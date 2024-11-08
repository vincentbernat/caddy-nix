final: prev: rec {
  caddy = prev.caddy.overrideAttrs (oldAttrs: {
    passthru = (oldAttrs.passthru or { }) // {
      withModules =
        { modules
        , hash ? prev.lib.fakeHash
        ,
        }: caddy.overrideAttrs (oldAttrs: {
          vendorHash = null;
          subPackages = [ "." ];
          src = prev.stdenv.mkDerivation rec {
            pname = "caddy-src-with-xcaddy";
            version = final.caddy.version;

            nativeBuildInputs = [
              prev.go
              prev.xcaddy
            ];
            unpackPhase = "true";
            buildPhase =
              let
                withArgs = prev.lib.concatMapStrings (module: "--with ${module} ") modules;
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
        });
    };
  });
}
