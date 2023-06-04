{
  description = "leveldb-json";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    ps-tools.follows = "purs-nix/ps-tools";
    purs-nix.url = "github:grybiena/purs-nix?ref=grybiena";
    npmlock2nix =
      { flake = false;
        url = "github:grybiena/npmlock2nix?ref=grybiena";
      };
  };
  outputs = inputs@{ self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ ];

        pkgs = import nixpkgs {
          inherit system overlays;
          config.allowBroken = true;

          # nodejs-18 doesn't link to the correct glibc on aarch64-linux
          # this is just a temporary convenience local testing on an aarch64 machine
          # in compatible environments (such as in deployment) use a higher nodejs version
          config.permittedInsecurePackages = [
            "nodejs-14.21.3"
            "openssl-1.1.1u"
          ];          
        };

        ps-tools = inputs.ps-tools.legacyPackages.${system};
        purs-nix = inputs.purs-nix { inherit system; 
        };

        npmlock2nix = import inputs.npmlock2nix { inherit pkgs; };

        package = import ./package.nix { inherit pkgs system npmlock2nix; } purs-nix;


        # use nodejs-14 for the purs-nix devShell command (see above note)
        ps_14 =
          purs-nix.purs { inherit (package) dependencies;
                          dir = ./.;
                          nodejs = pkgs.nodejs-14_x; 
                        };

        # use a higher version for everything else
        ps =
          purs-nix.purs { inherit (package) dependencies;
                          dir = ./.;
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
                   (ps_14.command { }) 
                   ps-tools.for-0_15.purescript-language-server
                   purs-nix.esbuild
                   purs-nix.purescript
                 ];
              };
         }

   );
}

