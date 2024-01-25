rec {
  description = "leveldb";
  inputs = {
    env.url = "github:grybiena/purescript-environment";
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

