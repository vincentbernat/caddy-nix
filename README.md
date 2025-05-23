# Flake to build Caddy with additional plugins

Building Caddy with additional plugins is a bit complex with Nix. Thanks to this
[pull request][], this is now possible in NixOS 25.05. For NixOS 24.11, this
flake proposes an alternative.

> [!IMPORTANT]
> This flake requires [this commit][] and therefore will only work starting from Nixpkgs 24.11.

[pull request]: https://github.com/NixOS/nixpkgs/pull/358586 "caddy: add support for compiling with Caddy modules (plugins)"
[this commit]: https://github.com/nixOS/nixpkgs/commit/eed069a5bc40ba4d871de7700c7eb8d592e98cb6

## Usage as input

The first possibility is to use this flake as an input of another flake. You can
look at `examples/flake/flake.nix` on how to do that. The `hash` key can be
removed on the first build to get the computed hash.

## Copy caddy.nix in your own configuration

If you don't want to depend on an external flake or if you don't use flakes, you
can just copy `caddy.nix` and import it as an overlay.

```nix
let
  pkgs = import nixpkgs {
    inherit system;
    overlays = [ (import ./caddy.nix) ];
  };
in
  pkgs.caddy.withPlugins {
    plugins = [ "github.com/caddy-dns/powerdns@v1.0.1" ];
    hash = "sha256-F/jqR4iEsklJFycTjSaW8B/V3iTGqqGOzwYBUXxRKrc=";
  }
```

With NixOS, you need to use:

```nix
nixosConfigurations = {
  "reverse" = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    nixpkgs.overlays = [ (import ./caddy.nix) ];
    /* ... */
  };
}
```
