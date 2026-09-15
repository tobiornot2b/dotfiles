{ config, pkgs, ...}:

{
  home.packages = with pkgs; [
    claude-code
    codex
  ];

  programs.opencode.enable = true;
}
