{ lib
, pkgs
, modules ? [ ]
, vendorHash ? lib.fakeHash
, caddy ? pkgs.caddy
}: caddy.overrideAttrs (old: {
  inherit vendorHash;
  prePatch =
    let
      moduleNames = map (module: module.name) modules;
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
    let
      moduleNameAndVersions = map (module: lib.escapeShellArg "${module.name}@v${module.version}") modules;
    in
    ''
      # In go-modules derivation, fetch the modules
      [ -n "$goModules" ] || {
        for module in ${toString moduleNameAndVersions}; do
          go get $module
        done
        go mod tidy
      }
    '';
  modPostBuild = ''
    # Once the modules are vendorized, also save go.mod and go.sum
    cp go.mod go.sum vendor
  '';
})
