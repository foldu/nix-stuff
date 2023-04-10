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
    blocklistdownloadthing = {
      url = "github:foldu/blocklistdownloadthing";
      inputs = {
        crane.follows = "crane";
        nixpkgs.follows = "nixpkgs";
      };
    };
  };

  outputs = { self, nixpkgs, flake-utils, eunzip, blocklistdownloadthing, ... }: {
    nixosModules = { };
  } // (flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
      nuScript = import ./packages/nu-script.nix { inherit pkgs; lib = nixpkgs.lib; };
      myPackages = nixpkgs.lib.foldl (acc: x: acc // x.packages.${system}) { } [
        eunzip
        blocklistdownloadthing
      ];
    in
    {
      packages = { } // myPackages // nuScript;
    }));
}
