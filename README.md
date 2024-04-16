# nixpkgs-xthead-toolchains

A Nix flake with overlays for toolchains with support for xthead extensions

## Configuration

Add to your flake input:

```nix
inputs.xthead-toolchains.url = "github:milkv-community/nixpkgs-xthead-toolchains";
```

Then add to your overlays:

```nix
nixpkgs.overlays = [
  xthead-toolchains.overlays.default
];
```

The overlay defines several packages under `xthead` which you can install:

```nix
# For your riscv64 native host:
environment.systemPackages = with pkgs; [
  # xthead.binutils_2_42
  xthead.gcc14
  # xthead.llvmPackages_17.clang
];

# For cross-compiling from your non-riscv64 native host to riscv64:
# NOTE: this prefixes tools with `riscv64-unknown-linux-gnu-`
environment.systemPackages = with pkgs.pkgsCross.riscv64.buildPackages; [
  # xthead.binutils_2_42
  xthead.gcc14
  # xthead.llvmPackages_17.clang
];
```

Note that the `gcc14` package automatically includes `binutils` version `2.42` since that version is needed to assemble the new `xtheadvector` instructions.

## Usage

### GCC 14 (with binutils 2.42)

Compile using `gcc` with `xtheadvector` via:

`gcc -O3 -march=riscv64gc_xtheadvector -mcpu=thead-c906`

### LLVM 17.0.6

This version of LLVM is compiled from the [ruyisdk/llvm-project](https://github.com/ruyisdk/llvm-project) repository.

See [here](https://github.com/ruyisdk/llvm-project?tab=readme-ov-file#how-to-use-the-xtheadvector-extension) for further information on the implementation and how to use the `xtheadvector` extension in detail.

Below is a quick summary.

#### clang

Compile using `clang` with `xtheadvector` via:

`clang -march=rv64gc_xtheadvector`

#### llc

Compile LLVM IR using `llc` with `xtheadvector` via:

`llc -mtriple=riscv64 -mattr=+xtheadvector`
