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

  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.alacritty = {	
    enable = true;
  };

  programs.firefox = {
    enable = true;
  };

  programs.xmobar.enable = true;

  programs.home-manager.enable = true;

  programs.fzf.enable = true;

  programs.rofi.enable = true;

  xdg.configFile."clipcat/clipcat-menu.toml".text = ''
	server_host = '127.0.0.1'
	server_port = 45045
	finder = 'rofi'

	[rofi]
	line_length = 100
	menu_length = 30

	[dmenu]
	line_length = 100
	menu_length = 30

	[custom_finder]
	program = 'fzf'
	args = []
  '';

  xdg.configFile."clipcat/clipcatctl.toml".text = ''
	server_host = '127.0.0.1'
	server_port = 45045
	log_level = 'INFO'
  '';

  xdg.configFile."clipcat/clipcatd.toml".text = ''
	daemonize = true
	max_history = 50
	history_file_path = '/home/tobi/.cache/clipcat/clipcatd/db'
	log_level = 'INFO'

	[monitor]
	load_current = true
	enable_clipboard = true
	enable_primary = true

	[grpc]
	host = '127.0.0.1'
	port = 45045
  '';
}
