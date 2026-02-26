{ config, pkgs, lib, flakePath, ... }:

{
  imports = [
    ./shell.nix
    ./programs.nix
  ];

  home.username = "ekropotin";
  home.homeDirectory =
    if pkgs.stdenv.isDarwin
    then "/Users/ekropotin"
    else "/home/ekropotin";

  home.stateVersion = "24.11";
  programs.home-manager.enable = true;

  # ── Common packages (cross-platform) ──────────────────────────────────
  home.packages = with pkgs; [
    # Core CLI tools
    bat
    eza
    fd
    fzf
    htop
    jq
    just
    ripgrep
    tldr
    wget
    zoxide

    # Editors
    neovim

    # Tmux (tmux itself is managed by programs.tmux)
    tmuxinator

    # Python
    python3
    uv

    # Node
    nodejs

    # Version control
    jujutsu # jj
    lazygit

    # Fonts
    meslo-lgs-nf

    # Kubernetes
    kubectl
    kubectx
    k9s
  ];

  # ── Dotfile symlinks ──────────────────────────────────────────────────
  # These replace setup_dotfiles.sh — home-manager manages symlinks for us.

  home.file = {
    ".ideavimrc".source = "${flakePath}/configs/common/.ideavimrc";
    ".p10k.zsh".source = "${flakePath}/configs/common/.p10k.zsh";
    ".cht-langs".source = "${flakePath}/configs/common/.cht-langs";
    ".cht-utils".source = "${flakePath}/configs/common/.cht-utils";
  };

  xdg.configFile = {
    # Neovim (entire directory)
    "nvim" = {
      source = "${flakePath}/configs/common/.config/nvim";
      recursive = true;
    };

    # Tmux is fully managed by programs.tmux in programs.nix

    # Kitty
    "kitty" = {
      source = "${flakePath}/configs/common/.config/kitty";
      recursive = true;
    };

    # Bat
    "bat/config".source = "${flakePath}/configs/common/.config/bat/config";
    "bat/themes" = {
      source = "${flakePath}/configs/common/.config/bat/themes";
      recursive = true;
    };

    # Jujutsu (jj)
    "jj" = {
      source = "${flakePath}/configs/common/.config/jj";
      recursive = true;
    };
  };

  # ── Editor extensions (VSCode / Cursor) ───────────────────────────────
  home.activation.editorExtensions = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    extensions_file="${flakePath}/editors/extensions.txt"
    if [ -f "$extensions_file" ]; then
      for editor in code cursor; do
        if command -v "$editor" >/dev/null 2>&1; then
          installed=$("$editor" --list-extensions 2>/dev/null || true)
          while IFS= read -r ext; do
            ext=$(echo "$ext" | xargs)
            [ -z "$ext" ] && continue
            if ! echo "$installed" | grep -iq "^$ext$"; then
              verboseEcho "Installing $editor extension: $ext"
              run "$editor" --install-extension "$ext" --force || true
            fi
          done < "$extensions_file"
        fi
      done
    fi
  '';

  # ── Custom scripts (tms, cht) → ~/bin ─────────────────────────────────
  home.file."bin/tms" = {
    source = "${flakePath}/tools/tms";
    executable = true;
  };
  home.file."bin/cht" = {
    source = "${flakePath}/tools/cht";
    executable = true;
  };

}
