{ config, pkgs, ... }:

{
  imports = [
    ../../home/core.nix
    ../../home/gh.nix
  ];
  # Minimal home manager configuration for server
  home.stateVersion = "24.11";

  programs.git = {
    enable = true;
    settings.user = {
      name = "tobiornot2b";
      email = "pgpg.toby@gmail.com";
    };
  };
}
