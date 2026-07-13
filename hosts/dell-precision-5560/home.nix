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
  # Path needs to be absolute to be working
  home.file.".config/nvim".source = config.lib.file.mkOutOfStoreSymlink "/home/tobi/.dotfiles/config/nvim";
}
