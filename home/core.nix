{ config, pkgs, ...}:

{
  programs.tmux = {
    enable = true;
    keyMode = "vi";
    mouse = true;
    historyLimit = 50000;
    escapeTime = 0;
    baseIndex = 1;

    extraConfig = ''
      set -g renumber-windows on
      set -g pane-base-index 1

      bind c new-window -c "#{pane_current_path}"
      bind % split-window -h -c "#{pane_current_path}"
      bind '"' split-window -v -c "#{pane_current_path}"
    '';
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
