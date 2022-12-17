{
  description = "Random nix packages and modules";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }: {
    nixosModules = {
      netclient = import./packages/netclient.nix;
    };
  } // (flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
      netclient = pkgs.callPackage ./packages/netclient.nix { };
    in
    {
      packages = {
        inherit netclient;
      };
    }));
}
