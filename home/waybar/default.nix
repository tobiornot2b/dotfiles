{ config, pkgs, ...}:
{
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        mode = "dock";
        reload_style_on_change = true;
        modules-left = [
          "hyprland/workspaces"
          "hyprland/window"
        ];
	modules-center = [
	  "clock#time"
	  "clock#date"
	];
	modules-right = [
	  "mpris"
	  "memory"
	  "cpu"
	  "backlight"
	  "battery"
	  "pulseaudio"
	];

	"hyprland/workspaces" = {
          on-scroll-up = "hyprctl dispatch workspace -1";
          on-scroll-down = "hyprctl dispatch workspace +1";
          persistent-workspaces = {
            "1" = [];
            "2" = [];
            "3" = [];
            "4" = [];
            "5" = [];
          };
        };

      "hyprland/window" = {
          swap-icon-label = false;
          format = "{}";
          tooltip = false;
          min-length = 5;
          rewrite = {
            "" = "<span foreground='#89b4fa'> </span> Hyprland";
            "~" = " Terminal";
            "zsh" = " Terminal";
            "kitty" = " Terminal";
            "tmux(.*)" = "<span foreground='#a6e3a1'> </span> Tmux";
            "(.*)Mozilla Firefox" = "<span foreground='#f38ba8'>  </span> Firefox";
            "(.*) - Visual Studio Code" = "<span foreground='#89b4fa'>󰨞 </span> $1";
            "(.*)Visual Studio Code" = "<span foreground='#89b4fa'>󰨞 </span> Visual Studio Code";
            "nvim" = "<span foreground='#a6e3a1'> </span> Neovim";
            "nvim (.*)" = "<span foreground='#a6e3a1'> </span> $1";
            "(.*)Spotify" = "<span foreground='#a6e3a1'> </span> Spotify";
            "(.*)Spotify Premium" = "<span foreground='#a6e3a1'> </span> Spotify Premium";
            "(.*) - mpv" = "<span foreground='#cba6f7'> </span> $1";
          };
        };

       "clock#time" = {
          format = "{:%H:%M}";
          tooltip = false;
          min-length = 6;
          max-length = 6;
        };

        "clock#date" = {
          format = "󰸗 {:%m-%d}";
          "tooltip-format" = "<tt>{calendar}</tt>";
          calendar = {
            mode = "month";
            "mode-mon-col" = 6;
            "on-click-right" = "mode";
            format = {
              months = "<span color='#b4befe'><b>{}</b></span>";
              weekdays = "<span color='#a6adc8' font='7'>{}</span>";
              today = "<span color='#f38ba8'><b>{}</b></span>";
            };
          };
          actions = {
            "on-click" = "mode";
            "on-click-right" = "mode";
          };
          min-length = 8;
          max-length = 8;
        };
      };
    };

    style = ''
      * {
        font-family: "JetBrainsMono Nerd Font";
	font-size: 14px;
      }

      window#waybar {
  background-color: rgba(30, 30, 46, 0.8);
}

#workspaces button.active {
  background-color: #89b4fa;
  color: #1e1e2e;
}
    '';
  };
}
