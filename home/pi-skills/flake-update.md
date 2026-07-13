# Skill: Flake Update

## Usage
```
/flake-update --check
/flake-update --input <name> [--to <version>]
/flake-update --all [--dry-run]
```

## What it does

Safely updates flake inputs with validation and compatibility checking. Prevents breaking changes and maintains reproducibility.

Features:
- Check for available updates without applying
- Update specific inputs with version pinning
- Dry-run mode to preview changes
- Compatibility validation
- Automatic flake.lock refresh

## Commands

### Check for updates (no changes)
```
/flake-update --check
```
Shows available updates for all inputs without modifying flake.lock

### Update a specific input
```
/flake-update --input nixpkgs --to "nixos-24.05"
/flake-update --input home-manager
```
Updates single input and validates compatibility

### Dry-run all updates
```
/flake-update --all --dry-run
```
Shows what would change without committing

### Apply all updates
```
/flake-update --all
```
Updates all inputs and validates

## Validation

Before applying updates, checks:
- ✓ No syntax errors in updated flake.nix
- ✓ All derivations evaluate successfully
- ✓ No incompatible versions (e.g., home-manager vs nixpkgs)
- ✓ System-specific packages available
- ✓ No regressions in dependency tree

## Workflow

1. **Check available updates:**
   ```
   /flake-update --check
   ```

2. **Test update (dry-run):**
   ```
   /flake-update --input nixpkgs --dry-run
   ```

3. **Apply update:**
   ```
   /flake-update --input nixpkgs
   ```

4. **Verify locally:**
   ```
   sudo nixos-rebuild switch --flake .#tobi
   ```

5. **Commit:**
   ```
   git add flake.lock
   git commit -m "chore(flake): update inputs"
   ```

## Important Notes

- Updates are conservative (minor version bumps by default)
- Major version jumps require explicit `--to <version>`
- Each system gets validated (thinkpad-t480, dell-precision-5560, ubuntu)
- Agenix secrets remain compatible
- Flake.lock is always committed with updates

## Troubleshooting

If update fails:
```
/flake-update --input problematic-package --dry-run
```
Shows error details for investigation.

Rollback to previous state:
```
git checkout HEAD~ flake.lock
sudo nixos-rebuild switch --flake .
```

## Related Skills
- `/nix-query` — Find newer versions of packages
- `/nix-module-gen` — Update module compatibility with new versions
