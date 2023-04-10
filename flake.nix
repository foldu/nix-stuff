{
  description = "Random nix packages and modules";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }: {
    nixosModules = { };
  } // (flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
      nuScript = import ./packages/nu-script.nix { inherit pkgs; lib = nixpkgs.lib; };
    in
    {
      packages = {
        nushell = pkgs.callPackage ./packages/nushell { };
      } // nuScript;
    }));
}
