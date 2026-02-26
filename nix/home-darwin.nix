{ config, pkgs, lib, flakePath, flakePathStr, ... }:

{
  home.packages = with pkgs; [
    # macOS-specific packages
    colima
    docker
    pngpaste
    reattach-to-user-namespace
    skaffold
  ];

  # Disable ~/Applications trampoline — GUI apps are managed by Homebrew casks.
  # This also avoids "permission denied" errors when running inside tmux.
  home.activation.trampolineApps = lib.mkForce "";

  # ── macOS-specific config files ───────────────────────────────────────
  xdg.configFile = {
    "yabai/yabairc" = {
      source = "${flakePath}/configs/mac/.config/yabai/yabairc";
      executable = true;
    };
    "yabai/toggle-layout.sh" = {
      source = "${flakePath}/configs/mac/.config/yabai/toggle-layout.sh";
      executable = true;
    };
    "skhd/skhdrc".source = "${flakePath}/configs/mac/.config/skhd/skhdrc";
  };

  # ── VSCode / Cursor settings ─────────────────────────────────────────
  # mkOutOfStoreSymlink links directly to the repo checkout (not the Nix store),
  # so GUI edits write straight back to the repo for easy git tracking.
  home.file."Library/Application Support/Code/User/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink "${flakePathStr}/editors/settings.json";
  home.file."Library/Application Support/Code/User/keybindings.json".source =
    config.lib.file.mkOutOfStoreSymlink "${flakePathStr}/editors/keybindings.json";
  home.file."Library/Application Support/Cursor/User/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink "${flakePathStr}/editors/settings.json";
  home.file."Library/Application Support/Cursor/User/keybindings.json".source =
    config.lib.file.mkOutOfStoreSymlink "${flakePathStr}/editors/keybindings.json";

  # ── Homebrew casks and formulae not available in nixpkgs ──────────────
  # These need to be installed separately via Homebrew.
  # Run: brew bundle --file=~/.config/homebrew/Brewfile
  xdg.configFile."homebrew/Brewfile".text = ''
    # Formulae managed outside nixpkgs
    brew "yabai"
    brew "skhd"
    tap "sdkman/tap"
    brew "sdkman-cli"
    tap "argoproj/tap"
    brew "kubectl-argo-rollouts"
    brew "kube-ps1"
    brew "powerlevel10k"
    brew "zsh-syntax-highlighting"

    # Cask apps (GUI applications — not available in nixpkgs)
    cask "google-cloud-sdk"
    cask "insomnia"
    cask "alfred"
    cask "google-chrome"
    cask "intellij-idea"
    cask "kitty"
    cask "font-meslo-lg-nerd-font"
  '';
}
