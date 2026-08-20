{ config, pkgs, ...}:

{
  fonts.fontconfig.enable = true;

  programs.alacritty = {
    enable = true;
    package = null;
    settings = {
      font = {
        normal = {
          family = "JetBrainsMono Nerd Font Mono";
          style = "Regular";
        };
        size = 12.0;
      };
    };
  };

  programs.vscode.enable = true;

  programs.zathura.enable = true;
}
