{ lib
, nixpkgs
, nixpkgs-master
, pkgset
, self
, system
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
            networking.hostName = lib.mkForce ""; # Use the DHCP provided hostname
            nix.nixPath = [
              "nixpkgs=${nixpkgs}"
              "nixpkgs-master=${nixpkgs-master}"
            ];

            nixpkgs = { inherit (pkgset) pkgs; };

            nix.registry = {
              nixpkgs.flake = nixpkgs;
              nixpkgs-master.flake = nixpkgs-master;
              nixpie.flake = nixpie;
              sadm.flake = self;
            };

            # TODO: correctly set config.system.nixos.label
            system.configurationRevision = lib.mkIf (self ? rev) self.rev;
          };

          local = import "${toString ./.}/${imageName}.nix";

          flakeModules =
            builtins.attrValues (removeAttrs self.nixosModules [ "profiles" ]);

        in
        lib.concat flakeModules [
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
