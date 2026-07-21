# macOS Host Configuration

This directory contains the nix-darwin configuration for macOS systems.

## Prerequisites

### Homebrew Installation

**Homebrew must be installed manually before applying the nix-darwin configuration.**

nix-darwin cannot automatically install Homebrew, but it can manage Homebrew packages once installed.

To install Homebrew, run:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

After installation, follow the post-install instructions to add Homebrew to your `$PATH`.

## Configuration Files

- **`default.nix`** — System-level configuration (settings, environment, imports)
- **`home.nix`** — Home-manager configuration (user-specific settings, git, etc.)
- **`homebrew.nix`** — Homebrew package management (formulae, casks, etc.)

## Applying the Configuration

Once Homebrew is installed, apply the configuration:

```bash
darwin-rebuild switch --flake .#MN-EXLRFJ470Y77
```

This will:
- Install/manage Homebrew packages defined in `homebrew.nix`
- Apply system settings from `default.nix`
- Configure the user environment from `home.nix`

## Adding Packages

To add Homebrew packages, edit `homebrew.nix`:

- **Formulae** (command-line tools): Add to `homebrew.brews`
- **Casks** (applications): Add to `homebrew.casks`

Example:

```nix
homebrew.casks = [
  "ghostty"
  "firefox"
];
```

Then run `darwin-rebuild switch --flake .#MN-EXLRFJ470Y77` to apply changes.
