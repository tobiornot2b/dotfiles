{ config, pkgs, ...}:

{
  programs.tmux = {
    enable = true;
    keyMode = "vi";
    mouse = true;
  };

  programs.fzf = {
    enable = true;
    historyWidget.zsh.command = "";
  };

  programs.fd.enable = true;

  programs.ripgrep.enable = true;

  programs.lazygit.enable = true;

  programs.yazi = {
    enable = true;
    shellWrapperName = "y";
  };

  programs.zoxide.enable = true;

  programs.k9s.enable = true;

  programs.numbat.enable = true;
}
