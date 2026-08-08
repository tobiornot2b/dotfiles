{  lib, config, pkgs, ...}:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
    # Don't let home-manager write/manage init.lua — config/nvim is symlinked
    # in from the dotfiles repo directly (see hosts/macos/home.nix).
    sideloadInitLua = true;
  };

  # Plugins like treesitter need an C compiler
  home.packages = lib.optionals config.programs.neovim.enable [
    pkgs.gcc
    pkgs.gnumake
    pkgs.tree-sitter
  ];
}
