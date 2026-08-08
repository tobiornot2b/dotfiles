{ config, pkgs, ... }:

{
  imports = [
    ../../home/core.nix
  ];
  # Minimal home manager configuration for server
  home.stateVersion = "24.11";
}
