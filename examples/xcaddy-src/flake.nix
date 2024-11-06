{
  description = "Fetch sources with xcaddy";
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
            pname = "caddy-src-with-xcaddy";
            inherit version;

            # Build with xcaddy
            nativeBuildInputs = [
              pkgs.go
            ];
            unpackPhase = "true";
            buildPhase =
              let
                withArgs = pkgs.lib.concatMapStrings (module: "--with ${module} ") modules;
              in
              ''
                XCADDY_SKIP_BUILD=1 ${pkgs.xcaddy}/bin/xcaddy build v${version} ${withArgs}
                (cd buildenv* && go mod vendor)
              '';
            installPhase = ''
              mv buildenv* $out
            '';

            # Fixed derivation with hash
            outputHashMode = "recursive";
            outputHash = "sha256-F/jqR4iEsklJFycTjSaW8B/V3iTGqqGOzwYBUXxRKrc=";
            outputHashAlgo = "sha256";
          };
          default = pkgs.caddy.overrideAttrs (prev: {
            src = xcaddy;
            vendorHash = null;
            subPackages = [ "." ];
          });
        };
      });
}
