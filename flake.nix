{
  description = "leveldb-json";
  inputs = {
    get-flake.url = "github:ursi/get-flake";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    ps-tools.follows = "purs-nix/ps-tools";
    purs-nix.url = "github:grybiena/purs-nix?ref=grybiena";
    flake-utils.url = "github:numtide/flake-utils";
    npmlock2nix =
      { flake = false;
        url = "github:grybiena/npmlock2nix?ref=grybiena";
      };
  };
  outputs = inputs@{ self, nixpkgs, flake-utils, get-flake, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ ];

        pkgs = import nixpkgs {
          inherit system overlays;
          config.allowBroken = true;
        };

        ps-tools = inputs.ps-tools.legacyPackages.${system};
        purs-nix = inputs.purs-nix { inherit system; 
        };

        npmlock2nix = import inputs.npmlock2nix { inherit pkgs; };

        package = import ./package.nix { inherit pkgs get-flake system npmlock2nix; } purs-nix;

        ps =
          purs-nix.purs { inherit (package) dependencies;
                          dir = ./.;
                          nodejs = pkgs.nodejs-14_x; 
                        };

      in 
         { packages.default =
             purs-nix.build
               { name = "leveldb-json";
                 src.path = ./.;
                 info = package;
               };
           packages.output = ps.output {};
           devShells.default = 
             pkgs.mkShell
               { packages = with pkgs; [
                   nodejs
                   (ps.command { }) 
                   ps-tools.for-0_15.purescript-language-server
                   purs-nix.esbuild
                   purs-nix.purescript
                 ];
               };
         }

   );
}

