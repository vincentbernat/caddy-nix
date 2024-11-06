{
  description = "Patch Caddy with modules";
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
        packages = {
          default = pkgs.caddy.overrideAttrs (old: {
            vendorHash = "sha256-ez8lcTJegWTIWcaEVJlqcA+M1DTyXF70U5VI+cOHz8s=";
            prePatch =
              let
                moduleNames = map (module: builtins.elemAt (pkgs.lib.splitString "@" module) 0) modules;
              in
              ''
                # Add modules to main.go
                for module in ${toString moduleNames}; do
                  sed -i "/plug in Caddy modules here/a _ \"$module\"" cmd/caddy/main.go
                done

                # Outside go-modules derivation, copy go.mod and go.sum
                [ -z "$goModules" ] || \
                  cp "$goModules/go.mod" "$goModules/go.sum" .
              '';
            preBuild =
              ''
                # In go-modules derivation, fetch the modules
                [ -n "$goModules" ] || {
                  for module in ${toString modules}; do
                    go get $module
                  done
                  go mod tidy
                }
              '';
            modPostBuild = ''
              # Once the modules are vendorized, also save go.mod and go.sum
              cp go.mod go.sum vendor
            '';
          });
        };
      });
}
