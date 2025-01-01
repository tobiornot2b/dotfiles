{lib, config, pkgs, ...}: 
with lib; let 
  cfg = config.my.desktop.sway;
in {
  options.my.desktop.sway = {
    enable = mkEnableOption "sway desktop";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      grim # screenshot functionatily
      slurp # screenshot functionality
      wl-clipboard # wl-copy and wl-paste for copy/paste from stdin / stdout
      mako # notification system developed by swaywm maintainer
    ];

    # Needed for sway
    security.polkit.enable = true;
    # Enable the gnome-keyring secrets vault.
    # Will be exposed through DBus to programs willing to store secrets
    services.gnome.gnome-keyring.enable = true;
    programs.sway = {
      enable = true;
      wrapperFeatures.gtk = true;
    };

    services.xserver.enable = true;
    services.xserver.displayManager.gdm.enable = true;
    services.xserver.desktopManager.gnome.enable = true;
  };
}
