
{ config, pkgs, ...}:
{
  programs.firefox = {
    enable = true;
  };

  programs.xmobar.enable = true;
}
