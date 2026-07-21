{ pkgs, ... }: {
  homebrew.enable = true;
  homebrew.onActivation.autoUpdate = true;
  homebrew.onActivation.upgrade = true;

  homebrew.casks = [
    "ghostty"
    "raycast"
  ];
}
