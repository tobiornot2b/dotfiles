# AGENTS.md

## Repo purpose

Dotfiles managed with Nix flakes. Three configurations:
- **`tobi`** — ThinkPad T480, NixOS, XMonad (X11)
- **`tobixx`** — Dell Precision 5560, NixOS, Hyprland (Wayland)
- **`dwp7953`** — Current machine (Ubuntu), standalone home-manager only, XMonad (X11)

## Critical commands

### NixOS hosts
```bash
sudo nixos-rebuild switch --flake .#tobi      # ThinkPad
sudo nixos-rebuild switch --flake .#tobixx    # Dell
```

### Ubuntu (standalone home-manager)
```bash
# Must source nix profile first if nix isn't in PATH
source ~/.nix-profile/etc/profile.d/nix.sh

nix run .#homeConfigurations.dwp7953.activationPackage
```

### Maintenance
```bash
nix flake update                              # update all inputs
sudo nix-collect-garbage -d                   # GC as root (system)
nix-collect-garbage -d                        # GC as user (home-manager)
```

## Architecture

- `flake.nix` — single entrypoint; defines all three configurations
- `hosts/<name>/default.nix` — NixOS system config (boot, hardware, services)
- `hosts/<name>/home.nix` — per-host home-manager entrypoint
- `home/` — shared home-manager modules, **auto-imported** via `lib.my.listModulesRecursivly`
- `modules/` — NixOS system-level modules, also auto-imported
- `lib/default.nix` — defines `lib.my.listModulesRecursivly` (collects all `.nix` except `default.nix`)

## Ubuntu vs NixOS: key differences

The Ubuntu config (`hosts/ubuntu/home.nix`) **does NOT** use `../../home` (which auto-imports everything). It hand-picks only: `core.nix`, `ai.nix`, `chromium.nix`, `spotify.nix`, `rofi/`, `shell/`, `neovim/`. This avoids pulling in Hyprland, Waybar, Sway, Stylix, XMonad system modules, etc.

When adding a new shared module: if it's Wayland/Hyprland-specific, don't add it to Ubuntu's imports. If it's universal, add it explicitly.

## WM configs

- **XMonad**: defined as a NixOS module with a custom option `my.desktop.xmonad.enable`. Config lives in `modules/xmonad/xmonad.hs` (Haskell). On Ubuntu, the file is symlinked into `~/.xmonad/xmonad.hs` via `home.file`.
- **Hyprland**: system-enabled in Dell host; home config in `home/hyprland/default.nix`. Includes Hyprlock, Pyprland (Logseq scratchpad), and UDEV monitor-hotplug script (`modules/udev/monitors-reconfigure.sh`).
- **Waybar**: configured in `home/waybar/default.nix` but `enable = false`.
- **Sway**: module exists (`modules/sway/`, `home/sway.nix`) but not enabled on any current host.

## Secrets

agenix is used only on NixOS hosts (not Ubuntu). Secrets stored in `secrets/`. Editing requires the age key on the target machine.

## Neovim config

Lives in `config/nvim/` and is linked into place via `mkOutOfStoreSymlink` — edits there take effect immediately without a rebuild.

## Ubuntu-specific inline scripts

Defined as `pkgs.writeShellScriptBin` in `hosts/ubuntu/home.nix`: `wg-toggle`, `wg-status`, `kb-toggle`, `kb-status`, `posture-toggle`, `posture-status`. These feed colored Nerd Font icons into xmobar.

## No CI, no pre-commit, no formatter config

There are no automated checks. Validate changes by running a rebuild against the target host.

## Usernames

- NixOS hosts: user `tobi`, git identity `tobiornot2b / pgpg.toby@gmail.com`
- Ubuntu: user `dwp7953`, git identity `Tobias Maede / tobias.maede.ext@dwpbank.de`
