{ nixpkgs, ... }:

nixpkgs.lib.composeManyExtensions [
  (import ./2.42)
]
