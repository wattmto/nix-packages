{
  description = "nix-packages";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
  };

  outputs =
    {
      self,
      systems,
      nixpkgs,
    }@inputs:
    let
      forEachSystems = nixpkgs.lib.genAttrs (import systems);
      mkPackages =
        path: pkgs:
        with builtins;
        listToAttrs (
          map (name: {
            inherit name;
            value = pkgs.callPackage (path + "/${name}") { };
          }) (attrNames (readDir path))
        );
    in
    {
      packages = forEachSystems (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
        in
        mkPackages ./packages pkgs
      );
    };
}
