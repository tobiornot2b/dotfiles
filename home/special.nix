
{ config, pkgs, ...}:
{
  programs.alacritty = {
    enable = true;
    settings = {
      font = {
        normal = {
          family = "JetBrains Mono";
          style = "Regular";
        };
        size = 12.0;
      };
    };
  };

  programs.firefox = {
    enable = true;
  };

  programs.xmobar.enable = true;
}
