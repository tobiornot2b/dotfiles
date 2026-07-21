{pkgs, config, ...}: {
  imports = [
    ../../home/ai.nix
  ];

  home.username = "tobias.taschenberger";
  home.homeDirectory = "/Users/tobias.taschenberger";
  home.stateVersion = "24.11";

  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "tobiornot2b";
        email = "pgpg.toby@gmail.com";
      };
    };
  };
}
