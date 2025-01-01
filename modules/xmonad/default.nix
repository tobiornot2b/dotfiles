{lib, config, pkgs, ...}: 
with lib; let 
  cfg = config.my.desktop.xmonad;
in {
  options.my.desktop.xmonad = {
    enable = mkEnableOption "xmonad desktop";
  };

  config = mkIf cfg.enable {
    services.xserver = {
      enable = true;
      xkb = {
        layout = "us";
        variant = "";
      };
      desktopManager = {
        xterm.enable = true;
        xfce = {
          enable = true;
          noDesktop = true;
          enableXfwm = false;
        };
      };
      windowManager.xmonad = {
        enable = true;
        enableContribAndExtras = true;
        flake = {
          enable = true;
          compiler = "ghc947";
        };
        extraPackages = haskellPackages : [
          haskellPackages.xmonad-contrib
          haskellPackages.xmonad-extras
          haskellPackages.xmonad
        ];
        config = builtins.readFile ./xmonad.hs;
        enableConfiguredRecompile = true;
      };
    };
  };
}
