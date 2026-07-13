# Skill: Git Helpers

## Usage
```
/git-commit [--type <type>] [--scope <scope>]
/git-branch --create <name> [--from <base>]
/git-sync [--all-repos]
/git-multi <command> [<args>...]
```

## What it does

Git workflow utilities for semantic commits, branch management, and multi-repository operations aligned with dotfiles conventions.

## Conventional Commits

Format: `type(scope): subject`

Available types:
- `feat` — New feature
- `fix` — Bug fix
- `docs` — Documentation only
- `style` — Code style (formatting, missing semicolons, etc.)
- `refactor` — Code refactoring without feature changes
- `perf` — Performance improvement
- `test` — Adding/updating tests
- `chore` — Build, CI, dependencies, tooling
- `ci` — CI/CD configuration

### Examples
```
feat(shell): add nix-shell auto-activation
fix(hyprland): resolve monitor hotplug on wake
docs(readme): update installation instructions
chore(flake): update nixpkgs inputs
```

## Commands

### Create semantic commit
```
/git-commit
# Interactive: prompts for type, scope, and message

/git-commit --type feat --scope pi-dev
# Creates: feat(pi-dev): <your message>
```

### Create feature branch
```
/git-branch --create feature/new-extension
/git-branch --create fix/hyprland-crash --from bugfix-base
```

Branch naming convention:
- `feature/<name>` — New features
- `fix/<name>` — Bug fixes
- `refactor/<name>` — Refactoring
- `docs/<name>` — Documentation

### Sync repositories
```
/git-sync
# Updates current repository (git pull origin main)

/git-sync --all-repos
# Updates ~/.dotfiles and ~/projects/*
```

### Multi-repo operations
```
/git-multi status
# Show git status in all repositories

/git-multi "git log --oneline -5"
# Run command in all repos

/git-multi branch --create release/1.0
# Create branch in all repos
```

## Workflow Examples

### Add new feature to dotfiles
```bash
# 1. Create feature branch
/git-branch --create feature/pi-extensions

# 2. Make changes
# (Create home/pi-extensions/src/my-extension.ts, etc.)

# 3. Check status
/git-commit
# Type: feat, Scope: pi-dev, Message: "Add custom extension"

# 4. Push
git push origin feature/pi-extensions

# 5. Create PR, get review
```

### Fix bug across systems
```bash
# 1. Branch
/git-branch --create fix/hyprland-monitor

# 2. Fix and test on Dell
sudo nixos-rebuild switch --flake .#tobixx

# 3. Commit
/git-commit --type fix --scope hyprland
# Message: "Fix monitor detection on hotplug"

# 4. Sync other systems
/git-sync --all-repos
sudo nixos-rebuild switch --flake .#tobi
```

### Update documentation
```bash
/git-branch --create docs/pi-setup
# Edit docs
/git-commit --type docs --scope pi-dev
```

## Integration with Pi

Pi can use these skills for self-service commits:
```
pi "Add new extension and create a semantic commit"
```

Pi will:
1. Generate code for the extension
2. Determine appropriate commit type/scope
3. Create conventional commit message
4. Stage files appropriately

## Related Skills
- `/workspace-ops` — Manage multi-project workflows
- `/nix-query` — Find packages (useful in commit review)
