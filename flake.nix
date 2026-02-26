{
  description = "Dotfiles managed with Nix flake + home-manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
    let
      mkCodingConfig = system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          isDarwin = pkgs.stdenv.isDarwin;
        in
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            ./nix/home-common.nix
          ] ++ (if isDarwin then [ ./nix/home-darwin.nix ] else [ ./nix/home-linux.nix ]);
          extraSpecialArgs = {
            flakePath = ./.;
            # Absolute path string for mkOutOfStoreSymlink — points to the real
            # checkout on disk so GUI editors can write back to the repo.
            # Requires --impure flag.
            flakePathStr = builtins.getEnv "PWD";
          };
        };
    in
    {
      homeConfigurations = {
        # Use: home-manager switch --flake .#coding --impure
        # Auto-selects darwin vs linux modules based on the system.
        "coding" = mkCodingConfig builtins.currentSystem;

        # Explicit per-system targets (no --impure needed for system detection,
        # but still needed for mkOutOfStoreSymlink via getEnv):
        #   home-manager switch --flake .#coding-darwin --impure
        #   home-manager switch --flake .#coding-linux --impure
        "coding-darwin" = mkCodingConfig "aarch64-darwin";
        "coding-linux" = mkCodingConfig "x86_64-linux";
      };
    };
}
