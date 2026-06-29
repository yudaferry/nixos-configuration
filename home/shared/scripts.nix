{ pkgs, ... }:
{
  home.packages = [
    (pkgs.writeShellScriptBin "colony" ''
      COLONY_MAIN_KEY="COLONY_MAIN_PANE"
      COLONY_PEER_PREFIX="COLONY_PEER_"

      usage() {
        cat <<EOF
      colony — tmux workspace manager for multi-agent sessions

      Usage:
        colony register <name> [pane-id]   Register a pane with a name (auto-detects current pane if omitted)
        colony send <message> <name-or-id> Send message to a named pane
        colony split                        Split current pane (smart: vertical for main, horizontal for others)
        colony spawn <command> [name]       Split + run a command; auto-register new pane if name given
        colony close <name-or-id>          Kill a pane and unregister it
        colony list                         List all registered panes
        colony help                         Show this help

      Examples:
        colony register test1 %16
        colony register test2 %0
        colony send "hello" test2
        colony split
        colony spawn claude
        colony spawn opencode
        colony spawn kiro-cli
      EOF
      }

      current_pane() {
        ${pkgs.tmux}/bin/tmux display-message -p "#{pane_id}"
      }

      resolve_pane() {
        local target="$1"
        if [[ "$target" == %* ]]; then
          echo "$target"
          return
        fi
        local key="''${COLONY_PEER_PREFIX}''${target^^}"
        local pane_id
        pane_id=$(${pkgs.tmux}/bin/tmux show-environment -g "$key" 2>/dev/null | cut -d= -f2)
        if [[ -z "$pane_id" ]]; then
          echo "Error: no pane registered with name '$target'. Run: colony register $target <pane-id>" >&2
          exit 1
        fi
        echo "$pane_id"
      }

      do_register() {
        if [[ $# -lt 1 ]]; then
          echo "Error: register requires <name>" >&2
          exit 1
        fi
        local name="$1" pane_id="''${2:-$(current_pane)}"
        local key="''${COLONY_PEER_PREFIX}''${name^^}"
        ${pkgs.tmux}/bin/tmux set-environment -g "$key" "$pane_id"
        if ! ${pkgs.tmux}/bin/tmux show-environment -g "$COLONY_MAIN_KEY" &>/dev/null; then
          ${pkgs.tmux}/bin/tmux set-environment -g "$COLONY_MAIN_KEY" "$pane_id"
          echo "Registered: $name → $pane_id (main pane)"
        else
          echo "Registered: $name → $pane_id"
        fi
      }

      wait_for_pane() {
        local pane="$1"
        local timeout=30
        local elapsed=0
        while [[ $elapsed -lt $timeout ]]; do
          local cmd
          cmd=$(${pkgs.tmux}/bin/tmux display-message -t "$pane" -p "#{pane_current_command}" 2>/dev/null)
          if [[ "$cmd" != "zsh" && "$cmd" != "bash" && "$cmd" != "sh" && -n "$cmd" ]]; then
            sleep 1
            return 0
          fi
          sleep 0.5
          elapsed=$((elapsed + 1))
        done
        echo "Warning: pane $pane still at shell after ${timeout}s, sending anyway" >&2
      }

      do_send() {
        if [[ $# -lt 2 ]]; then
          echo "Error: send requires <message> and <pane name or ID>" >&2
          exit 1
        fi
        local message="$1"
        local pane
        pane=$(resolve_pane "$2")
        local pane_content
        pane_content=$(${pkgs.tmux}/bin/tmux capture-pane -t "$pane" -p 2>/dev/null)
        if echo "$pane_content" | grep -q "OpenCode\|ctrl+p commands\|tab agents"; then
          ${pkgs.tmux}/bin/tmux set-buffer "$message"
          ${pkgs.tmux}/bin/tmux paste-buffer -p -t "$pane"
          sleep 0.3
          ${pkgs.tmux}/bin/tmux send-keys -t "$pane" Enter
        else
          ${pkgs.tmux}/bin/tmux send-keys -l -t "$pane" "$message"
          sleep 0.3
          ${pkgs.tmux}/bin/tmux send-keys -t "$pane" Enter
        fi
      }

      do_split() {
        local cmd="$1"
        local register_name="$2"
        local current
        current=$(current_pane)
        local main
        main=$(${pkgs.tmux}/bin/tmux show-environment -g "$COLONY_MAIN_KEY" 2>/dev/null | cut -d= -f2)

        local wrapped_cmd=""
        [[ -n "$cmd" ]] && wrapped_cmd="zsh -c '''${cmd}; exec zsh'"

        local new_pane
        if [[ "$current" == "$main" ]]; then
          if [[ -n "$wrapped_cmd" ]]; then
            new_pane=$(${pkgs.tmux}/bin/tmux split-window -h -d -P -F "#{pane_id}" -t "$current" "$wrapped_cmd")
          else
            new_pane=$(${pkgs.tmux}/bin/tmux split-window -h -d -P -F "#{pane_id}" -t "$current")
          fi
        else
          if [[ -n "$wrapped_cmd" ]]; then
            new_pane=$(${pkgs.tmux}/bin/tmux split-window -v -d -P -F "#{pane_id}" -t "$current" "$wrapped_cmd")
          else
            new_pane=$(${pkgs.tmux}/bin/tmux split-window -v -d -P -F "#{pane_id}" -t "$current")
          fi
        fi

        if [[ -n "$register_name" ]]; then
          do_register "$register_name" "$new_pane"
          local main_name
          main_name=$(${pkgs.tmux}/bin/tmux show-environment -g | grep "^''${COLONY_PEER_PREFIX}" | while IFS= read -r line; do
            local n="''${line#''${COLONY_PEER_PREFIX}}"; n="''${n%%=*}"; id="''${line#*=}"
            local m; m=$(${pkgs.tmux}/bin/tmux show-environment -g "$COLONY_MAIN_KEY" 2>/dev/null | cut -d= -f2)
            [[ "$id" == "$m" ]] && echo "''${n,,}" && break
          done)
          [[ -z "$main_name" ]] && main_name="test1"
          (
            wait_for_pane "$new_pane"
            ${pkgs.tmux}/bin/tmux send-keys -t "$new_pane" "You are colony agent '''${register_name}' (pane ''${new_pane}). The orchestrator is '''${main_name}'. Reply to messages using: colony send \"your reply\" ''${main_name}"
            sleep 0.3
            ${pkgs.tmux}/bin/tmux send-keys -t "$new_pane" Enter
          ) &
        else
          echo "$new_pane"
        fi
      }

      do_close() {
        if [[ -z "$1" ]]; then
          echo "Error: close requires <name or pane-id>" >&2
          exit 1
        fi
        local pane
        pane=$(resolve_pane "$1")
        ${pkgs.tmux}/bin/tmux kill-pane -t "$pane"
        echo "Closed: $1 ($pane)"
        local key="''${COLONY_PEER_PREFIX}''${1^^}"
        ${pkgs.tmux}/bin/tmux set-environment -g -u "$key" 2>/dev/null || true
      }

      do_list() {
        local main
        main=$(${pkgs.tmux}/bin/tmux show-environment -g "$COLONY_MAIN_KEY" 2>/dev/null | cut -d= -f2)
        echo "Registered panes:"
        ${pkgs.tmux}/bin/tmux show-environment -g | grep "^''${COLONY_PEER_PREFIX}" | while IFS= read -r line; do
          local name id tag
          name="''${line#''${COLONY_PEER_PREFIX}}"
          name="''${name%%=*}"
          id="''${line#*=}"
          tag=""
          [[ "$id" == "$main" ]] && tag=" (main)"
          printf "  %-20s %s%s\n" "''${name,,}" "$id" "$tag"
        done
      }

      case "$1" in
        help|--help|-h|"")
          usage; exit 0 ;;
        register)
          shift; do_register "$@" ;;
        send)
          shift; do_send "$@" ;;
        split)
          do_split ;;
        spawn)
          if [[ -z "$2" ]]; then
            echo "Error: spawn requires a command (e.g. colony spawn claude)" >&2
            exit 1
          fi
          do_split "$2" "$3" ;;
        close)
          shift; do_close "$@" ;;
        list)
          do_list ;;
        *)
          echo "Error: unknown command '$1'" >&2
          echo "Run 'colony help' for usage." >&2
          exit 1 ;;
      esac
    '')
  ];
}
