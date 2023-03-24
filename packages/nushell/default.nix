{ stdenv
, lib
, fetchFromGitHub
, fetchpatch
, runCommand
, rustPlatform
, openssl
, zlib
, zstd
, pkg-config
, python3
, xorg
, libiconv
, nghttp2
, libgit2
, withExtraFeatures ? true
, testers
, nushell
, nix-update-script
}:

rustPlatform.buildRustPackage rec {
  pname = "nushell";
  version = "0.77.1";

  src = fetchFromGitHub {
    owner = pname;
    repo = pname;
    rev = version;
    sha256 = "sha256-MheKGfm72cxFtMIDj8VxEN4VFB1+tLoj+ujzL/7n8YI=";
  };

  cargoSha256 = "sha256-oUeoCAeVP2MBAhJfMptK+Z3n050cqpIIgnUroRVBYjg=";

  nativeBuildInputs = [ pkg-config ]
    ++ lib.optionals (withExtraFeatures && stdenv.isLinux) [ python3 ];

  buildInputs = [ openssl zstd ] ++ lib.optionals (withExtraFeatures && stdenv.isLinux) [ xorg.libX11 ];

  buildFeatures = lib.optional withExtraFeatures "extra";

  checkPhase = ''
    runHook preCheck
    echo "Running cargo test"
    HOME=$TMPDIR cargo test
    runHook postCheck
  '';

  meta = with lib; {
    description = "A modern shell written in Rust";
    homepage = "https://www.nushell.sh/";
    license = licenses.mit;
    maintainers = with maintainers; [ Br1ght0ne johntitor marsam ];
    mainProgram = "nu";
  };

  passthru = {
    shellPath = "/bin/nu";
    tests.version = testers.testVersion {
      package = nushell;
    };
    updateScript = nix-update-script { };
  };
}
