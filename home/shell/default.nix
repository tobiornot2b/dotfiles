{ config, pkgs, ...}:

{
  imports = [
    ./atuin.nix
  ];

  programs.bash = {
    enable = false;
    shellAliases = {
      ll = "ls -l";
      ".." = "cd ..";
    };
  };

  programs.zsh = {
    enable = true;
    oh-my-zsh = {
      enable = true;
    };
    shellAliases = {
      ll = "ls -l";
      ".." = "cd ..";
    };
  };
}
