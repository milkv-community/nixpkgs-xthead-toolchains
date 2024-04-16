{
  description = "A Nix flake with overlays for toolchains with support for xthead extensions";

  inputs = {
    nixpkgs = {
      url = "github:silvanshade/nixpkgs/nixpkgs-unstable";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, systems, nixpkgs, treefmt-nix, ... }:
    let
      eachSystem = nixpkgs.lib.genAttrs (import systems);
      eachSystemPkgs = overrides: f: eachSystem (system:
        let
          pkgs = import nixpkgs ({ inherit system; } // overrides);
        in
        f pkgs);
      treefmtEval = eachSystem (system: treefmt-nix.lib.evalModule nixpkgs.legacyPackages.${system} ./treefmt.nix);
    in
    {
      formatter = eachSystem (system: treefmtEval.${system}.config.build.wrapper);

      checks = eachSystem (system: {
        formatting = treefmtEval.${system}.config.build.check self;
      });

      overlays = {
        default = nixpkgs.lib.composeManyExtensions [
          self.overlays.binutils
          self.overlays.gcc
          self.overlays.llvm
        ];
        binutils = import ./overlays/xthead/binutils inputs;
        gcc = import ./overlays/xthead/gcc inputs;
        llvm = import ./overlays/xthead/llvm inputs;
      };

      packages = eachSystemPkgs
        {
          overlays = [ self.overlays.default ];
        }
        (pkgs: {
          default = pkgs.gcc;
        });
    };
}
