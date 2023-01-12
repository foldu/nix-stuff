{
  description = "Random nix packages and modules";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }: {
    nixosModules = {
      netclient = import ./modules/netclient.nix;
    };
  } // (flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      lib = import ./lib/nu-script.nix { inherit pkgs; lib = nixpkgs.lib; };
      packages = {
        netclient = pkgs.callPackage ./packages/netclient.nix { };
        nushell = pkgs.callPackage ./packages/nushell { };
      };
    }));
}
