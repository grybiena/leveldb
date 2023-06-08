rec {
  description = "leveldb-json";
  inputs = {
    env.url = "git+ssh://git@github.com/grybiena/purescript-environment?ref=grybiena";  
  };

  outputs = inputs@{ env, ... }:
    env.flake-utils.lib.eachDefaultSystem (system:
      env.build-package { inherit system;
                          name = description;
                          src = ./.;
                          overlays = with inputs; { };
                          derive-package = ./package.nix;
                        }
                
   );
}

