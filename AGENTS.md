# AGENTS.md

## Repo purpose

Dotfiles managed with Nix flakes. Three configurations:
- **`tobi`** — ThinkPad T480, NixOS, XMonad (X11)
- **`tobixx`** — Dell Precision 5560, NixOS, Hyprland (Wayland)
- **`dwp7953`** — Current machine (Ubuntu), standalone home-manager only, XMonad (X11)
- **`contabo-server`** — Contabo VPS (NixOS), containerized applications with Docker Compose + Traefik

## Critical commands

### NixOS hosts (local)
```bash
sudo nixos-rebuild switch --flake .#tobi      # ThinkPad
sudo nixos-rebuild switch --flake .#tobixx    # Dell
```

### Contabo server (remote via SSH)
```bash
ssh root@62.84.178.194 'cd /root/.dotfiles && git pull && sudo nixos-rebuild switch --flake .#contabo-server'
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
- Contabo server: user `root`, git identity `tobiornot2b / pgpg.toby@gmail.com`

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

### Network Isolation

- **`apps-web` network**: Only Traefik (public-facing, listens on ports 80/443)
- **`apps-backend` network**: Traefik, Vikunja, PostgreSQL (internal, marked `internal: true`)

**Security guarantee**: All internet traffic must pass through Traefik. Vikunja and PostgreSQL cannot be accessed directly from the internet.

### Secrets Management

Environment variables are encrypted with **agenix** using both server SSH host key and user SSH key:

```bash
# To edit secrets locally (requires server's SSH keys to be in ~/.ssh/)
agenix -e secrets/contabo-server/apps.env.age

# Deploy after changes
ssh root@62.84.178.194 'cd /root/.dotfiles && git pull && sudo nixos-rebuild switch --flake .#contabo-server'
```

**Contains**: `POSTGRES_PASSWORD`, `POSTGRES_USER`, `VIKUNJA_DATABASE_NAME`, `VIKUNJA_SERVICE_JWTSECRET`, `ACME_EMAIL`

### Agent Guidelines for Contabo Server

**When modifying the server, agents should:**

1. **Work remotely via SSH** — Do NOT assume you're running locally on the Contabo machine
   - Use `ssh root@62.84.178.194 'command'` to execute commands
   - Use SSH to read/check files on the server
   
2. **Follow the deployment pattern**:
   ```bash
   # Pull latest code
   ssh root@62.84.178.194 'cd /root/.dotfiles && git pull'
   
   # Make changes locally (in this repo), commit, and push
   git add <files>
   git commit -m "message"
   git push
   
   # Deploy on server
   ssh root@62.84.178.194 'cd /root/.dotfiles && git pull && sudo nixos-rebuild switch --flake .#contabo-server'
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
   ssh root@62.84.178.194 'docker ps'
   ssh root@62.84.178.194 'curl -I https://todo.tobiornot2b.com'
   ssh root@62.84.178.194 'sudo systemctl status apps-compose'
   ```

7. **Don't assume running locally** — When writing scripts or commands:
   - If they need to run on Contabo: Wrap in `ssh root@62.84.178.194 '...'`
   - If they're local development: Run directly without SSH
   - Be explicit about which machine the operation targets
