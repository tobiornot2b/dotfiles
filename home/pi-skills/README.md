# Pi Skills

Collection of reusable skills for the Pi coding agent. Skills are markdown-based CLI tools that encapsulate domain knowledge and workflows.

## Skills

### nix-query.md
Query nixpkgs for packages, versions, and dependencies. Useful for finding the right package or understanding conflicts.

### nix-module-gen.md
Generate new home-manager modules following dotfiles conventions. Scaffolds module structure with proper options, config, and documentation.

### flake-update.md
Safely update flake inputs with version pinning and compatibility checking. Validates updates before committing.

### workspace-ops.md
Workspace management utilities: clone repositories, initialize new projects, manage dotfiles symlinks.

### git-helpers.md
Git workflow utilities: semantic commits, branch management, multi-repo operations.

## Using Skills

Skills are automatically available as `/skillname` commands in Pi:

```
/nix-query package-name
/nix-module-gen --path home/foo --type directory
/flake-update --check
/workspace-ops clone repo-url
```

## Adding New Skills

1. Create a `.md` file in this directory
2. Use the standard format:
   ```markdown
   # Skill: My Skill Name
   
   ## Usage
   /my-skill <args>
   
   ## What it does
   Description
   ```
3. Pi will automatically discover and load it

Skills appear in `/help` and are progressively disclosed during sessions.
