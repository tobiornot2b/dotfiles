{pkgs, config, ...}: 

let
  wg-toggle = pkgs.writeShellScriptBin "wg-toggle" ''
    INTERFACE="wg0"
    if sudo wg show "$INTERFACE" &>/dev/null; then
      sudo wg-quick down "$INTERFACE"
    else
      sudo wg-quick up "$INTERFACE"
    fi
  '';
  wg-status = pkgs.writeShellScriptBin "wg-status" ''
    if sudo wg show wg0 &>/dev/null; then
      echo "<fc=#98be65><fn=1>$(printf '\uf132')</fn></fc>"
    else
      echo "<fc=#ff6c6b><fn=1>$(printf '\uf132')</fn></fc>"
    fi
  '';
  kb-toggle = pkgs.writeShellScriptBin "kb-toggle" ''
    VARIANT=$(setxkbmap -query | awk '/variant/{print $2}')
    if [ "$VARIANT" = "intl" ]; then
      setxkbmap us
    else
      setxkbmap us -variant intl
    fi
  '';
  kb-status = pkgs.writeShellScriptBin "kb-status" ''
    VARIANT=$(setxkbmap -query | awk '/variant/{print $2}')
    if [ "$VARIANT" = "intl" ]; then
      echo "<fc=#82AAFF>US-intl</fc>"
    else
      echo "<fc=#c792ea>US</fc>"
    fi
  '';
in
{
  imports = [
    ../../home/core.nix
    ../../home/chromium.nix
    ../../home/spotify.nix
    ../../home/rofi/default.nix
    ../../home/shell/default.nix
    ../../home/neovim/default.nix
  ];

  home.packages = with pkgs; [
    wg-toggle
    wg-status
    kb-toggle
    kb-status
    kind
    picom # needed compositor for xmonad
    dbeaver-bin
    jetbrains.idea
    maim # screenshot utility
    nodejs_24
    clipcat # clipboard manager
    dunst
    logseq
    bruno
    syncthing
  ];

  home.username = "dwp7953";
  home.homeDirectory = "/home/dwp7953";
  home.stateVersion = "23.11";

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Tobias Maede";
        email = "tobias.maede.ext@dwpbank.de";
      };
    };
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


  # Create a symlink so the files can be changed without running home-manager again
  # Path needs to be absolute to be working
  home.file.".config/nvim".source = config.lib.file.mkOutOfStoreSymlink "/home/dwp7953/.dotfiles/config/nvim";
}
