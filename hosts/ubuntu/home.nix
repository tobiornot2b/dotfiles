{pkgs, ...}: {
  imports = [
    ../../home/core.nix
    ../../home/neovim/default.nix
  ];

  home.packages = with pkgs; [
    kind
  ];

  home.username = "dwp7953";
  home.homeDirectory = "/home/dwp7953";
  home.stateVersion = "23.11";

  programs.git = {
    userName = "Tobias Maede";
    userEmail = "tobias.maede.ext@dwpbank.de";
  };
}
