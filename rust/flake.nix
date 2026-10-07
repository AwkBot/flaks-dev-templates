{
  description = "Rust development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, rust-overlay, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ rust-overlay.overlays.default ];
      };
      toolchain = pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml;
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        packages = [
          toolchain
          pkgs.cargo-nextest
          pkgs.gcc
        ];

        shellHook = ''
          ln -sfn ${toolchain} .toolchain

          # stdlib gravável para o RustRover (RUST-16842)
          if [ "$(cat .direnv/rust-src/.source 2>/dev/null)" != "${toolchain}" ]; then
            mkdir -p .direnv
            chmod -R u+w .direnv/rust-src 2>/dev/null; rm -rf .direnv/rust-src
            cp -rL --no-preserve=mode ${toolchain}/lib/rustlib/src/rust .direnv/rust-src
            echo "${toolchain}" > .direnv/rust-src/.source
          fi
        '';
      };
    };
}