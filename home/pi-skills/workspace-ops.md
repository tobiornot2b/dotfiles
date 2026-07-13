# Skill: Workspace Operations

## Usage
```
/workspace-ops clone <repo-url> [--name <alias>]
/workspace-ops init-project <name> [--template <type>]
/workspace-ops link-dotfiles [--host <hostname>]
/workspace-ops sync-all
```

## What it does

Manages project workspace operations in the context of the dotfiles repository. Handles:
- Cloning and organizing repositories
- Initializing new projects with proper structure
- Managing dotfiles symlinks across systems
- Syncing configurations across machines

## Commands

### Clone a repository
```
/workspace-ops clone https://github.com/user/project
/workspace-ops clone git@github.com:user/project --name myproject
```
Clones repository with proper structure and git setup.

### Initialize new project
```
/workspace-ops init-project my-app
/workspace-ops init-project microservice --template nix-flake
```

Available templates:
- `nix-flake` — Nix flake-based project
- `node` — Node.js project
- `rust` — Rust cargo project
- `python` — Python poetry/venv project
- `generic` — Simple project structure

### Link dotfiles to system
```
/workspace-ops link-dotfiles --host thinkpad-t480
/workspace-ops link-dotfiles --host dell-precision-5560
```
Symlinks dotfiles configuration to target system paths.

### Sync across systems
```
/workspace-ops sync-all
```
Pulls latest dotfiles and rebuilds all local systems.

## Workflow Example

### Initial Setup on New Machine

```bash
# 1. Clone dotfiles
/workspace-ops clone https://github.com/user/.dotfiles --name dotfiles

# 2. Link to system
/workspace-ops link-dotfiles --host tobixx

# 3. Rebuild system
sudo nixos-rebuild switch --flake ~/.dotfiles#tobixx

# 4. Sync all projects
/workspace-ops sync-all
```

### Creating New Project

```bash
# 1. Initialize with nix flake
/workspace-ops init-project rust-api --template nix-flake

# 2. Add project-specific pi skills
# (Create .pi/skills/rust-dev.md)

# 3. Enable project instructions
# (Create .pi/AGENTS.md with rust-specific guidelines)

# 4. Start working
pi "Generate basic Axum web server"
```

### Multi-Host Development

```bash
# On ThinkPad
cd ~/.dotfiles
git pull
/workspace-ops sync-all

# On Dell
cd ~/.dotfiles
git pull
sudo nixos-rebuild switch --flake .#tobixx
/workspace-ops sync-all
```

## Directory Structure

```
~
├── .dotfiles/                 # System dotfiles (synced across hosts)
│   ├── home/
│   ├── hosts/
│   ├── modules/
│   └── .git
│
├── projects/                  # Development projects
│   ├── project-a/
│   ├── project-b/
│   └── ...
│
└── work/                       # Work-specific projects (optional, host-specific)
    └── ...
```

## Integration with Pi

Each workspace can have:
```
project-root/
├── flake.nix                 # Project dependencies
├── .pi/
│   ├── AGENTS.md            # Project-specific instructions
│   ├── skills/              # Project skills
│   └── extensions/          # Project extensions
└── src/
```

When working in a project, Pi automatically loads:
- Project AGENTS.md instructions
- Project-specific skills and extensions
- Project flake.nix dependencies

## Related Skills
- `/nix-query` — Find packages for new projects
- `/nix-module-gen` — Create new dotfiles modules
