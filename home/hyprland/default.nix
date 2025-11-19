{ config, pkgs, ... }:
{
  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        disable_loading_bar = true;
        grace = 10;
        hide_cursor = true;
        no_fade_in = false;
      };
     
      background = [
        {
          path = "screenshot";
          blur_passes = 3;
          blur_size = 8;
        }
      ];
     
      input-field = [
        {
          size = "200, 50";
          position = "0, -80";
          monitor = "";
          dots_center = true;
          fade_on_empty = false;
          font_color = "rgb(202, 211, 245)";
          inner_color = "rgb(91, 96, 120)";
          outer_color = "rgb(24, 25, 38)";
          outline_thickness = 5;
          placeholder_text = "Password...";
          shadow_passes = 2;
        }
      ];
    };
  };
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
    	"swww-daemon"
        "swww img /home/tobi/Downloads/background.jpg"     
      ];

      input = {
        kb_layout = "us";
        kb_variant = "intl";
      };

      bind = [
        "SUPER,RETURN,exec,alacritty"
        "SUPER,Q,killactive"
        "SUPER,W,exec,firefox"
        "SUPER,P,exec,rofi -show drun"
        "SUPER,ESCAPE,exec,hyprlock"
        "SUPER,E,exec,alacritty -e yazi"
        "SUPER SHIFT, s, exec, grimblast save area"
        "SUPER SHIFT,h,movewindow,l"
        "SUPER SHIFT,l,movewindow,r"
        "SUPER SHIFT,k,movewindow,u"
        "SUPER SHIFT,j,movewindow,d"
        "SUPER,h,movefocus,l"
        "SUPER,l,movefocus,r"
        "SUPER,k,movefocus,u"
        "SUPER,j,movefocus,d"
        "SUPER,F,togglefloating"
        "SUPER ALT,h,resizeactive,-80 0"
        "SUPER ALT,l,resizeactive,80 0"
        "SUPER ALT,k,resizeactive,0 -80"
        "SUPER ALT,j,resizeactive,0 80"
        "SUPER,1,focusworkspaceoncurrentmonitor,1"
        "SUPER,2,focusworkspaceoncurrentmonitor,2"
        "SUPER,3,focusworkspaceoncurrentmonitor,3"
        "SUPER,4,focusworkspaceoncurrentmonitor,4"
        "SUPER,5,focusworkspaceoncurrentmonitor,5"
        "SUPER,6,focusworkspaceoncurrentmonitor,6"
        "SUPER,7,focusworkspaceoncurrentmonitor,7"
        "SUPER,8,focusworkspaceoncurrentmonitor,8"
        "SUPER,9,focusworkspaceoncurrentmonitor,9"
        "SUPER,0,focusworkspaceoncurrentmonitor,10"
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
	"ELECTRON_OZONE_PLATFORM_HINT,auto"
        "MOZ_ENABLE_WAYLAND, 1"
        "GDK_SCALE,1"
        "QT_SCALE_FACTOR,1"
        "EDITOR,vim"
      ];
  
      animations = {
        enabled = false;
      };

      ecosystem = {
        no_donation_nag = true;
        no_update_news = false;
      };

      cursor = {
        sync_gsettings_theme = true;
        no_hardware_cursors = 2; # change to 1 if want to disable
        enable_hyprcursor = false;
        warp_on_change_workspace = 2;
        no_warps = true;
      };

      render = {
        # both options are not supported anymore
        # explicit_sync = 1; # Change to 1 to disable
        # explicit_sync_kms = 1;
        direct_scanout = 0;
      };
  
    };
  
    extraConfig = "
        monitor=eDP-1,1920x1200@60,0x0,1
        monitor=DVI-I-1,2560x1440@60,1920x0,1
        monitor=DVI-I-2,2560x1440@60,4480x0,1
        monitor=DVI-I-3,2560x1440@60,1920x0,1
        monitor=DVI-I-4,2560x1440@60,4480x0,1
        monitor=DP-5,2560x1440@60,1920x0,1
        monitor=DP-6,1920x1200@60,4480x0,1,transform,1
    ";
  };
}
