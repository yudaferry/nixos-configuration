{ pkgs, ... }:
{
  home-manager.users.yuda = { lib, ... }: {
    home.stateVersion = "25.11";

    imports = [
      ../../shared/tmux.nix
      ../../shared/nvim/nvim.nix
    ];

    home.packages = with pkgs; [
      gnomeExtensions.vitals
      uv
      python3
    ];

    home.activation.installGraphify = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      ${pkgs.uv}/bin/uv tool install graphifyy --quiet --python ${pkgs.python3}/bin/python3
    '';

    dconf.settings = {
      "org/gnome/shell" = {
        enabled-extensions = [ "Vitals@CoreCoding.com" ];
      };
      "org/gnome/shell/extensions/vitals" = {
        show-cpu = true;
        show-memory = true;
        show-temperature = true;
        show-voltage = false;
        show-fan = false;
        show-network = false;
        show-storage = false;
        show-battery = false;
        show-system = false;
        hot-sensors = [ "_processor_usage_" "_memory_usage_" "_temperature_average_" ];
      };
    };

    systemd.user.services.rclone-gdrive = {
      Unit = {
        Description = "rclone Google Drive mount";
        After = [ "network-online.target" ];
        Wants = [ "network-online.target" ];
      };
      Service = {
        Type = "notify";
        ExecStartPre = "/run/current-system/sw/bin/mkdir -p %h/GoogleDrive";
        ExecStart = "${pkgs.rclone}/bin/rclone mount gdrive: %h/GoogleDrive --vfs-cache-mode writes --vfs-cache-max-size 512M";
        ExecStop = "/run/wrappers/bin/fusermount -u %h/GoogleDrive";
        Restart = "on-failure";
        RestartSec = "10s";
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };
}
