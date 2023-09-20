{ pkgs ? import <nixpkgs> { }, nixpkgs ? <nixpkgs> }:
let
  inherit (pkgs.lib) optional optionals;
  ghc =  pkgs.haskellPackages.ghcWithPackages (pkgs: with pkgs; [ stack ]);
in pkgs.mkShell rec {
  name = "shell";
  buildInputs = with pkgs; [ ghc zlib
    ] ++ optional stdenv.isLinux inotify-tools ++ optionals stdenv.isDarwin (with darwin.apple_sdk.frameworks; [ CoreFoundation CoreServices ]);

shellHook = ''
     # this allows mix to work on the local directory
   '';
}
