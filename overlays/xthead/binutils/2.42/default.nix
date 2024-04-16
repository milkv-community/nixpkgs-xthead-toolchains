final: prev: {
  xthead = (prev.xthead or { }) // {
    binutils-unwrapped_2_42 = prev.binutils-unwrapped.overrideAttrs (oldAttrs: rec {
      version = "2.42";
      src = prev.fetchurl {
        url = "mirror://gnu/binutils/binutils-${version}.tar.bz2";
        hash = "sha256-qlSFDr2lBkxyzU7C2bBWwpQlKZFIY1DZqXqypt/frxI=";
      };
      patches = prev.lib.filter
        (patch: ! builtins.elem (builtins.baseNameOf patch) [
          "gold-powerpc-for-llvm.patch"
          "0001-libtool.m4-update-macos-version-detection-block.patch"
        ])
        oldAttrs.patches;
    });
    binutils_2_42 = prev.wrapBintoolsWith {
      bintools = final.xthead.binutils-unwrapped_2_42;
      # NOTE: Without this override, `wrapBintoolsWith` will choose `libcCross` when `host !=
      # target`, which does not include the needed `libgcc`, etc.
      libc = prev.targetPackages.glibc or prev.glibc;
    };
  };
}
