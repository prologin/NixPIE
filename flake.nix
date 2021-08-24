{
  description = "Prologin NixOS configuration for 2021 finale";

  inputs = {
    nixpie.url = "git+https://gitlab.cri.epita.fr/cri/infrastructure/nixpie.git";
    nixpkgsMuEditor.url = "github:rissson/nixpkgs/mu-editor";
    futils.url = "github:numtide/flake-utils";
  };

  outputs =
    { self
    , nixpie
    , nixpkgsMuEditor
    , futils
    } @ inputs:
    let
      inherit (nixpie.inputs) nixpkgs;
      nixpkgs-master = nixpie.inputs.nixpkgsMaster;
      inherit (nixpkgs) lib;
      inherit (lib) recursiveUpdate;
      inherit (futils.lib) eachDefaultSystem;

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

        nixosConfigurations =
          let
            system = "x86_64-linux";
          in
          (import ./images (
            recursiveUpdate inputs {
              inherit lib system;
              inherit nixpkgs nixpkgs-master;
              pkgset = pkgset system;
            }
          ));

      };
    in
    recursiveUpdate anySystemOutputs { };
}

