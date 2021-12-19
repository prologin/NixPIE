{
  description = "Prologin NixOS configuration for 2021 finale";

  inputs = {
    nixpie.url = "git+https://gitlab.cri.epita.fr/cri/infrastructure/nixpie.git";
    nixpkgsMuEditor.url = "github:prologin/nixpkgs/mu-editor";
    futils.url = "github:numtide/flake-utils";
    nixpkgsMaster.url = "github:NixOS/nixpkgs/master";
    nixpkgsUnstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    { self
    , nixpie
    , nixpkgsMuEditor
    , futils
    , nixpkgsMaster
    , nixpkgsUnstable
    } @ inputs:
    let
      inherit (nixpie.inputs) nixpkgs;
      nixpkgs-master = nixpie.inputs.nixpkgsMaster;
      inherit (nixpkgs) lib;
      inherit (lib) recursiveUpdate;
      inherit (futils.lib) eachDefaultSystem;

      pkgs = import nixpkgs { inherit system; };
      system = "x86_64-linux";

      pkgImport = pkgs: system: withOverrides:
        import pkgs {
          overlays = [
            nixpie.overlay
          ];
          inherit system;
          config = {
            allowUnfree = true;
          };
        };

      pkgset = system: {
        pkgs = pkgImport nixpkgs system true;
        pkgsMaster = pkgImport nixpkgs-master system false;
      };

      anySystemOutputs = {
        nixosModules = {
          profiles = import ./profiles;
        };

        packages =
          {
              "${system}" = {
                prologin-gcc-background = import ./pkgs/gcc-background.nix { inherit pkgs; };
              };
          };

        nixosConfigurations =
          let
            system = "x86_64-linux";
          in
          (import ./images (
            recursiveUpdate inputs {
              inherit lib system;
              inherit nixpkgs nixpkgs-master;
              inherit (self.packages.${system}) prologin-gcc-background;
              pkgset = pkgset system;
            }
          ));

      };
    in
    recursiveUpdate anySystemOutputs { };
}

