{ config, pkgs, ... }:
{
  wayland.windowManager.hyprland = {
    enable = true;
    package = pkgs.hyprland;
    systemd = {
      enable = true;
      enableXdgAutostart = true;
      variables = ["--all"];
    };
    xwayland = {
      enable = true;
    };
    settings = {
      exec-once = [
        "waybar"
      ];

      bind = [
        "SUPER,RETURN,exec,ghostty"
        "SUPER,Q,killactive"
        "SUPER,W,exec,firefox"
        "SUPER,Y,exec,ghostty -e yazi"
        "SUPER SHIFT,h,movewindow,l"
        "SUPER SHIFT,l,movewindow,r"
        "SUPER SHIFT,k,movewindow,u"
        "SUPER SHIFT,j,movewindow,d"
        "SUPER,h,movefocus,l"
        "SUPER,l,movefocus,r"
        "SUPER,k,movefocus,u"
        "SUPER,j,movefocus,d"
        "SUPER,1,workspace,1"
        "SUPER,2,workspace,2"
        "SUPER,3,workspace,3"
        "SUPER,4,workspace,4"
        "SUPER,5,workspace,5"
        "SUPER,6,workspace,6"
        "SUPER,7,workspace,7"
        "SUPER,8,workspace,8"
        "SUPER,9,workspace,9"
        "SUPER,0,workspace,10"
        "SUPER  SHIFT,1,movetoworkspace,1"
        "SUPER  SHIFT,2,movetoworkspace,2"
        "SUPER  SHIFT,3,movetoworkspace,3"
        "SUPER  SHIFT,4,movetoworkspace,4"
        "SUPER  SHIFT,5,movetoworkspace,5"
        "SUPER  SHIFT,6,movetoworkspace,6"
        "SUPER  SHIFT,7,movetoworkspace,7"
        "SUPER  SHIFT,8,movetoworkspace,8"
        "SUPER  SHIFT,9,movetoworkspace,9"
        "SUPER  SHIFT,0,movetoworkspace,10"
      ];
      env = [
        "NIXOS_OZONE_WL, 1"
        "WLR_DRM_DEVICES,/dev/dri/card1" # use Intel Graphics
        "NIXPKGS_ALLOW_UNFREE, 1"
        "XDG_CURRENT_DESKTOP, Hyprland"
        "XDG_SESSION_TYPE, wayland"
        "XDG_SESSION_DESKTOP, Hyprland"
        "GDK_BACKEND, wayland, x11"
        "CLUTTER_BACKEND, wayland"
        "QT_QPA_PLATFORM=wayland;xcb"
        "QT_WAYLAND_DISABLE_WINDOWDECORATION, 1"
        "QT_AUTO_SCREEN_SCALE_FACTOR, 1"
        "SDL_VIDEODRIVER, x11"
        "MOZ_ENABLE_WAYLAND, 1"
        "GDK_SCALE,1"
        "QT_SCALE_FACTOR,1"
        "EDITOR,vim"
      ];
  
      animations = {
        enabled = false;
      };
  
    };
  
    extraConfig = "
        monitor=eDP-1,1920x1200@60,0x0,1
    ";
  };
}
