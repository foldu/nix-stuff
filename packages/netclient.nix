{ lib
, fetchFromGitHub
, buildGo118Module
, makeWrapper
, wireguard-tools
, sysctl
, nftables
, iproute2
}:

let
  version = "0.17.0";
in
buildGo118Module {
  pname = "netclient";
  version = version;
  src = fetchFromGitHub {
    owner = "gravitl";
    repo = "netmaker";
    rev = "v${version}";
    sha256 = "sha256-9ybiE1QIojX7dc5FSvWqOeDo+UVOZJ8pGiSYDZH7rHk=";
  };
  ldflags = [
    "-X"
    "main.version=v${version}"
  ];
  nativeBuildInputs = [ makeWrapper ];
  postInstall =
    let
      binPath = lib.strings.makeBinPath [ wireguard-tools sysctl nftables iproute2 ];
    in
    ''
      wrapProgram $out/bin/netclient --prefix PATH : "${binPath}"
    '';
  subPackages = [ "netclient" ];
  vendorSha256 = "sha256-4LaGwwDu3pKd6I6r/F3isCi9CuFqPGvc5SdVTV34qOI=";
}
