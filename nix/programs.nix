{ config, pkgs, lib, ... }:

{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Evgeny Kropotin";
        email = "ekropotin@gmail.com";
      };
    };
  };

  programs.kitty = {
    enable = true;
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = false; # Handled manually in shell.nix to keep alias ordering
  };

  programs.bat = {
    enable = true;
    config = {
      theme = "Catppuccin Mocha";
    };
  };

  programs.eza = {
    enable = true;
  };

  programs.tmux = {
    enable = true;
    mouse = true;
    prefix = "C-Space";
    baseIndex = 1;
    keyMode = "vi";
    terminal = "tmux-256color";
    shell = "\${SHELL}";

    plugins = with pkgs.tmuxPlugins; [
      sensible
      vim-tmux-navigator
      yank
      {
        plugin = catppuccin;
        extraConfig = ''
          set -g @catppuccin_flavour 'mocha'
        '';
      }
    ];

    extraConfig = ''
      # True color support
      set-option -sa terminal-overrides ",xterm*:Tc"

      # Pane base index
      set -g pane-base-index 1
      set-window-option -g pane-base-index 1
      set-option -g renumber-windows on

      # Shift arrow to switch windows
      bind -n S-Left  previous-window
      bind -n S-Right next-window

      # Toggle passthrough mode with F12
      bind-key -n F12 run-shell '             \
        current=$(tmux show-option -gqv prefix); \
        if [ "$current" = "None" ]; then         \
          tmux set -g prefix C-Space;            \
          tmux set -g @prefix-enabled 1;         \
          tmux bind -n S-Left previous-window;   \
          tmux bind -n S-Right next-window;      \
          tmux unbind -n C-h;                    \
          tmux unbind -n C-j;                    \
          tmux unbind -n C-k;                    \
          tmux unbind -n C-l;                    \
          is_vim="ps -o state= -o comm= -t \"$(tmux display -p \"#{pane_tty}\")\" | grep -iqE \"^[^TXZ ]+ +(\\S+\\/)?g?(view|l?n?vim?x?|fzf)(diff)?$\""; \
          tmux bind-key -n C-h if-shell "$is_vim" "send-keys C-h" "select-pane -L"; \
          tmux bind-key -n C-j if-shell "$is_vim" "send-keys C-j" "select-pane -D"; \
          tmux bind-key -n C-k if-shell "$is_vim" "send-keys C-k" "select-pane -U"; \
          tmux bind-key -n C-l if-shell "$is_vim" "send-keys C-l" "select-pane -R"; \
          tmux display-message "Prefix and navigation enabled"; \
        else                                     \
          tmux set -g prefix None;               \
          tmux set -g @prefix-enabled 0;         \
          tmux unbind -n S-Left;                 \
          tmux unbind -n S-Right;                \
          tmux unbind -n C-h;                    \
          tmux unbind -n C-j;                    \
          tmux unbind -n C-k;                    \
          tmux unbind -n C-l;                    \
          tmux unbind -n C-\\;                   \
          tmux display-message "Prefix and navigation disabled"; \
        fi'

      # Status line indicators for passthrough and sync modes
      set -g status-left "#{?#{==:#{prefix},None},🔒,}#{?synchronize-panes, 🔄,}"

      # Vi copy-mode keybindings
      bind-key -T copy-mode-vi v send-keys -X begin-selection
      bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
      bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel

      # Split panes in current path
      bind '"' split-window -v -c "#{pane_current_path}"
      bind % split-window -h -c "#{pane_current_path}"

      # Custom tool bindings
      bind-key -r t run-shell "tmux neww tms"
      bind-key -r f1 run-shell "tmux neww cht"

      # Toggle panes synchronization
      bind S setw synchronize-panes
    '';
  };
}
