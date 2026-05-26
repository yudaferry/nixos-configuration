{ pkgs, ... }:
{
  programs.tmux = {
    enable = true;
    extraConfig = ''
      setw -g mode-keys vi
      set -g base-index 1
      set -g pane-base-index 1
      set -g renumber-windows on
      set -s escape-time 0
      set -g set-clipboard on
      bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "wl-copy"
      bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel "wl-copy"
    '';
  };
}
