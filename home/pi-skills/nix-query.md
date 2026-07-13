# Skill: Nix Package Query

## Usage
```
/nix-query <package-name>
/nix-query --search <pattern>
/nix-query --info <package-name>
```

## What it does

Queries the nixpkgs repository for package information, versions, and metadata. Useful for:
- Finding the correct package name
- Checking available versions
- Understanding package attributes
- Discovering dependencies

## Examples

### Find a package
```
/nix-query nodejs
```
Returns: nodejs, nodejs_18, nodejs_20, nodejs_22 (latest), nodejs-slim, etc.

### Search by pattern
```
/nix-query --search "python.*dev"
```
Returns packages matching the pattern (regex)

### Get detailed info
```
/nix-query --info python3Packages.numpy
```
Shows: description, version, platform, maintainers, source

## Integration with dotfiles

Discovered packages are added to `home.packages` in the appropriate module:
- System tools → `home/core.nix`
- Development tools → `home/dev.nix` or language-specific
- Window managers → `home/hyprland/default.nix`, etc.

Use `nix flake check` after adding packages to ensure no conflicts.

## Related Skills
- `/nix-module-gen` — Create new Nix modules
- `/flake-update` — Update package versions in flake.lock
