{ config, pkgs, lib, flakePath, flakePathStr, ... }:

{
  home.packages = with pkgs; [
    # Linux-specific packages
    grim
    slurp
    wl-clipboard
    cliphist
    wtype
    tofi
    waybar
    meld

    # Fonts
    noto-fonts
    dejavu_fonts
    liberation_ttf
    font-awesome

    # Shell
    zsh-syntax-highlighting
  ];

  # ── VSCode / Cursor settings ─────────────────────────────────────────
  # mkOutOfStoreSymlink links directly to the repo checkout (not the Nix store),
  # so GUI edits write straight back to the repo for easy git tracking.
  xdg.configFile."Code/User/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink "${flakePathStr}/editors/settings.json";
  xdg.configFile."Code/User/keybindings.json".source =
    config.lib.file.mkOutOfStoreSymlink "${flakePathStr}/editors/keybindings.json";
  xdg.configFile."Cursor/User/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink "${flakePathStr}/editors/settings.json";
  xdg.configFile."Cursor/User/keybindings.json".source =
    config.lib.file.mkOutOfStoreSymlink "${flakePathStr}/editors/keybindings.json";

  # ── Linux-specific config files ───────────────────────────────────────
  xdg.configFile = {
    "sway" = {
      source = "${flakePath}/configs/linux/.config/sway";
      recursive = true;
    };
    "tofi/config".source = "${flakePath}/configs/linux/.config/tofi/config";
    "waybar" = {
      source = "${flakePath}/configs/linux/.config/waybar";
      recursive = true;
    };
  };
}
