{pkgs, config, ...}: {
  imports = [
    ../../home
    ../../home/pi-dev.nix
  ];

  home.username = "tobi";
  home.homeDirectory = "/home/tobi";
  home.stateVersion = "24.11";

  # Enable Pi coding agent
  home.pi-dev = {
    enable = true;
    nodeVersion = "24";
    theme = "dark";
    thinkingLevel = "medium";
    piPackages = [
      "npm:@juicesharp/rpiv-ask-user-question"
    ];
  };

  programs.home-manager.enable = true;

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
      "*" = {
        addKeysToAgent = "yes";
      };
      "github-tobiornot2b" = {
        hostname = "github.com";
        identityFile = "~/.ssh/tobiornot2b_github";
        addKeysToAgent = "yes";
      };
    };
  };
  services.ssh-agent.enable = true;

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "tobiornot2b";
        email = "pgpg.toby@gmail.com";
      };
    };
  };

  services.syncthing = {
    enable = true;
  };

  # Create a symlink so the files can be changed without running home-manager again
  # Must run before home-manager tries to create the directory
  home.activation.linkNvimConfig = 
    let
      nvimDir = "/home/tobi/.dotfiles/config/nvim";
      configDir = "${config.home.homeDirectory}/.config/nvim";
    in
      config.lib.dag.entryBefore ["writeBoundary"] ''
        # Remove the symlink or directory if it exists
        if [ -L "${configDir}" ] || [ -d "${configDir}" ]; then
          rm -rf "${configDir}"
        fi
        mkdir -p "$(dirname \"${configDir}\")"
        ln -s "${nvimDir}" "${configDir}"
      '';

}
