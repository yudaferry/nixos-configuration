{ pkgs, ... }:
{
  programs.tmux = {
    enable = true;
    extraConfig = ''
      set -g default-terminal "tmux-256color"
      setw -g mode-keys vi
      set -g base-index 1
      set -g pane-base-index 1
      set -g renumber-windows on
      set -s escape-time 0
      set -g mouse off
      set -g set-clipboard on
      bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "wl-copy"
    '';
  };
}
