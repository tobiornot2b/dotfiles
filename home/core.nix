{ config, pkgs, ...}:

{
  programs.tmux.enable = true;

  programs.alacritty = {	
    enable = true;
  };

  programs.ghostty = {
    enable = true;
    package = pkgs.ghostty;
  };

  programs.yazi = {
    enable = true;
  };

  # programs.xmobar.enable = true;

  programs.fzf.enable = true;

  programs.ripgrep.enable = true;

  programs.lazygit.enable = true;

  programs.vscode.enable = true;

  programs.ranger.enable = true;
}
