{ lib
, nixpkgs
, nixpkgs-master
, pkgset
, self
, system
, impermanence
, nixpie
, ...
}@inputs:
let
  nixosSystem = imageName:
    lib.nixosSystem {
      inherit system;

      specialArgs = {
        inherit inputs;
        inherit imageName;
      };

      modules =
        let
          core = self.nixosModules.profiles.core;

          global = {
            system.name = imageName;
            networking.hostName = ""; # Use the DHCP provided hostname
            nix.nixPath = [
              "nixpkgs=${nixpkgs}"
              "nixpkgs-master=${nixpkgs-master}"
            ];

            nixpkgs = { inherit (pkgset) pkgs; };

            nix.registry = {
              nixpkgs.flake = nixpkgs;
              nixpkgs-master.flake = nixpkgs-master;
              nixpie.flake = self;
              sadm.flake = self;
            };

            # TODO: correctly set config.system.nixos.label
            system.configurationRevision = lib.mkIf (self ? rev) self.rev;
          };

          local = import "${toString ./.}/${imageName}.nix";

          flakeModules =
            builtins.attrValues (removeAttrs self.nixosModules [ "profiles" "sadm" ]);

        in
        lib.concat flakeModules [
          impermanence.nixosModules.impermanence
          core
          global
          local
          nixpie.nixosModules.nixpie
        ];
    };

  hosts = lib.genAttrs [
    "prologin-gcc"
  ]
    nixosSystem;
in
hosts
