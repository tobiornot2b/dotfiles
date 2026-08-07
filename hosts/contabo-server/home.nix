{ config, pkgs, ... }:

{
  imports = [
    ../../home
  ];
  # Minimal home manager configuration for server
  # Root user has minimal customization
  home.stateVersion = "24.11";
  
}
