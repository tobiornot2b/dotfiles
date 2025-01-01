{ config, pkgs, lib, ... }:
with lib; let 
  cfg = config.my.desktop.sway;
in {
  options.my.desktop.sway = {
    enable = mkEnableOption "sway desktop";
  };

  config = mkIf cfg.enable {
    wayland.windowManager.sway = {
      enable = true;
      config = rec {
        modifier = "Mod4";
        window = {
          border = 2;
          titlebar = false;
        };
        output = {
          Virtual-1 = {
            mode = "2048x1152";
          };
        };
        keybindings = let 
            modifier = config.wayland.windowManager.sway.config.modifier;
          in lib.mkOptionDefault {
            "${modifier}+w" = "exec ${pkgs.firefox}/bin/firefox";
          };
      };
    };
};
}
