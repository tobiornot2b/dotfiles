{pkgs, ...}: {
  imports = [
    ../../home
  ];

  home.username = "tobi";
  home.homedirectory = "/home/tobi";
  home.stateversion = "23.11";

  programs.home-manager.enable = true;

  programs.git = {
    username = "tobiornot2b";
    useremail = "pgpg.toby@gmail.com";
  };
}
