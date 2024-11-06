{ lib
, pkgs
, modules ? [ ]
, hash ? lib.fakeHash
, caddy ? pkgs.caddy
, version ? args'.caddy.version
}@args': caddy.overrideAttrs (old: {
  vendorHash = null;
  subPackages = [ "." ];
  src = pkgs.stdenv.mkDerivation rec {
    pname = "caddy-src-with-xcaddy";
    inherit version;

    nativeBuildInputs = [
      pkgs.go
      pkgs.xcaddy
    ];
    unpackPhase = "true";
    buildPhase =
      let
        withArgs = pkgs.lib.concatMapStrings (module: "--with ${module} ") modules;
      in
      ''
        export GOCACHE=$TMPDIR/go-cache
        export GOPATH="$TMPDIR/go"
        XCADDY_SKIP_BUILD=1 xcaddy build v${version} ${withArgs}
        (cd buildenv* && go mod vendor)
      '';
    installPhase = ''
      mv buildenv* $out
    '';

    # Fixed derivation with hash
    outputHashMode = "recursive";
    outputHash = hash;
    outputHashAlgo = "sha256";
  };
})
