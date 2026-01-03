{
  description = "My custom installation of NixOS";

  inputs = {
    # Use the unstable branch for fresher packages (recommended for desktops)
    # Or change to "github:nixos/nixpkgs/nixos-24.11" for stability
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs = {
        # IMPORTANT: we're using "libgbm" and is only available in unstable so ensure
        # to have it up-to-date or simply don't specify the nixpkgs input
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };
  };

  outputs = { self, nixpkgs, home-manager, zen-browser, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      username = "aleh";
      hostname = "nixos";
    in
    {
      nixosConfigurations.${hostname} = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };  # for zen-browser
        modules = [
          ./configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.${username} = import ./home.nix;
            
            # Pass arguments to home.nix
            home-manager.extraSpecialArgs = { inherit username inputs; };
          }
        ];
      };
    };
}
