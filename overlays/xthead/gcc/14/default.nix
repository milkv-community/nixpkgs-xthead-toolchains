final: prev: {
  xthead = (prev.xthead or { }) // {
    gcc14 =
      let
        bintools = final.xthead.binutils_2_42;
        gcc-snapshot = "20240414";
        version = "14.0.0-dev.${gcc-snapshot}+binutils-${bintools.version}";
      in
      prev.wrapCCWith {
        inherit bintools;
        cc = (prev.gcc13.cc.override (oldInputs: {
          stdenv =
            if (with oldInputs.stdenv; buildPlatform == hostPlatform)
            then oldInputs.stdenv
            else
            # NOTE: When `build != host`, we need to ensure we build with the build-platform
            # gcc14, otherwise gcc will not build `xgcc` in-tree, but instead use a
            # pre-existing gcc13, which will then fail to build `libstdc++-v3` since it now
            # requires `-std=gnu++26`, which is not supported.
              oldInputs.stdenv.override {
                allowedRequisites = null;
                cc = final.buildPackages.xthead.gcc14;
              };
          targetPackages =
            if (with oldInputs.stdenv; hostPlatform == targetPlatform)
            then oldInputs.targetPackages
            else
            # NOTE: When `host != target`, we need to ensure we override the binutils chosen
            # by `targetPackages`, since this is used in the `gcc` derivation for specifying
            # the cross-configure flags for `--with-as=` and `--with-ld=`. Without this
            # modification, the `pkgsCross.<name>.buildPackages.gcc14` will use the default
            # binutils (2.41).
              oldInputs.targetPackages // {
                stdenv.cc.bintools = oldInputs.targetPackages.buildPackages.xthead.binutils_2_42;
              };
        })).overrideAttrs (oldAttrs: {
          inherit version;
          name = "gcc-${version}";
          passthru = oldAttrs.passthru // { inherit version; };
          src = prev.stdenv.fetchurlBoot {
            url = "https://gcc.gnu.org/pub/gcc/snapshots/14-20240414/gcc-14-${gcc-snapshot}.tar.xz";
            hash = "sha256-2zUl9QmW4OWkMfEI/wHReEeIyvs+PvobdbnOvBE0inM=";
          };
          nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [
            prev.buildPackages.flex
          ];
          patches = prev.lib.filter
            (patch: ! builtins.elem (builtins.baseNameOf patch) [
              "ICE-PR110280.patch"
            ])
            oldAttrs.patches;
        });
      };
  };
}
