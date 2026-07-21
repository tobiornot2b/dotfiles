{ pkgs, ... }: {


      users.users."tobias.taschenberger".home = "/Users/tobias.taschenberger";
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages = with pkgs;
        [ 
          vim
          git
        ];

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = [ "nix-command flakes" ];

      system.primaryUser = "tobias.taschenberger";
      system.defaults.NSGlobalDomain = {
        # Disable automatic spell correction
	NSAutomaticSpellingCorrectionEnabled = false;

	# Disable automatic capitalization
	NSAutomaticCapitalizationEnabled = false;

	# Disable automatic dash substitution
	NSAutomaticDashSubstitutionEnabled = false;

	# Disable automatic period substitution
	NSAutomaticPeriodSubstitutionEnabled = false;

	# Disable automatic quote substitution
	NSAutomaticQuoteSubstitutionEnabled = false;

	# Enable key repeat instead of press-and-hold character popup
	ApplePressAndHoldEnabled = false;
      };

      # Enable alternative shell support in nix-darwin.
      # programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      # system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
}
