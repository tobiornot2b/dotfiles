{pkgs, config, ...}: {
  imports = [
    ../../home/core.nix
    ../../home/ai.nix
    ../../home/shell
    ../../home/neovim/default.nix
  ];

  home.file.".aerospace.toml".source = ./aerospace.toml;

  home.username = "tobias.taschenberger";
  home.homeDirectory = "/Users/tobias.taschenberger";
  home.stateVersion = "24.11";

  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "tobiornot2b";
        email = "pgpg.toby@gmail.com";
      };
    };
  };

  # Create a symlink so the files can be changed without running home-manager again
  # Must run before home-manager tries to create the directory
  home.activation.linkNvimConfig = 
    let
      nvimDir = "/Users/tobias.taschenberger/.dotfiles/config/nvim";
      configDir = "${config.home.homeDirectory}/.config/nvim";
    in
      config.lib.dag.entryBetween ["preActivationVariables"] ["preActivation"] ''
        # Remove the symlink or directory if it exists
        if [ -L "${configDir}" ] || [ -d "${configDir}" ]; then
          rm -rf "${configDir}"
        fi
        mkdir -p "$(dirname \"${configDir}\")"
        ln -s "${nvimDir}" "${configDir}"
      '';
}
