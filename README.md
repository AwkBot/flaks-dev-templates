# flaks-dev-templates

A collection of [Nix flake](https://nixos.wiki/wiki/Flakes) templates for development environments, one per language. Each template provides a reproducible `devShell`: the same toolchain, at the same version, on any machine with Nix.

Templates are exposed through Nix's native template mechanism (`nix flake init -t`). The files are copied into your project, so the result is independent and doesn't reference this repository.

## Available templates

| Template | Files | Description |
|----------|-------|-------------|
| [`rust`](./rust) | `flake.nix`, `rust-toolchain.toml`, `.envrc`, `.gitignore` | Rust with the toolchain provided by [rust-overlay](https://github.com/oxalica/rust-overlay), version pinned in `rust-toolchain.toml` |

## Requirements

- Nix with `flakes` and `nix-command` enabled:

  ```nix
  # NixOS (configuration.nix)
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  ```

  ```ini
  # Other distros (~/.config/nix/nix.conf)
  experimental-features = nix-command flakes
  ```

- `git`: flakes only see files tracked by git.
- Optional but recommended: [direnv](https://direnv.net/) + [nix-direnv](https://github.com/nix-community/nix-direnv), to load the environment automatically when you enter the directory.

## Usage

### 1. Initialize the template

In the current directory:

```sh
cd my-project
nix flake init -t github:AwkBot/flaks-dev-templates#rust
```

Or in a new directory:

```sh
nix flake new my-project -t github:AwkBot/flaks-dev-templates#rust
```

Every file in the template directory is copied, including `.envrc` and `.gitignore`. Existing files are not overwritten: if your project already has a `flake.nix` or `.gitignore`, it is kept as is.

### 2. Track the files in git

```sh
git init   # if the project is not a repository yet
git add flake.nix rust-toolchain.toml .envrc .gitignore
```

Without this, `nix develop` fails with a file-not-found error. You don't need to commit, just stage them.

### 3. Enter the environment

**Manually:**

```sh
nix develop
```

On the first run Nix downloads the dependencies and generates `flake.lock`. Commit it together with `flake.nix`.

**Automatically, with direnv:**

```sh
direnv allow
```

The template already ships an `.envrc` with `use flake`.

From then on the environment is loaded when you enter the directory and unloaded when you leave. Changes to `flake.nix` or `rust-toolchain.toml` reload the environment automatically.

### 4. Editor integration

Editors running outside the `devShell` can't see the toolchain. With direnv set up, use your editor's integration:

- **VS Code:** [direnv](https://marketplace.visualstudio.com/items?itemName=mkhl.direnv) extension (`mkhl.direnv`)
- **Neovim:** [direnv.vim](https://github.com/direnv/direnv.vim)
- **JetBrains:** [Direnv Integration](https://plugins.jetbrains.com/plugin/15285-direnv-integration) plugin

Without direnv: launch the editor from the project shell (`nix develop -c code .`).

### 5. Update dependencies

```sh
nix flake update
```

This updates `flake.lock` (nixpkgs, rust-overlay, etc.). Commit `flake.lock` to keep the environment reproducible across machines.

## Rust

### First run

The template only provides the environment; the Cargo project is created inside it:

```sh
nix develop          # or via direnv
cargo init           # binary; use `cargo init --lib` for a library
cargo build
cargo run
```

### Toolchain version

The compiler version, components and targets live in `rust-toolchain.toml`, which is read both by the flake (through rust-overlay) and by tools that understand the file (rustup, IDEs). To change versions, edit only this file:

```toml
[toolchain]
channel = "stable"            # or "1.xx.0", "nightly-YYYY-MM-DD"
components = ["rustfmt", "clippy", "rust-analyzer", "rust-src"]
targets = []
```

Then `nix develop` (or direnv) picks up the new version.

## Adding a template

1. Create a directory named after the language containing the `flake.nix` and any supporting files.
2. Register it under `templates` in the root `flake.nix`, with a `path`, a `description` and a `welcomeText`.
3. Test it by running `nix flake init -t /path/to/this/repo#<language>` in an empty repository, then `nix develop`.
4. Add a row to the templates table (with the file list) and a section with language-specific instructions.

## License

[0BSD](./LICENSE.md): free to use, copy, modify and distribute for any purpose, with no attribution required.