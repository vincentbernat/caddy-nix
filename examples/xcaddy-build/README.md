# Build Caddy with xcaddy

This `flake.nix` builds Caddy with xcaddy. It requires patching the resulting
caddy and the resulting binary may have some functions not working correctly
(MIME type and service lookup notably).
