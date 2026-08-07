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

`nixos-anywhere` allows you to install NixOS on a remote machine from a Linux system. This is required when installing on x86_64 targets from macOS (cross-compilation not supported without complex Remote Building setup).

### Prerequisites

- A Linux machine with Nix installed (can be a temporary VM or remote server)
- SSH access to the target server (running in Rescue Mode, BIOS, or live-boot)
- The target server's SSH key fingerprint (verify via `ssh-keyscan`)
- A defined NixOS configuration in the flake (e.g., `contabo-server`)
- A LUKS encryption key file (if using disk encryption)

### Step-by-step Installation

#### 1. Prepare the LUKS key (if encryption is needed)

Create a secure passphrase file **outside the repository**:

```bash
umask 077
install -m 600 /dev/null /tmp/contabo-luks-key
# Securely enter the passphrase (will not be echoed)
cat > /tmp/contabo-luks-key << 'EOF'
<your-secure-passphrase>
EOF
```

**Important:** Never commit this file to git or display it in logs.

#### 2. Verify SSH access to the target

```bash
ssh-keyscan -t ed25519 root@<TARGET_IP> >> ~/.ssh/known_hosts 2>/dev/null
ssh root@<TARGET_IP> "uname -a && lsblk"
```

Replace `<TARGET_IP>` with the server's IP address (e.g., `62.84.178.194`).

#### 3. Run nixos-anywhere from a Linux machine

```bash
cd /path/to/dotfiles
nix run github:nix-community/nixos-anywhere -- \
  --flake .#<HOST_NAME> \
  --disk-encryption-keys /tmp/contabo-luks-key \
  root@<TARGET_IP>
```

**Parameters:**
- `<HOST_NAME>`: Your NixOS configuration name (e.g., `contabo-server`)
- `<TARGET_IP>`: Target server IP (e.g., `62.84.178.194`)
- `--disk-encryption-keys`: Path to the LUKS passphrase file

**Example:**
```bash
nix run github:nix-community/nixos-anywhere -- \
  --flake .#contabo-server \
  --disk-encryption-keys /tmp/contabo-luks-key \
  root@62.84.178.194
```

The process will:
1. Connect via SSH
2. Create a kexec (kernel boot in RAM)
3. Partition the target disk according to disko configuration
4. Format and encrypt (LUKS2) if configured
5. Install NixOS
6. Set up the bootloader
7. Configure SSH and networking

#### 4. Monitor the installation

The installation output will show:
- Disk partitioning progress
- LUKS encryption setup
- NixOS installation steps
- Build logs

**If an error occurs:**
- Do NOT blindly reboot
- Check the error message carefully
- Verify disk/network configuration
- Reconnect via SSH (Rescue System should still be active)
- Check logs: `journalctl -xeu disko` or similar

#### 5. First boot and LUKS unlock

After successful installation:

1. **Reboot the server** (via Contabo panel, KVM, or `reboot` command)
2. **Open Contabo VNC/KVM console** (from the Contabo control panel)
3. **Wait for LUKS unlock prompt**
   - The boot process will pause with: `Passphrase for /dev/sda2 (or similar):`
4. **Enter the LUKS passphrase** via the VNC/KVM console keyboard
5. **System completes boot**, networking and SSH become available
6. **SSH access resumes** normally after boot

**Note:** Without entering the LUKS passphrase via VNC/KVM, the system cannot boot. This is expected behavior. Remote unlock solutions (initrd SSH, Clevis/Tang) require additional setup.

#### 6. Verify the installation

After first boot and LUKS unlock, SSH into the system:

```bash
ssh root@<TARGET_IP>
```

Run system checks:

```bash
hostnamectl
uname -a
findmnt
lsblk -f
systemctl status
systemctl --failed
resolvectl status
```

Verify LUKS encryption:

```bash
lsblk -f
cryptsetup status cryptroot
```

#### 7. Clean up temporary files

After successful installation, securely delete the LUKS key file:

```bash
shred -u /tmp/contabo-luks-key 2>/dev/null || rm -f /tmp/contabo-luks-key
```

### Troubleshooting

**SSH connection refused:**
- Verify the target server is in Rescue Mode or running a live system with SSH
- Check firewall rules in the Contabo panel
- Verify the SSH port is open (usually 22)

**Disk not found:**
- Run `lsblk` on the target server to confirm the device name
- Update the disko configuration with the correct device (e.g., `/dev/sda`, `/dev/nvme0n1`)

**LUKS passphrase incorrect:**
- Reboot via VNC/KVM and try again
- Remember that the passphrase must match exactly (including spaces, special chars)

**Boot fails after installation:**
- Use VNC/KVM to see boot errors
- Check bootloader configuration (BIOS vs. UEFI)
- Verify hardware-configuration.nix is correct for the target

**nixos-anywhere hangs:**
- SSH connection may be timing out
- Check network connectivity on the target
- Try increasing timeout: add `SSH_TIMEOUT=30` environment variable

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

