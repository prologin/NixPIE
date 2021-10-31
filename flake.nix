{
  description = "Prologin NixOS configuration for 2021 finale";

  inputs = {
    nixpie.url = "git+https://gitlab.cri.epita.fr/cri/infrastructure/nixpie.git";
    nixpkgsMuEditor.url = "github:prologin/nixpkgs/mu-editor";
    futils.url = "github:numtide/flake-utils";
    prolowalls.url = "github:prologin/prolowalls";
  };

  outputs =
    { self
    , nixpie
    , nixpkgsMuEditor
    , futils
    , prolowalls
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

        nixosConfigurations =
          let
            system = "x86_64-linux";
          in
          (import ./images (
            recursiveUpdate inputs {
              inherit lib system;
              inherit nixpkgs nixpkgs-master;
              inherit (prolowalls.packages.${system}) gccLogo;
              pkgset = pkgset system;
            }
          ));

      };
    in
    recursiveUpdate anySystemOutputs { };
}

