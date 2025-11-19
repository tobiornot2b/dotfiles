{
  description = "NixOS Setup from tobi";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    xmonad-contrib.url = "github:xmonad/xmonad-contrib/v0.18.0";
    agenix.url = "github:ryantm/agenix";
    disko.url = "github:nix-community/disko";
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, xmonad-contrib, agenix, disko, stylix, ... }@inputs:
    let 
      lib = nixpkgs.lib.extend (self: _: {my = import ./lib {lib = self;};});
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        system = system;
        config.allowUnfree = true;
      };
    in {

    nixosConfigurations = {
      tobi = lib.nixosSystem rec {
         inherit system;
         modules = [
            ./hosts/thinkpad-t480 

            agenix.nixosModules.default
            {
              environment.systemPackages = [ agenix.packages.${system}.default ];
            }
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.tobi = import ./hosts/thinkpad-t480/home.nix;
            }
         ] ++ xmonad-contrib.nixosModules ++ [
           xmonad-contrib.modernise.${system}
         ] ++ [
	    ./modules
         ];
      };

      tobixx = lib.nixosSystem rec {
         inherit system;
         modules = [
	    # Do i need this when i run the disko install on its own?
	    disko.nixosModules.disko
            stylix.nixosModules.stylix
            ./hosts/dell-precision-5560
            agenix.nixosModules.default
            {
              environment.systemPackages = [ agenix.packages.${system}.default ];
            }
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.tobi = import ./hosts/dell-precision-5560/home.nix;
            }
         ];
       };
    };

    homeConfigurations = {
      dwp7953 = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          ./hosts/ubuntu/home.nix
        ];
      };
    };
  };
}
