
{ config, pkgs, ...}:

{
  programs.alacritty = {
    enable = true;
  };

  programs.firefox = {
    enable = true;
  };

  programs.xmobar.enable = true;

}
