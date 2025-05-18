# NixOS Configuration

## Installation

nix run github:nix-community/disko -- --mode disko ./hosts/{host}/disko.nix
nixos-install --flake .#encrypted-nixos

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

## References

- [NixOS Flake Book](https://nixos-and-flakes.thiscute.world/)
- [Lookup packages and there configuration options - MyNixOS](https://mynixos.com/)
- [Official option search](https://search.nixos.org/options)
- [Nix Quellcode](https://github.com/NixOS/nixpkgs/tree/master)
- [Noogle - Nix Function Search similar to Hoogle for Haskle](https://noogle.dev/)

