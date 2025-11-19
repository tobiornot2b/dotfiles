{pkgs, ...}: {
  imports = [
    ../../home/core.nix
    ../../home/shell/default.nix
    ../../home/neovim/default.nix
  ];

  home.packages = with pkgs; [
    kind
    picom # needed compositor for xmonad
    dbeaver-bin
    jetbrains.idea-ultimate
    maim # screenshot utility
    nodejs_20
    clipcat # clipboard manager
    dunst
    logseq
  ];

  home.username = "dwp7953";
  home.homeDirectory = "/home/dwp7953";
  home.stateVersion = "23.11";

  programs.git = {
    userName = "Tobias Maede";
    userEmail = "tobias.maede.ext@dwpbank.de";
  };

  ## Clipcat Config
  home.file.".config/clipcat/clipcatd.toml" = {
    source = ./clipcatd.toml;
  };

  ## Xmonad setup
  home.file.".xmonad/xmonad.hs" = {
    source = ../../modules/xmonad/xmonad.hs;
  };

  home.file.".config/xmobar/xmobarrc" = {
    source = ../../modules/xmonad/xmobarrc;
  };
}
