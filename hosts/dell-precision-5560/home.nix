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
    matchBlocks."*" = {
      addKeysToAgent = "yes";
    };
  };

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
  # Using standalone home.activation to bypass home.file management issues
  home.activation.linkNvimConfig = 
    let
      nvimDir = "/home/tobi/.dotfiles/config/nvim";
      configDir = "${config.home.homeDirectory}/.config/nvim";
    in
      config.lib.dag.entryAfter ["writeBoundary"] ''
        rm -rf "${configDir}"
        mkdir -p "$(dirname \"${configDir}\")"        
        ln -s "${nvimDir}" "${configDir}"
      '';

}
