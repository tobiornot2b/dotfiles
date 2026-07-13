{ config, pkgs, lib, ... }:
with lib;

let
  cfg = config.home.pi-dev;
  
  # Get the appropriate Node.js version
  nodePackage = builtins.getAttr "nodejs_${cfg.nodeVersion}" pkgs;
  
  # Pi package - try multiple locations or make it optional
  piPackage = if builtins.hasAttr "pi-coding-agent" pkgs then
    pkgs.pi-coding-agent
  else if lib.hasAttrByPath [ "nodePackages" "pi-coding-agent" ] pkgs then
    pkgs.nodePackages."@earendil-works/pi-coding-agent"
  else
    null;
  
  # Pi config directory - uses ~/.pi/agent by default (PI_CODING_AGENT_DIR env var)
  piConfigHome = "${config.home.homeDirectory}/.pi/agent";
  piDataHome = "${config.home.homeDirectory}/.pi/agent";
  
in
{
  options.home.pi-dev = {
    enable = mkEnableOption "Pi coding agent harness";
    
    package = mkOption {
      type = types.nullOr types.package;
      default = piPackage;
      description = "Pi package to use (can be null if not available in nixpkgs)";
    };
    
    nodeVersion = mkOption {
      type = types.str;
      default = "24";
      description = "Node.js major version to use";
    };
    
    extensionsPath = mkOption {
      type = types.str;
      default = "${config.home.homeDirectory}/.pi/agent/extensions";
      description = "Path to pi extensions directory";
    };
    
    skillsPath = mkOption {
      type = types.str;
      default = "${config.home.homeDirectory}/.pi/agent/skills";
      description = "Path to pi skills directory";
    };
    
    globalModels = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "List of default model providers (e.g., ['anthropic/claude-opus', 'openai/gpt-4-turbo'])";
    };
    
    theme = mkOption {
      type = types.enum [ "dark" "light" "auto" ];
      default = "dark";
      description = "Pi theme preference";
    };
    
    thinkingLevel = mkOption {
      type = types.enum [ "low" "medium" "high" ];
      default = "medium";
      description = "Default thinking level for claude models";
    };
    
    piPackages = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "List of pi packages to install (e.g., ['npm:@juicesharp/rpiv-ask-user-question'])";
      example = [ "npm:@juicesharp/rpiv-ask-user-question" "npm:@another/package@1.0.0" ];
    };
  };
  
  config = mkIf cfg.enable {
    # 1. Install pi globally with Node.js
    home.packages = [
      nodePackage
    ] ++ lib.optionals (cfg.package != null) [ cfg.package ];
    
    # 2. Create pi config directory structure
    home.file."${piConfigHome}/.keep".text = "";
    
    # 3. Create settings.json
    home.file."${piConfigHome}/settings.json" = mkIf (cfg.globalModels != []) {
      text = builtins.toJSON {
        thinking = cfg.thinkingLevel;
        theme = cfg.theme;
        enableSkillCommands = true;
        defaultProjectTrust = "ask";
        defaultModels = cfg.globalModels;
      };
    };
    
    # 4. Create AGENTS.md template for project instructions
    home.file."${piConfigHome}/AGENTS.md" = {
      text = ''
        # Pi Agent Instructions
        
        ## Project Context
        
        This project uses a Nix-based configuration management system.
        
        ## Guidelines
        
        - Follow nix conventions and patterns from the dotfiles repository
        - Use TypeScript for custom extensions
        - Keep responses concise and focused
        - Always check flake.lock before suggesting package updates
        - Test nix changes with: `nix flake check`
        - Rebuild the system with: `sudo nixos-rebuild switch --flake .`
        
        ## Available Skills
        
        - `/nix-query` — Query nixpkgs for packages
        - `/nix-module-gen` — Generate home-manager modules
        - `/flake-update` — Safely update flake inputs
        
        ## System Information
        
        Refer to the AGENTS.md and README.md in the root of the dotfiles repo for:
        - System architecture and module organization
        - Multi-host configuration patterns
        - Secrets management (agenix on NixOS, env vars on Ubuntu)
      '';
    };
    
    # 5. Create basic extensions directory structure
    home.file."${cfg.extensionsPath}/.gitkeep".text = "";
    
    # 6. Create basic skills directory structure
    home.file."${cfg.skillsPath}/.gitkeep".text = "";
    
    # 7. Install pi packages (runs after home setup completes)
    home.activation.piPackages = lib.hm.dag.entryAfter [ "linkGeneration" ] (
      lib.optionalString (cfg.piPackages != []) (
        let
          piCmd = "${cfg.package}/bin/pi";
          installCmd = pkg: ''echo "Installing pi package: ${pkg}" && ${piCmd} install ${pkg} 2>/dev/null || echo "Note: Run 'pi install ${pkg}' manually if needed"'';
        in
          if cfg.package != null then
            "export HOME=${config.home.homeDirectory}\n" +
            lib.concatMapStringsSep "\n" installCmd cfg.piPackages
          else
            "# pi-coding-agent not available in this package set, skipping package installation\n" +
            "# Install packages manually with: pi install ${lib.concatMapStringsSep " " (p: p) cfg.piPackages}"
      )
    );
    
    # 8. Informational message if pi-coding-agent not found
    warnings = lib.optionals (cfg.package == null) [
      "pi-dev: pi-coding-agent package not found in nixpkgs. Install via: npm install -g @earendil-works/pi-coding-agent"
    ];
  };
}
