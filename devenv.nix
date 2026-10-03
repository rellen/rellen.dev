{ pkgs, lib, config, inputs, ... }:

{
  # https://devenv.sh/basics/
  env.GREET = "devenv";

  # https://devenv.sh/packages/
  packages =
    with pkgs;
    [
      git

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
      imagemagick

      # Deployment
      wrangler

  ];

  # https://devenv.sh/languages/
  languages.haskell.enable = true;
  languages.haskell.stack.enable = false;
  
  # https://devenv.sh/processes/
  processes.watch = {
    exec = "cabal build && cabal exec site rebuild && cabal exec site watch";
    watch = {
      paths = [ ./. ];
      extensions = [ "hs"];
    };
  };

  # https://devenv.sh/services/
  # services.postgres.enable = true;

  # https://devenv.sh/scripts/
  scripts.hello.exec = ''
    echo hello from $GREET
  '';

  # https://devenv.sh/basics/
  enterShell = ''
    hello         # Run scripts directly
    git --version # Use packages
    cabal --version
  '';

  # https://devenv.sh/tasks/
  tasks = {
    "cabal:update".exec = "cabal update";
    "cabal:install".exec = "cabal install";
    "cabal:build".exec = "cabal build";

    "site:build".exec = "site build";
    
  #   "devenv:enterShell".after = [ "myproj:setup" ];
  };

  # https://devenv.sh/tests/
  enterTest = ''
    echo "Running tests"
    git --version | grep --color=auto "${pkgs.git.version}"
  '';

  # https://devenv.sh/git-hooks/
  # git-hooks.hooks.shellcheck.enable = true;

  # See full reference at https://devenv.sh/reference/options/
}
