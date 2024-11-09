final: prev: rec {
  caddy = prev.caddy.overrideAttrs (oldAttrs: {
    passthru = (oldAttrs.passthru or { }) // {
      withPlugins =
        { plugins
        , hash ? prev.lib.fakeHash
        ,
        }:
        let
          version = final.caddy.version;
        in
        caddy.overrideAttrs (oldAttrs: {
          vendorHash = null;
          subPackages = [ "." ];
          src = prev.stdenv.mkDerivation {
            pname = "caddy-src-with-xcaddy";
            inherit version;

            nativeBuildInputs = [
              prev.go
              prev.xcaddy
            ];
            unpackPhase = "true";
            buildPhase =
              let
                withArgs = prev.lib.concatMapStrings (plugin: "--with ${plugin} ") plugins;
              in
              ''
                export GOCACHE=$TMPDIR/go-cache
                export GOPATH="$TMPDIR/go"
                XCADDY_SKIP_BUILD=1 xcaddy build v${version} ${withArgs}
                (cd buildenv* && go mod vendor)
              '';
            installPhase = ''
              mv buildenv* $out
              echo "v${version}" > $out/version
            '';

            # Fixed derivation with hash
            outputHashMode = "recursive";
            outputHash = hash;
            outputHashAlgo = "sha256";
          };
          # As we rely on pkgs.caddy, which version may change on upgrades, we
          # may silently reuse the previous version because the above derivation
          # would be cached. The check below is a workaround to avoid that and
          # ensure the version we want was really the one built. This is a
          # common problem with Nix. See: https://github.com/NixOS/nix/issues/7999.
          postCheck = (oldAttrs.postCheck or "") + ''
            [ "$(cat version)" = "v${version}" ] || {
              echo "Mismatched version $(cat version) in source, while v${version} requested"
              exit 1
            }
          '';
        });
    };
  });
}
