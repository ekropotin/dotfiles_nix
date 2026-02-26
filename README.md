# Nix-managed dotfiles

An experimental attempt to port [my dotfiles](https://github.com/ekropotin/dotfiles) to [Home Manager](https://nix-community.github.io/home-manager/index.xhtml)

May be very unstable, use on your own risk!

## Prerequisites

### 1. Install Nix

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

This uses the [Determinate Nix Installer](https://github.com/DeterminateSystems/nix-installer), which enables flakes by default. Alternatively, install Nix via the [official installer](https://nixos.org/download/) and enable flakes manually.

### 2. Install home-manager

```bash
nix run home-manager -- init
```

### 3. (macOS only) Install Homebrew

Some GUI apps and macOS-specific tools are not available in nixpkgs and require Homebrew:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

## Installation

1. Clone the repo

```bash
git clone git@github.com:ekropotin/dotfiles.git
cd dotfiles
```

2. Build (validates the configuration without changing anything)

```bash
home-manager build --flake .#coding --impure
```

3. Apply the configuration

```bash
home-manager switch --flake .#coding --impure -b backup
```

The `-b backup` flag renames any existing conflicting files with a `.backup` suffix instead of failing.

4. (macOS only) Install Homebrew casks and formulae not covered by Nix

```bash
brew bundle --file=~/.config/homebrew/Brewfile
```

## Everyday usage

After editing any config files, apply changes with:

```bash
home-manager switch --flake .#coding --impure
```

## Rollback

List all generations (snapshots of previous configurations):

```bash
home-manager generations
```

Roll back to the previous generation:

```bash
home-manager rollback
```

Switch to a specific generation (use the path from `home-manager generations`):

```bash
/nix/store/<hash>-home-manager-generation/activate
```

## Uninstall

To remove all home-manager managed symlinks and restore your home directory to an unmanaged state:

```bash
home-manager uninstall
```

## Structure

```
flake.nix                 # Entry point — defines the "coding" home configuration
nix/
  home-common.nix         # Shared packages and dotfile symlinks (cross-platform)
  home-darwin.nix         # macOS-specific packages and configs (yabai, skhd, Brewfile)
  home-linux.nix          # Linux-specific packages and configs (sway, waybar, tofi)
  shell.nix               # Zsh configuration (oh-my-zsh, aliases, fzf integration)
  programs.nix            # Declarative program configs (git, bat, tmux, fzf, kitty, etc.)
configs/
  common/                 # Dotfiles shared across platforms
  mac/                    # macOS-specific dotfiles
  linux/                  # Linux-specific dotfiles
editors/                  # VS Code / Cursor settings, keybindings, and extensions list
tools/                    # Custom scripts (tms, cht) installed to ~/bin
```

## How it works

The flake uses `builtins.currentSystem` to auto-detect whether you are on macOS or Linux and applies the appropriate platform-specific module. This requires the `--impure` flag.

home-manager handles:

- Installing packages via Nix
- Creating symlinks for all dotfiles (replaces `setup_dotfiles.sh`)
- Configuring programs declaratively (zsh, tmux, bat, git, etc.)
- Managing tmux plugins (no more TPM or vendored plugin directories)
