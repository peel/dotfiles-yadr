{
  description = "peel's env";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-20.09-darwin";
    darwin.url = "github:lnl7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    emacs-overlay.url = "github:nix-community/emacs-overlay";
    emacs-overlay.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";    
  };

  outputs = { self, darwin, nixpkgs, emacs-overlay, ... }@inputs: {
    darwinConfigurations.snowflake = darwin.lib.darwinSystem {
      modules = [
        { nixpkgs.overlays = [ emacs-overlay.overlay ]; }
        ./machines/snowflake/configuration.nix
        # home-manager.nixosModules.home-manager
        #   {
        #     home-manager.useGlobalPkgs = true;
        #     home-manager.useUserPackages = true;
        #     home-manager.users.user = import ./setup/common/home.nix;
        #   }
      ];      
    };
    darwinConfigurations.fff666 = darwin.lib.darwinSystem {
      modules = [
        { nixpkgs.overlays = [ emacs-overlay.overlay ]; }
        ./machines/fff666/configuration.nix
        # home-manager.nixosModules.home-manager
        #   {
        #     home-manager.useGlobalPkgs = true;
        #     home-manager.useUserPackages = true;
        #     home-manager.users.user = import ./setup/common/home.nix;
        #   }
      ];      
    };
    nixosConfigurations.nuke = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
      modules = [
        { nixpkgs.overlays = [ emacs-overlay.overlay ]; }
        ./machines/nuke/configuration.nix
        ./machines/nuke/hardware-configuration.nix
        # home-manager.nixosModules.home-manager
        #   {
        #     home-manager.useGlobalPkgs = true;
        #     home-manager.useUserPackages = true;
        #     home-manager.users.user = import ./setup/common/home.nix;
        #   }
      ];
    };
  };
}
