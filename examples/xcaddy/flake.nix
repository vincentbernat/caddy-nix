{
  description = "Build with xcaddy";
  inputs = {
    nixpkgs.url = "nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
        modules = [ "github.com/caddy-dns/powerdns@v1.0.1" ];
        version = pkgs.caddy.version;
      in
      {
        packages = rec {
          xcaddy = pkgs.stdenv.mkDerivation {
            pname = "caddy-with-xcaddy";
            inherit version;

            # Build with xcaddy
            nativeBuildInputs = [
              pkgs.removeReferencesTo
              pkgs.go
            ];
            unpackPhase = "true";
            buildPhase =
              let
                withArgs = pkgs.lib.concatMapStrings (module: "--with ${module} ") modules;
              in
              ''
                ${pkgs.xcaddy}/bin/xcaddy build v${version} ${withArgs}
              '';
            installPhase = ''
              # This part is likely wrong!
              remove-references-to -t ${pkgs.iana-etc} -t ${pkgs.tzdata} -t ${pkgs.mailcap} caddy

              cp caddy $out
            '';

            # Fixed derivation with hash
            outputHashMode = "recursive";
            outputHash = "sha256-Iu2xx2cXr1KXv9kqX6gDNe4DMnLUcbzPK817leOomJg=";
            outputHashAlgo = "sha256";
          };
          default = pkgs.caddy.overrideAttrs (prev: {
            # This is inefficient, we will have a full rebuild of caddy just to replace it.
            postInstall = (prev.postInstall or "") + ''
              cp ${xcaddy} $out/bin/caddy
            '';
          });
        };
      });
}
