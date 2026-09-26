{
  description = "Nix flake templates for development environments";

  outputs =
    { self }:
    {
      templates = {
        rust = {
          path = ./rust;
          description = "Rust development environment with a toolchain pinned in rust-toolchain.toml";
          welcomeText = ''
            # Rust development environment

            Next steps:

            Track the files in git (flakes only see tracked files):

            ```sh
            git add .
            ```

            Enter the environment:

            ```sh
            direnv allow   # with direnv
            nix develop    # without direnv
            ```

            Create the Cargo project:

            ```sh
            cargo init     # or cargo init --lib
            ```
          '';
        };
        default = self.templates.rust;
      };
    };
}
