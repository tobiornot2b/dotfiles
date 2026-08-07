# NixOS Configuration

## Installation

### Create partitions with disko

```
sudo nix run --extra-experimental-features "nix-command flakes" github:nix-community/disko/latest -- --mode disko ./hosts/dell-precision-5560/disko.nix 
```

### Generate new hardware configuration

```
sudo nixos-generate-config --root /mnt
```
and save it to the needed position (f.e. ./hosts/dell-precision-5560/hardware-configuration.nix)

### Install

```
nixos-install --flake .#tobixx
```

## Building the system

Every configuration change needs an rebuild of the system. This is done by the following command:

```
sudo nixos-rebuild switch --flake .#tobi
```

The command need to be run in this directory. Otherwise the value of the --flake parameter has to be the path to the flake.nix file.

More helpful output can be received with the `--show-trace --print-build-logs --verbose` parameters while rebuilding.

The `#tobi` here is the reference for the system configuration that should be applied.

## Updating

The system can be updated by running the following command:

```
nix flake update
```

This will update the versions in the flake file. Maybe there are `sudo` permissions needed to update the files.
To apply the changes the system need to be rebuilded.

The NixOS Version can be updated by changing the input versions in the flake.nix to the prefered version. A new OS Version needs some space so ensure that there is enough space (>10 GB).

## System cleanup

**Delete all historical versions older than 7 days**
```
sudo nix profile wipe-history --older-than 7d --profile /nix/var/nix/profiles/system
```

**Wiping history won't garbage collect the unused packages, you need to run the gc command manually as root:**
```
sudo nix-collect-garbage --delete-old
```

**Due to the following issue, you need to run the gc command as per user to delete home-manager's historical data:
https://github.com/NixOS/nix/issues/8508**
```
nix-collect-garbage --delete-old`
```

## MacOS

Initially the following command need to be used for install:

```
sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake .#MN-EXLRFJ470Y77
```

This will install `darwin-` tools that can be used for the following builds:

```
sudo darwin-rebuild switch --flake .#MN-EXLRFJ470Y77
```

## Ubuntu

Make nix available in the current shell:

```
. /home/dwp7953/.nix-profile/etc/profile.d/nix.sh
```

Build the current setup:

```
nix run .#homeConfigurations.dwp7953.activationPackage
```

## nixos-anywhere: Remote NixOS Installation

`nixos-anywhere` allows you to install NixOS on a remote machine over SSH. This is the method used for the `contabo-server` configuration and can be reused for any future server. The contabo VPC can be put into rescue mode at new.contabo.com.

### Prerequisites

- A Linux machine with Nix installed (the machine you run commands from)
- SSH access to the target server with password auth (Rescue Mode or fresh VPS)
- A NixOS configuration in the flake (e.g., `contabo-server`)
- A LUKS passphrase if disk encryption is desired

### Key design decisions (contabo-server)

- **Partition table: GPT** — disko does not support MBR/msdos partition tables. GPT is used even for BIOS/Legacy boot systems.
- **BIOS boot partition** — A 1 MB `EF02` partition is required for GRUB to embed itself on a GPT disk without UEFI.
- **`boot.loader.grub.device` must NOT be set** in `default.nix`. Disko auto-configures `boot.loader.grub.devices` from the `EF02` partition. Setting it manually causes a `duplicated devices in mirroredBoots` assertion failure.
- **`fileSystems` must NOT be set** in `hardware-configuration.nix`. Disko generates them using `/dev/disk/by-partlabel` paths; static `/dev/sdaX` entries from `nixos-generate-config` conflict with these.

### Step-by-step Installation

#### 1. Add your SSH public key to the NixOS configuration

Before installing, make sure your public key is in `authorizedKeys` in `hosts/<HOST>/default.nix`. After installation SSH password login is disabled — if your key is missing there is no way in.

```bash
cat ~/.ssh/id_ed25519.pub
```

Add the output to `users.users.root.openssh.authorizedKeys.keys` in the host config.

#### 2. Upload your SSH key to the rescue system

The target server likely only accepts password auth in rescue mode. Upload your key so nixos-anywhere can connect without a password:

```bash
# Install sshpass temporarily if needed
nix-shell -p sshpass --run "sshpass -p '<rescue-password>' ssh-copy-id -o StrictHostKeyChecking=no root@<TARGET_IP>"

# Verify key auth works
ssh root@<TARGET_IP> "uname -a && lsblk"
```

#### 3. Prepare the LUKS key file

Create the passphrase file **outside the repository** (never commit it):

```bash
umask 077
printf '<your-secure-passphrase>' > /tmp/contabo-luks-key
chmod 600 /tmp/contabo-luks-key
```

#### 4. Run nixos-anywhere

```bash
cd ~/.dotfiles
nix run github:nix-community/nixos-anywhere -- \
  --flake .#<HOST_NAME> \
  --disk-encryption-keys /tmp/contabo-luks-key /tmp/contabo-luks-key \
  root@<TARGET_IP>
```

The `--disk-encryption-keys` flag takes two arguments: `<remote-path> <local-path>`.
nixos-anywhere uploads the local file to the remote path before running disko.
The remote path must match the `keyFile` value in `disko.nix`.

**Example (contabo-server):**
```bash
nix run github:nix-community/nixos-anywhere -- \
  --flake .#contabo-server \
  --disk-encryption-keys /tmp/contabo-luks-key /tmp/contabo-luks-key \
  root@62.84.178.194
```

The process will:
1. Boot a temporary NixOS environment in RAM via kexec
2. Partition the disk according to `disko.nix`
3. Format, encrypt (LUKS2), and mount filesystems
4. Install the NixOS system closure
5. Install GRUB and reboot

#### 5. First boot and LUKS unlock

After the reboot nixos-anywhere triggers, the system will pause at the LUKS
unlock prompt — there is no remote way to enter this on first boot.

1. **Open the Contabo VNC/KVM console** (Contabo control panel → KVM)
2. **Wait for the prompt:** `Please enter passphrase for disk ... (cryptroot):`
3. **Type the LUKS passphrase** and press Enter
4. The system completes boot; SSH becomes available again

> Without the LUKS passphrase the system cannot boot. This is by design.
> For unattended reboots, consider setting up initrd SSH or Clevis/Tang.

#### 6. First SSH connection after install

The host key has changed (new NixOS install). Remove the old entry and connect:

```bash
ssh-keygen -R <TARGET_IP>
ssh root@<TARGET_IP>
```

Or accept the new key in one step:

```bash
ssh -o StrictHostKeyChecking=accept-new root@<TARGET_IP>
```

#### 7. Verify the installation

```bash
hostnamectl
uname -a
lsblk -f
cryptsetup status cryptroot
systemctl --failed
```

#### 8. Clean up the LUKS key file

```bash
shred -u /tmp/contabo-luks-key 2>/dev/null || rm -f /tmp/contabo-luks-key
```

### Subsequent configuration changes

After the initial install, deploy changes with:

```bash
# NIX_SSHOPTS forces use of a specific key, avoiding "too many auth failures"
# when ssh-agent has many keys loaded.
NIX_SSHOPTS="-i ~/.ssh/id_ed25519 -o IdentitiesOnly=yes" \
  nixos-rebuild switch --flake .#contabo-server --target-host root@62.84.178.194
```

### Troubleshooting

**SSH: "Too many authentication failures"**
- The SSH client tried too many keys before the correct one. Use `NIX_SSHOPTS` to pin the identity (see Subsequent configuration changes above).

**SSH connection refused / timeout**
- Verify the server is in Rescue Mode or running a live system with SSH enabled
- Check firewall rules in the Contabo panel

**`attribute 'mbr' missing` / `attribute 'msdos' missing`**
- Disko only supports `gpt` as disk content type. See Key design decisions above.

**`duplicated devices in mirroredBoots`**
- `boot.loader.grub.device` is set explicitly alongside the disko-generated value. Remove the explicit setting from `default.nix`.

**`fileSystems."/boot".device has conflicting definition values`**
- `hardware-configuration.nix` contains static `fileSystems` entries that conflict with disko. Remove them — disko manages all filesystem definitions.

**Disk not found**
- Run `lsblk` on the target to confirm the device name and update `disko.nix` accordingly (e.g., `/dev/sda` vs `/dev/nvme0n1`).

**LUKS passphrase incorrect**
- Reboot via VNC/KVM and try again. The passphrase must match exactly.

**Boot fails after installation**
- Use VNC/KVM to see boot errors
- Verify BIOS vs. UEFI: the current config is BIOS/Legacy. For UEFI, replace the `EF02` BIOS boot partition with an `EF00` EFI System Partition and switch to `boot.loader.systemd-boot` or `boot.loader.grub.efiSupport = true`.

## Display Link

In order to install the DisplayLink drivers, you must first
   > comply with DisplayLink's EULA and download the binaries and
   > sources from here:
   >
   > https://www.synaptics.com/products/displaylink-graphics/downloads/ubuntu-6.1
   >
   > Once you have downloaded the file, please use the following
   > commands and re-run the installation:
   >
   > mv $PWD/"DisplayLink USB Graphics Software for Ubuntu6.1-EXE.zip" $PWD/displaylink-610.zip
   > nix-prefetch-url file://$PWD/displaylink-600.zip

## TODOs

- Install [spotify](https://nixos.wiki/wiki/Spotify)

## References

- [NixOS Flake Book](https://nixos-and-flakes.thiscute.world/)
- [Lookup packages and there configuration options - MyNixOS](https://mynixos.com/)
- [Official option search](https://search.nixos.org/options)
- [Nix Quellcode](https://github.com/NixOS/nixpkgs/tree/master)
- [Noogle - Nix Function Search similar to Hoogle for Haskle](https://noogle.dev/)
- [Hyprland NixOS Reference Repo](https://gitlab.com/Zaney/zaneyos]

