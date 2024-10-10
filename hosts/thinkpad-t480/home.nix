{pkgs, ...}: {
  imports = [
    ../../home/core.nix
    ../../home/clipcat.nix

    ../../home/shell
  ];

  home.username = "tobi";
  home.homeDirectory = "/home/tobi";
  home.stateVersion = "23.11";

  programs.home-manager.enable = true;

  programs.git = {
    userName = "tobiornot2b";
    userEmail = "tobias.maede@gmail.com";
  };
}