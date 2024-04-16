_final: prev: {
  xthead = (prev.xthead or { }) // {
    llvmPackages_17 = prev.llvmPackages_17.override {
      gitRelease = null;
      officialRelease = {
        inherit (prev.llvmPackages_17.llvm) version;
        rev-version = "${prev.llvmPackages_17.llvm.version}-milkv-community";
      };
      monorepoSrc = prev.fetchFromGitHub {
        owner = "ruyisdk";
        repo = "llvm-project";
        rev = "c0dd8b6a1ed0399ebcd52e0d4ebc7395ed1e4b46"; # rebase-17.0.6
        hash = "sha256-YAhiZ4QYZVom7jMTT7eZe3L/cqemyR04ZGidOcMywuA=";
      };
    };
  };
}
