{pkgs, ...}: {
  imports = [
    ../../home
  ];

  home.username = "tobi";
  home.homeDirectory = "/home/tobi";
  home.stateVersion = "23.11";

  programs.home-manager.enable = true;

  programs.git = {
    userName = "tobiornot2b";
    userEmail = "pgpg.toby@gmail.com";
  };
}
