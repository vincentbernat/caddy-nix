 {
  inputs = {
    nixpkgs.url = "nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    caddy = {
      url = "github:vincentbernat/caddy-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, flake-utils, caddy }:
    flake-utils.lib.eachDefaultSystem (system:
      {
        packages = {
          default = caddy.packages.${system}.default.override {
            modules = [{ name = "github.com/caddy-dns/powerdns"; version = "1.0.1"; }];
            vendorHash = "sha256-ez8lcTJegWTIWcaEVJlqcA+M1DTyXF70U5VI+cOHz8s=";
          };
        };
      });
}
