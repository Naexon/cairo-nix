{
  description = "Cairo toolchain in nix";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, flake-utils, ... }:
    let
      overlay = import ./overlay.nix;
    in
    {
      overlays = {
        default = overlay;
      };

      templates = {
        default = {
          path = ./templates/simple;
          description = "A basic project using cairo-nix";
        };
      };
    } // flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ overlay ];
        };
      in
      {
        formatter = pkgs.nixpkgs-fmt;

        devShells.default = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [
            cargo
            openssl
            openssl.dev
            pkg-config
            perl
            cairo-bin.stable.cairo
            cairo-bin.stable.scarb
          ];

          # Set OpenSSL-related environment variables
          OPENSSL_DIR = "${pkgs.openssl.dev}";
          OPENSSL_INCLUDE_DIR = "${pkgs.openssl.dev}/include";
          OPENSSL_LIB_DIR = "${pkgs.openssl.dev}/lib";
          PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";

          RUSTFLAGS = "--cfg openssl_dir=/nix/store/s3vv0916j6z5zfs0b1bcfinx1kb6cbhn-openssl-3.3.2-bin/bin/openssl";
        };

        packages = {
          default = pkgs.cairo-bin.stable.scarb;
          cairo = pkgs.cairo-bin.stable.cairo;
          scarb = pkgs.cairo-bin.stable.scarb;
          cairo-beta = pkgs.cairo-bin.beta.cairo;
          scarb-beta = pkgs.cairo-bin.beta.scarb;
        };
      });
}
