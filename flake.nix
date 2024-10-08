{
  description = "NixOS Setup from tobi";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-23.11";
    home-manager.url = "github:nix-community/home-manager/release-23.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    xmonad-contrib.url = "github:xmonad/xmonad-contrib/v0.18.0";
    agenix.url = "github:ryantm/agenix";
  };

  outputs = { self, nixpkgs, home-manager, xmonad-contrib, agenix, ... }:
    let 
      lib = nixpkgs.lib;
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
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
              home-manager.users.tobi = import ./home.nix;
            }
         ] ++ xmonad-contrib.nixosModules ++ [
           xmonad-contrib.modernise.${system}
         ];
      };
    };
  };
}
