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
            modules = [ "github.com/caddy-dns/powerdns@v1.0.1" ];
            hash = "sha256-F/jqR4iEsklJFycTjSaW8B/V3iTGqqGOzwYBUXxRKrc=";
          };
        };
      });
}
