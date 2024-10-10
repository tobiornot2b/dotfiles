{ config, pkgs, ...}:

{
  programs.tmux.enable = true;

  programs.alacritty = {	
    enable = true;
  };

  programs.firefox = {
    enable = true;
  };

  programs.xmobar.enable = true;

  programs.fzf.enable = true;

  programs.rofi.enable = true;

  programs.ripgrep.enable = true;
}
