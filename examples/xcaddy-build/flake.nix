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

              mkdir -p $out/bin
              cp caddy $out/bin
            '';

            # Fixed derivation with hash
            outputHashMode = "recursive";
            outputHash = "sha256-00wMN9c1AEXefvSi6JItYybG6PKZaRKoc3fSU2JyWzI=";
            outputHashAlgo = "sha256";
          };
          default = pkgs.symlinkJoin {
            pname = "caddy";
            inherit version;
            paths = [ xcaddy pkgs.caddy ];
          };
        };
      });
}