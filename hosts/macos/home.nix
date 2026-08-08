{pkgs, config, ...}: {
  imports = [
    ../../home/core.nix
    ../../home/ai.nix
    ../../home/shell
    ../../home/neovim/default.nix
  ];

  home.file.".aerospace.toml".source = ./aerospace.toml;

  home.username = "tobias.taschenberger";
  home.homeDirectory = "/Users/tobias.taschenberger";
  home.stateVersion = "24.11";

  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "tobiornot2b";
        email = "pgpg.toby@gmail.com";
      };
    };
  };

  # Out-of-store symlink so nvim config can be edited without rebuilding.
  # home-manager owns this symlink itself, so it won't conflict with
  # programs.neovim's own managed files under .config/nvim.
  xdg.configFile."nvim".source =
    config.lib.file.mkOutOfStoreSymlink "/Users/tobias.taschenberger/.dotfiles/config/nvim";
}
