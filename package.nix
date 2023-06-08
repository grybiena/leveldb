{ ps-pkgs, npmlock2nix, ... }:
  with ps-pkgs;
  { version = "1.0.0";
    dependencies =
      [ aff
        aff-promise
        argonaut
        options
        pipes
        resourcet
      ];
    src = "src";
    foreign."Level.DB".node_modules =
      npmlock2nix.v2.node_modules { src = ./.;
                                    buildInputs = [];
                                  } + /node_modules;
    foreign."Level.DB.Iterator".node_modules =
      npmlock2nix.v2.node_modules { src = ./.; } + /node_modules;
    foreign."Level.DB.Resource".node_modules =
      npmlock2nix.v2.node_modules { src = ./.; } + /node_modules;


  }
