{  lib, config, pkgs, ...}:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
  };

  # Plugins like treesitter need an C compiler
  home.packages = lib.optionals config.programs.neovim.enable [
    pkgs.gcc
    pkgs.gnumake
  ];
}
