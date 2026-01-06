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

    caelestia-shell = {
      url = "github:caelestia-dots/shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sysc-greet = {
      url = "github:Nomadcxx/sysc-greet";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    zen-browser,
    caelestia-shell,
    sysc-greet,
    nixvim,
    ... }@inputs:
    let
      system = "x86_64-linux";
      username = "aleh";
    in
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs self; enableNvidia = true; hostname = "nixos"; };
        modules = [
          ./configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.${username} = import ./home.nix;

            home-manager.extraSpecialArgs = { inherit username inputs self caelestia-shell nixvim; };
          }
          sysc-greet.nixosModules.default
        ];
      };

      nixosConfigurations.nixos-intel = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs self; enableNvidia = false; hostname = "nixos-intel"; };
        modules = [
          ./configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.${username} = import ./home.nix;

            home-manager.extraSpecialArgs = { inherit username inputs self caelestia-shell nixvim; };
          }
          sysc-greet.nixosModules.default
        ];
      };
    };
}
