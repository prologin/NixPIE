{
  description = "Prologin NixOS configuration for 2021 finale";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.05";
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";
    nixpie.url = "git+https://gitlab.cri.epita.fr/cri/infrastructure/nixpie.git";
    futils.url = "github:numtide/flake-utils";
    impermanence.url = "github:nix-community/impermanence";
  };

  outputs =
    { self
    , nixpkgs
    , nixpkgs-master
    , nixpie
    , futils
    , impermanence
    } @ inputs:
    let
      inherit (nixpkgs) lib;
      inherit (lib) recursiveUpdate;
      inherit (futils.lib) eachDefaultSystem;

      pkgImport = pkgs: system: withOverrides:
        import pkgs {
          inherit system;
          config = {
            allowUnfree = true;
          };
          overlays = (lib.attrValues self.overlays);
        };

      pkgset = system: {
        pkgs = pkgImport nixpkgs system true;
        pkgsMaster = pkgImport nixpkgs-master system false;
      };

      anySystemOutputs = {
        nixosConfigurations =
          let
            system = "x86_64-linux";
          in
          (import ./images (
            recursiveUpdate inputs {
              inherit lib system;
              pkgset = pkgset system;
            }
          ));

      };
    in
    recursiveUpdate anySystemOutputs;
}

