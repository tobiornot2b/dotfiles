# Skill: Nix Module Generator

## Usage
```
/nix-module-gen --path <path> --type <type>
/nix-module-gen --list-templates
/nix-module-gen --validate <file>
```

## What it does

Scaffolds new home-manager or NixOS modules following the dotfiles repository conventions. Generates:
- Module structure with proper imports
- Custom options using `my.*` namespace
- Configuration sections with `mkIf`
- Documentation comments
- Git-ready file structure

## Module Types

### `single`
Single `.nix` file for simple tool configs:
```bash
/nix-module-gen --path home/mytool --type single
```
Creates: `home/mytool.nix` with basic program setup

### `directory`
Directory-based module with subcomponents:
```bash
/nix-module-gen --path home/myapp --type directory
```
Creates:
```
home/myapp/
├── default.nix
├── submodule-1.nix
└── submodule-2.nix
```

### `system`
NixOS system-level module:
```bash
/nix-module-gen --path modules/myfeature --type system
```
Creates module for system services, boot config, hardware, etc.

## Generated Structure

A typical single-file module:
```nix
{ config, pkgs, lib, ... }:
with lib;

let
  cfg = config.my.mytool;
in
{
  options.my.mytool = {
    enable = mkEnableOption "MyTool description";
    # Add more options here
  };
  
  config = mkIf cfg.enable {
    # Configuration here
    programs.mytool = { enable = true; };
  };
}
```

## Conventions

Generated modules follow:
- **Naming**: lowercase-with-hyphens for files
- **Options namespace**: `config.my.<feature>.enable` pattern
- **Structure**: options → config sections
- **Imports**: explicit or via `listModulesRecursivly`
- **File organization**: single-file for <100 lines, directory for larger modules

## Integration

After generation:
1. Add to appropriate `home/default.nix` or host config
2. Run: `nix flake check`
3. Test with: `sudo nixos-rebuild switch --flake .` (NixOS) or `nix run .#homeConfigurations.dwp7953.activationPackage` (Ubuntu)

## Examples

### Create a simple tool module
```
/nix-module-gen --path home/mytools --type single
# Now edit home/mytools.nix and add programs
```

### Create window manager module
```
/nix-module-gen --path home/mydesk --type directory
# Create default.nix and keybindings.nix submodule
```

### Create system service
```
/nix-module-gen --path modules/myservice --type system
# Configure systemd service, boot hooks, etc.
```

## Related Skills
- `/nix-query` — Find packages for your module
- `/flake-update` — Manage dependencies
