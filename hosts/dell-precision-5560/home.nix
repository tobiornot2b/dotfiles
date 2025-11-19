{pkgs, ...}: {
  imports = [
    ../../home
  ];

  home.username = "tobi";
  home.homeDirectory = "/home/tobi";
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
