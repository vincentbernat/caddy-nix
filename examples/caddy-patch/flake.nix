{
  description = "Patch Caddy with plugins";
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
        plugins = [ "github.com/caddy-dns/powerdns@v1.0.1" ];
        version = pkgs.caddy.version;
      in
      {
        packages = {
          default = pkgs.caddy.overrideAttrs (old: {
            vendorHash = "sha256-ez8lcTJegWTIWcaEVJlqcA+M1DTyXF70U5VI+cOHz8s=";
            prePatch =
              let
                pluginNames = map (plugin: builtins.elemAt (pkgs.lib.splitString "@" plugin) 0) plugins;
              in
              ''
                # Add modules to main.go
                for plugin in ${toString pluginNames}; do
                  sed -i "/plug in Caddy modules here/a _ \"$plugin\"" cmd/caddy/main.go
                done

                # Outside go-modules derivation, copy go.mod and go.sum
                [ -z "$goModules" ] || \
                  cp "$goModules/go.mod" "$goModules/go.sum" .
              '';
            preBuild =
              ''
                # In go-modules derivation, fetch the plugins
                [ -n "$goModules" ] || {
                  for plugin in ${toString plugins}; do
                    go get $plugin
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
