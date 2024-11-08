{
  outputs = { self }: {
    overlays = {
      default = import ./caddy.nix;
    };
  };
}
