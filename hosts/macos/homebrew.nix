{ pkgs, ... }: {
  homebrew.enable = true;
  homebrew.enableZshIntegration = true;
  homebrew.onActivation.autoUpdate = true;
  homebrew.onActivation.upgrade = true;

  homebrew.taps = [
    {
      name = "nikitabobko/tap";
      trusted = true;
    }
  ];

  homebrew.brews = [
    # For podman the following commands need to be run for setup:
    # podman machine init
    # podman machine start
    "podman"
    "podman-compose"
  ];

  homebrew.casks = [
    "aerospace"
    "ghostty"
    "raycast"
  ];
}
