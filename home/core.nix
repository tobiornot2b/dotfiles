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

      # Tokyo Night Theme Colors (based on tokyonight-night variant)
      # Status bar
      set -g status-style bg='#1a1b26',fg='#c0caf5'
      set -g status-left-length 40
      set -g status-right-length 40
      
      # Status bar left side
      set -g status-left '#[fg=#16161e,bg=#7aa2f7] #S #[default]'
      
      # Status bar right side
      set -g status-right '#[fg=#c0caf5,bg=#16161e] %Y-%m-%d %H:%M #[default]'
      
      # Window status
      set -g window-status-format ' #I:#W '
      set -g window-status-current-format ' #[fg=#16161e,bg=#7aa2f7] #I:#W #[default]'
      
      # Pane border
      set -g pane-border-style fg='#3b4261'
      set -g pane-active-border-style fg='#7aa2f7'
      
      # Message
      set -g message-style bg='#16161e',fg='#c0caf5'
      set -g message-command-style bg='#16161e',fg='#c0caf5'
      
      # Mode
      set -g mode-style bg='#7aa2f7',fg='#1a1b26'
      
      # Status bar clock
      set -g status-right-attr default
      set -g status-left-attr default
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
