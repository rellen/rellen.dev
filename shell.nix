{
  pkgs ? import <nixpkgs> { },
}:
let
  inherit (pkgs.lib) optional;
  ghc = pkgs.haskellPackages.ghcWithPackages (
    pkgs: with pkgs; [
      cabal-install
      haskell-language-server
    ]
  );
in
pkgs.mkShell {
  name = "haskell shell";
  buildInputs =
    with pkgs;
    [
      ghc
      zlib

      # Formatters
      treefmt
      nixfmt
      ormolu
      prettier
      shfmt

      # Linters
      hlint
      deadnix
      statix
      vale

      # Link checking
      lychee

      # HTML5 conformance (wraps W3C Nu Validator's vnu.jar)
      html5validator

      # Build tools
      just
      imagemagick

      # Deployment
      wrangler

      # Node (for npx-based MCP servers like chrome-devtools-mcp)
      nodejs_22
    ]
    ++ optional stdenv.isLinux inotify-tools
    ++ optional stdenv.isDarwin apple-sdk;

  shellHook = ''
    if [ -f package.json ]; then
      npm install --silent --no-fund --no-audit
      export PATH="$PWD/node_modules/.bin:$PATH"
    fi
  '';
}
