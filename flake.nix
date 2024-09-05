{
  description = "Random nix packages and modules";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    crane.url = "github:ipetkov/crane";
    eunzip = {
      url = "github:foldu/eunzip";
      inputs = {
        crane.follows = "crane";
        nixpkgs.follows = "nixpkgs";
      };
    };
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      eunzip,
      ...
    }:
    {
      nixosModules = {
        podman-pods = import ./modules/podman-pods.nix;
      };
    }
    // (flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        nuScript = import ./packages/nu-script.nix {
          inherit pkgs;
          lib = nixpkgs.lib;
        };
        myPackages = nixpkgs.lib.foldl (acc: x: acc // x.packages.${system}) { } [
          eunzip
        ];
      in
      {
        packages = { } // myPackages // nuScript;
      }
    ));
}
