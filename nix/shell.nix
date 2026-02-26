{ config, pkgs, lib, ... }:

{
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "git-prompt"
        "vscode"
        "kubectl"
        "fzf"
        "kube-ps1"
        "python"
        "gradle"
        "tmux"
        "docker"
        "brew"
        "rust"
        "docker-compose"
        "terraform"
        "jj"
      ];
      theme = "powerlevel10k/powerlevel10k";
    };

    sessionVariables = {
      EDITOR = "nvim";
      JJ_CONFIG = "$HOME/.config/jj/";
    };

    shellAliases = {
      # Kubernetes
      kctx = "kubectx";
      kns = "kubens";
      ar = "kubectl argo rollouts";

      # Git
      gci = "git commit -a -m";
      gbc = "git fetch && git checkout origin/$(git_main_branch) -b";
      gbp = "git push origin $(current_branch)";

      # Jujutsu
      jji = "jj git init --colocate";
      jjf = "jj git fetch";
      jjp = "jj git push";

      # Modern CLI replacements
      cat = "bat";
      ls = "eza --icons=always";
      cd = "z";
    };

    initContent = lib.mkMerge [
      # Powerlevel10k instant prompt — must be at the very top of .zshrc
      (lib.mkOrder 100 ''
        if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
          source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
        fi
      '')

      # Main init content (runs after oh-my-zsh, which is at order 1000)
      (lib.mkOrder 1500 ''
        export PATH=$PATH:$HOME/bin

        # kubectl completion
        complete -F __start_kubectl k

        # -- supercharge fzf --
        show_file_or_dir_preview="if [ -d {} ]; then eza --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi"
        export FZF_CTRL_T_OPTS="--preview '$show_file_or_dir_preview'"
        export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"
        export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
        export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
        export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

        # Use fd for listing path candidates
        _fzf_compgen_path() {
          fd --hidden --exclude .git . "$1"
        }

        # Use fd to generate the list for directory completion
        _fzf_compgen_dir() {
          fd --type=d --hidden --exclude .git . "$1"
        }

        # Advanced customization of fzf options via _fzf_comprun function
        _fzf_comprun() {
          local command=$1
          shift
          case "$command" in
            cd)           fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
            export|unset) fzf --preview "eval 'echo \''$''\{}'" "$@" ;;
            ssh)          fzf --preview 'dig {}'                   "$@" ;;
            *)            fzf --preview "$show_file_or_dir_preview" "$@" ;;
          esac
        }

        # Make directory and cd into it
        function mcd() {
          mkdir -p "$1" && cd "$1";
        }

        # ---- Zoxide (better cd) ----
        eval "$(zoxide init zsh)"

        # Local overrides
        [[ -s "$HOME/.zshrc-local" ]] && source "$HOME/.zshrc-local"

        # To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
        [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

        # NVM
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

        # Init gcloud - platform independent
        if command -v brew &>/dev/null; then
          source "$(brew --prefix)/share/google-cloud-sdk/path.zsh.inc"
          source "$(brew --prefix)/share/google-cloud-sdk/completion.zsh.inc"
        elif [ -f "/usr/share/google-cloud-sdk/path.zsh.inc" ]; then
          source "/usr/share/google-cloud-sdk/path.zsh.inc"
          source "/usr/share/google-cloud-sdk/completion.zsh.inc"
        elif [ -f "$HOME/google-cloud-sdk/path.zsh.inc" ]; then
          source "$HOME/google-cloud-sdk/path.zsh.inc"
          source "$HOME/google-cloud-sdk/completion.zsh.inc"
        fi

        # Init SDKMan
        if command -v brew &>/dev/null; then
          export SDKMAN_DIR=$(brew --prefix sdkman-cli)/libexec
          [[ -s "''${SDKMAN_DIR}/bin/sdkman-init.sh" ]] && source "''${SDKMAN_DIR}/bin/sdkman-init.sh"
        elif [ -d "$HOME/.sdkman" ]; then
          export SDKMAN_DIR="$HOME/.sdkman"
          [[ -s "''${SDKMAN_DIR}/bin/sdkman-init.sh" ]] && source "''${SDKMAN_DIR}/bin/sdkman-init.sh"
        fi

        eval "$(uv generate-shell-completion zsh)"
        eval "$(uvx --generate-shell-completion zsh)"
      '')
    ];

    profileExtra = ''
      # Initialize Homebrew if it exists
      command -v brew &>/dev/null && eval "$(/opt/homebrew/bin/brew shellenv)"
    '';
  };
}
