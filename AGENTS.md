# AGENTS.md

## Repo purpose

Dotfiles managed with Nix flakes. Four host configurations:
- **`tobi`** — ThinkPad T480, NixOS, XMonad (X11)
- **`tobixx`** — Dell Precision 5560, NixOS, Hyprland (Wayland)
- **`dwp7953`** — Ubuntu (standalone home-manager only), XMonad (X11)
- **`MN-EXLRFJ470Y77`** — MacBook Pro (nix-darwin + home-manager), aarch64-darwin
- **`contabo-server`** — Contabo VPS (NixOS), containerized applications with Docker Compose + Traefik

## Critical commands

### NixOS hosts
```bash
sudo nixos-rebuild switch --flake .#tobi
sudo nixos-rebuild switch --flake .#tobixx
sudo nixos-rebuild switch --flake .#contabo-server  # via SSH
```

### macOS (nix-darwin)
```bash
darwin-rebuild switch --flake .#MN-EXLRFJ470Y77
```

### Ubuntu (standalone home-manager)
```bash
# Must source nix profile first if nix isn't in PATH
source ~/.nix-profile/etc/profile.d/nix.sh

nix run .#homeConfigurations.dwp7953.activationPackage
```

### Maintenance (all hosts)
```bash
nix flake update                              # update all inputs
nix-collect-garbage -d                        # user home-manager packages
sudo nix-collect-garbage -d                   # system packages (NixOS/darwin only)
```

### Contabo server (remote deployment)
```bash
# root SSH login is disabled entirely — always use the tobias user (wheel, passwordless sudo)
ssh tobias@62.84.178.194 'cd ~/.dotfiles && git pull && sudo nixos-rebuild switch --flake .#contabo-server'
```

## Architecture

- `flake.nix` — Single entrypoint; defines all host configurations
- `hosts/<name>/default.nix` — System-level config (NixOS or nix-darwin)
  - Boot loader, hardware, networking, system services (NixOS only)
  - System defaults and packages (all systems)
- `hosts/<name>/home.nix` — Per-host home-manager entrypoint
- `home/` — Shared home-manager modules, **auto-imported** via `lib.my.listModulesRecursivly`
- `modules/` — NixOS system-level modules (not used on macOS or Ubuntu), auto-imported
- `lib/default.nix` — Defines `lib.my.listModulesRecursivly` (collects all `.nix` except `default.nix`)

## Platform-specific configurations

### NixOS Hosts (`tobi`, `tobixx`, `contabo-server`)
- Full system configuration including boot, hardware, networking
- Uses systemd for service management
- Can use agenix for secrets (integrated into flake)

### macOS (`MN-EXLRFJ470Y77`)
- Uses **nix-darwin** for system configuration (not traditional NixOS)
- Uses **Homebrew** for additional packages via `hosts/macos/homebrew.nix`
- Configures macOS defaults (key repeat, spell check, etc.)
- Uses `darwin-rebuild` for deployments
- Home-manager integration via nix-darwin modules

### Ubuntu (`dwp7953`)
- **Standalone home-manager only** (no NixOS or nix-darwin)
- Does NOT auto-import from `home/` directory
- Hand-picks only necessary modules: `core.nix`, `ai.nix`, `shell/`, `neovim/`
- Avoids WM-specific configs (Hyprland, Waybar, Sway, Stylix) that don't apply to Ubuntu
- When adding shared modules: if system-specific, explicitly add to Ubuntu's imports only if needed

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

## Usernames & Git Identity

- `tobi`, `tobixx`, `contabo-server`: git identity `tobiornot2b / pgpg.toby@gmail.com`
- `dwp7953`: git identity `Tobias Maede / tobias.maede.ext@dwpbank.de`
- `MN-EXLRFJ470Y77`: git identity `tobiornot2b / pgpg.toby@gmail.com`

## Contabo Server Setup

The Contabo VPS (`62.84.178.194`) runs a reproducible containerized application stack managed entirely via NixOS and agenix.

### Architecture

```
Internet (HTTPS on port 443)
         ↓
    Traefik (Reverse Proxy) — on web + backend networks
         ↓
    Vikunja (Todo App) — on backend network only
         ↓
    PostgreSQL (Database) — on backend network (internal)
```

**Key files**:
- `hosts/contabo-server/default.nix` — System configuration, Docker setup, agenix secrets
- `hosts/contabo-server/server/docker-compose.yaml` — Container definitions
- `secrets/contabo-server/apps.env.age` — Encrypted environment variables
- `hosts/contabo-server/README.md` — Full architecture and operations guide

**`nono` package**: sourced from the `llm-agents-nix` flake input (`github:numtide/llm-agents.nix`), not nixpkgs — nixpkgs' copy lags upstream. Wired in `flake.nix` (contabo-server's `environment.systemPackages` module block), not in `hosts/contabo-server/default.nix`. Run `nix flake update llm-agents-nix` to pull newer releases.

### Network Isolation

- **`apps-web` network**: Only Traefik (public-facing, listens on ports 80/443)
- **`apps-backend` network**: Traefik, Vikunja, PostgreSQL (internal, marked `internal: true`)

**Security guarantee**: All internet traffic must pass through Traefik. Vikunja and PostgreSQL cannot be accessed directly from the internet.

### Secrets Management

Environment variables are encrypted with **agenix** using both server SSH host key and user SSH key:

```bash
# To edit secrets locally (requires server's SSH keys to be in ~/.ssh/)
agenix -e secrets/contabo-server/apps.env.age

# Deploy after changes — root SSH login is disabled, use tobias (wheel, passwordless sudo)
ssh tobias@62.84.178.194 'cd ~/.dotfiles && git pull && sudo nixos-rebuild switch --flake .#contabo-server'
```

**Contains**: `POSTGRES_PASSWORD`, `POSTGRES_USER`, `VIKUNJA_DATABASE_NAME`, `VIKUNJA_SERVICE_JWTSECRET`, `ACME_EMAIL`

### Agent Guidelines for Contabo Server

**When modifying the server, agents should:**

1. **Work remotely via SSH as `tobias`** — Do NOT assume you're running locally on the Contabo machine, and never use `root`
   - Root SSH login is disabled entirely (`PermitRootLogin = "no"`) — there is no way in as root
   - Use `ssh tobias@62.84.178.194 'command'` to execute commands
   - `tobias` has passwordless `sudo` (wheel group) — prefix privileged commands with `sudo`
   - Use SSH to read/check files on the server
   
2. **Follow the deployment pattern**:
   ```bash
   # Pull latest code
   ssh tobias@62.84.178.194 'cd ~/.dotfiles && git pull'
   
   # Make changes locally (in this repo), commit, and push
   git add <files>
   git commit -m "message"
   git push
   
   # Deploy on server
   ssh tobias@62.84.178.194 'cd ~/.dotfiles && git pull && sudo nixos-rebuild switch --flake .#contabo-server'
   ```

3. **Modify Docker Compose services** — Edit `hosts/contabo-server/server/docker-compose.yaml`
   - Keep generic naming: `apps-traefik-1`, `apps-postgres-1`, `apps-vikunja-1`
   - Always place new services on the `backend` network
   - Only expose ports via Traefik labels if needed on public internet
   - All internal services should be on `backend` network (marked `internal: true`)

4. **Add new secrets** — Edit `secrets/contabo-server/apps.env.age`
   ```bash
   agenix -e secrets/contabo-server/apps.env.age
   # Add variables
   # Save and commit
   git add secrets/contabo-server/apps.env.age
   git commit -m "chore: update secrets"
   git push
   ```

5. **Update NixOS config** — Modify `hosts/contabo-server/default.nix` only for system-level changes (boot, networking, SSH, firewall, systemd services)
   - For container changes, edit `docker-compose.yaml` instead
   - For secrets, use agenix (see point 4)

6. **Verify deployments**:
   ```bash
   # After deployment, verify via SSH
   ssh tobias@62.84.178.194 'docker ps'
   ssh tobias@62.84.178.194 'curl -I https://todo.tobiornot2b.com'
   ssh tobias@62.84.178.194 'sudo systemctl status apps-compose'
   ```

7. **Don't assume running locally** — When writing scripts or commands:
   - If they need to run on Contabo: Wrap in `ssh tobias@62.84.178.194 '...'`
   - If they're local development: Run directly without SSH
   - Be explicit about which machine the operation targets
   - Never use `root` — SSH login as root is disabled; `tobias` has passwordless sudo for anything privileged
