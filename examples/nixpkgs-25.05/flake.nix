{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
      in
      {
        packages = {
          default = pkgs.caddy.withPlugins {
            plugins = [ "github.com/mholt/caddy-ratelimit@v0.1.0" ];
            hash = "sha256-gn+FDt9GJ6bM1AJMUuBpLZqf/PXr5qYPHqB1kVy8ovQ=";
          };
        };
      });
}
