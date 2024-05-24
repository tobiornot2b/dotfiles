{ config, pkgs, ...}:

{
  home.username = "tobi";
  home.homeDirectory = "/home/tobi";
  home.stateVersion = "23.11";

  programs.bash = {
    enable = true;
    shellAliases = {
      ll = "ls -l";
      ".." = "cd ..";
    };
  };

  programs.zsh = {
    enable = true;
    shellAliases = {
      ll = "ls -l";
      ".." = "cd ..";
    };
  };

  programs.tmux.enable = true;

  programs.alacritty = {	
    enable = true;
  };

  programs.firefox = {
    enable = true;
  };

  programs.xmobar.enable = true;

  programs.home-manager.enable = true;
}
