{ config, pkgs, ...}:

{
  home.packages = with pkgs; [
    claude-code
  ];

  programs.opencode.enable = true;
}
