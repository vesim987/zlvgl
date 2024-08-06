{
  description = "KlipperZscreen";

  inputs = {
    nixpkgs.url =
      "git+file:///home/vesim/pro/nixpkgs"; # "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    zig.url = "github:mitchellh/zig-overlay";
  };
  outputs = { self, nixpkgs, flake-utils, ... }@inputs:
    let
      overlays = [
        (final: prev: {
          zigpkgs = inputs.zig.packages.${prev.system};
        })
      ];

      systems = builtins.attrNames inputs.zig.packages;
    in flake-utils.lib.eachSystem systems (system:
      let pkgs = import nixpkgs { inherit overlays system; };
      in with pkgs; rec {
        devShells.default = pkgs.mkShell {
          buildInputs = [ zigpkgs.master pkg-config gdb SDL2 SDL2_image ];
        };
      });
}
