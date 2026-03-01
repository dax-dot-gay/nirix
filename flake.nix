{
    description = "A more modular and maintainable alternative to niri-flake";

    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
        home-manager = {
            url = "github:nix-community/home-manager";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        niri-unstable-blur = {
            url = "github:niri-wm/niri/wip/branch";
            inputs.nixpkgs.follows = "nixpkgs";

            # https://github.com/niri-wm/niri/blob/2dc6f4482c4eeed75ea8b133d89cad8658d38429/flake.nix#L8-L9
            inputs.rust-overlay.follows = "";
        };
        niri-unstable = {
            url = "github:niri-wm/niri";
            inputs.nixpkgs.follows = "nixpkgs";
        };
    };

    outputs =
        { self, nixpkgs, home-manager, ... }@inputs:
        let
            inherit (nixpkgs) lib;
            lib' = import ./lib { inherit self nixpkgs lib; };
        in
        {
            lib = lib';
            nixosModules = {
                nirix = ./modules/nixos.nix;
                default = self.nixosModules.nirix;
            };
            homeModules = {
                nirix = lib.modules.importApply ./modules/home { inherit self; };
                default = self.homeModules.nirix;
            };
        };
}
