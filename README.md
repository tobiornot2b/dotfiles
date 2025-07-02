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

