# project setup

In this section we document all the files relevant for the project setup.

## `flake.nix`

This file specifies our project's dependencies and outputs/artefacts.
Some common dependencies for a Haskell project are the GHC and Cabal, but during development we also use HLS, hpack, ....
Nix flake dependencies are called *inputs*, and are usually Git repositories (e.g. from GitHub, GitLab, ...), but they can be any web-accessible resource.

By using Nix and Nixpkgs, the developers do not have to have those tools installed on their machines, manage their versions, etc.
It also allows us to create other controlled environments, such as container images for CI/CD.

The project should still build without Nix, because Nix does not change any project files. This means you must have Cabal and system libraries installed manually.

## `flake.lock`

This file is automatically generated and updated by Nix, when evaluating the `flake.nix` file.
It contains the timestamps and hashes of each input at the time of last update.

An input coupled with a timestamp and hash of its contents is called a *pinned* input. Pinning inputs allows us to guarantee reproducibility.

We can specify unpinned inputs in `flake.nix`; for example, our `nixpkgs` input is not pinned to a specific commit. The branch `nixpkgs-unstable` changes almost every day.
However, the `flake.lock` file contains a timestamp and hash of a specific commit in the `nixpkgs` repository. This is regenerated for every input every time we run `nix flake upadate`, to the latest commit in the branch/tag we specified in the flake.

We can also update just a single input (e.g. just `nixpkgs`) and leave the others pinned.
One way of doing this is with the command:
```sh
nix build . --update-input nixpkgs
```

## `shell.nix`

Nix flakes are a new feature. Some Nix installations do not support them. However, it is still useful to provide a development shell for developers with older Nix versions.

This file allows us to replicate the development shell provided in `flake.nix` without duplicating the code. This way changes to the `flake.nix` are automatically propagated to the `shell.nix`.

Some tools also don't yet support flakes. An important example is Visual Studio Code with the Nix Environment Selector plugin: it works with `shell.nix`, but not `flake.nix`.

## `hie.yaml`

This file instructs the Haskell Language Server how your project should be built. Find more information at [https://haskell-language-server.readthedocs.io/en/latest/configuration.html](https://haskell-language-server.readthedocs.io/en/latest/configuration.html).

## `package.yaml`

This file contains the Cabal package specification in `yaml` format read by [hpack](https://github.com/sol/hpack#readme). It is more abstract and easier to maintain than the Cabal file format.

To generate a `.cabal` file from a `package.yaml` file, run the following command:

```sh
hpack
```

Note that Cabal does not understand `package.yaml` files, and requires us to generate a `.cabal` file before running `cabal`.
Nix (or more precisely, Cabal2nix) uses a `.cabal` file if it is present, otherwise the `package.yaml` file. Because `package.yaml` is our single source of truth, we would prefer that Nix uses it instead of the generated `.cabal`. This is why we don't commit the `.cabal` file.

## `crem.cabal`

This file is automatically generated from the `package.yaml` file and should not be committed to Git history.

## `fourmolu.yaml`

Configuration file for the [`fourmolu`](https://github.com/fourmolu/fourmolu) formatting tool.

## `.hspec`

Using a dedicated file to specify options for [`hspec`](https://hspec.github.io) allows passing options only to it. Using `cabal test --test-options` would pass options to all test stanzas instead.