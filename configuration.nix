# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

let
  unstable = import (fetchTarball "https://nixos.org/channels/nixpkgs-unstable/nixexprs.tar.xz") {
    config.allowUnfree = true;
  };

  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/release-25.11.tar.gz";
in

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      "${home-manager}/nixos"
      ./home/users/yuda
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Jakarta";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;

    wireplumber.extraConfig."10-disable-stream-restore" = {
      "wireplumber.settings" = {
        "stream.restore-props" = false;
      };
    };

    # Force software volume control so master volume works correctly across all apps.
    # Hardware mixer on sof-hda-dsp only responds to mute/0%, not intermediate levels.
    wireplumber.extraConfig."20-soft-mixer" = {
      "monitor.alsa.rules" = [
        {
          matches = [ { "device.name" = "~alsa_card.pci-0000_00_1f.3.*"; } ];
          actions = {
            "update-props" = {
              "api.alsa.soft-mixer" = true;
            };
          };
        }
      ];
    };
  };

  # Fix: combo 3.5mm jack (mic-only plug) triggers auto-mute and silences speakers.
  # Disable the ALC287 codec's auto-mute so speakers work regardless of jack state.
  hardware.alsa.enablePersistence = true;
  systemd.services.alsa-disable-auto-mute = {
    description = "Disable ALSA Auto-Mute Mode for combo jack mic fix";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.alsa-utils}/bin/amixer -c sofhdadsp sset 'Auto-Mute Mode' Disabled";
      RemainAfterExit = true;
    };
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # CIDOO V65 keyboard - grant permission for VIA app
  services.udev.extraRules = ''
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="320f", ATTRS{idProduct}=="5055", MODE="0666"
  '';

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.yuda = {
    isNormalUser = true;
    description = "yuda";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    shell = pkgs.zsh;
    packages = with pkgs; [
    #  thunderbird
    ];
  };

  # Install firefox.
  programs.firefox.enable = true;
  programs.steam.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    gnomeExtensions.bluetooth-battery-meter


vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    google-chrome
    vscode
    unstable.zed-editor
    htop
    claude-code
    (pkgs.writeShellScriptBin "flameshot" ''
      tmpfile=$(mktemp /tmp/flameshot-XXXXXX.png)
      ${pkgs.flameshot}/bin/flameshot gui --raw > "$tmpfile"
      if [ -s "$tmpfile" ]; then
        ${pkgs.wl-clipboard}/bin/wl-copy --type image/png < "$tmpfile" &
        disown $!
      fi
      rm -f "$tmpfile"
    '')
    pkgs.xclip
    tailscale
    oh-my-zsh
    unstable.ollama-vulkan
    opencode
    git
    lazydocker
    lazygit
    gcc
    tree-sitter
    wl-clipboard
    rclone
    lm_sensors
    unzip
    curl
    cloudflare-warp
    bun
    jq
    sweethome3d.application
    p7zip
    baobab
  ];


  hardware.graphics.extraPackages = with pkgs; [
    intel-media-driver        # iHD driver — QuickSync encode + decode
    intel-compute-runtime     # Level Zero driver for Intel GPU compute
    intel-vaapi-driver        # legacy VA-API fallback
  ];

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  hardware.bluetooth.settings.General.Experimental = true;
  services.blueman.enable = true;
  environment.variables = {
    LIBVA_DRIVER_NAME = "iHD";
    OLLAMA_SCHED_SPREAD = "1";
    OLLAMA_KEEP_ALIVE = "30s";
    OLLAMA_NUM_PARALLEL = "1";
    OLLAMA_MAX_LOADED_MODELS = "1";
    OLLAMA_VULKAN = "1";
  };

  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
  ];

  programs.nix-ld.enable = true;

  programs.zsh = {
    enable = true;
    ohMyZsh = {
      enable = true;
      theme = "robbyrussell";
      plugins = [ "git" "sudo" ];
    };
    interactiveShellInit = ''
      export PATH="$HOME/.local/bin:$PATH"
    '';
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:
  services.tailscale.enable = true;
  services.cloudflare-warp.enable = true;
  virtualisation.docker.enable = true;

  system.activationScripts.binbash = lib.stringAfter [ "binsh" ] ''
    ln -sf ${pkgs.bash}/bin/bash /bin/bash
  '';

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  boot.kernel.sysctl."vm.swappiness" = 10;

  system.stateVersion = "25.11"; # Did you read the comment?

}
