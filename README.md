# Flake to build Caddy with additional modules

Building Caddy with additional modules is a bit complex with Nix. In the near
future, this should become possible thanks to this [pull request][]. Meanwhile,
this flake proposes an alternative.

[pull request]: https://github.com/NixOS/nixpkgs/pull/317881 "caddy: add support for compiling with Caddy modules (plugins)"

## Usage as input

The first possibility is to use this flake as an input of another flake. You can
look at `examples/flake/flake.nix` on how to do that. The `hash` key can be
removed on the first build to get the computed hash.

## Copy caddy.nix in your own configuration

If you don't want to depend on an external flake or if you don't use flakes, you
can just copy `caddy.nix` and invoke it with `callPackage`:

```nix
caddy-with-modules = pkgs.callPackage ./caddy.nix {
  modules = [ "github.com/caddy-dns/powerdns@v1.0.1" ];
  hash = "sha256-F/jqR4iEsklJFycTjSaW8B/V3iTGqqGOzwYBUXxRKrc=";
}
```
