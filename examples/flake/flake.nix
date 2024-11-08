{
  inputs = {
    nixpkgs.url = "nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    caddy.url = "github:vincentbernat/caddy-nix";
  };
  outputs = { self, nixpkgs, flake-utils, caddy }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ caddy.overlays.default ];
        };
      in
      {
        packages = {
          default = pkgs.caddy.withModules {
            modules = [ "github.com/caddy-dns/powerdns@v1.0.1" ];
            hash = "sha256-Vh7JP6RK23Y0E5IDJ3zbBCnF3gKPIav05OMI4ALIcZg=";
          };
        };
      });
}
