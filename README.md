# NixOS Configuration

Personal NixOS system configuration for a, managed with [Home Manager](https://github.com/nix-community/home-manager) as a NixOS module.

## Structure

```
/etc/nixos/
├── configuration.nix          # Main system configuration, imports everything
├── hardware-configuration.nix # Auto-generated, excluded from git
├── system/                    # System-level configurations
└── home/
    ├── shared/                # Shared configs, reusable across users
    │   ├── tmux.nix           # tmux
    │   └── nvim/              # Neovim (LazyVim-based)
    │       ├── nvim.nix       # Home Manager module
    │       ├── init.lua
    │       └── lua/
    │           ├── config/    # options, keymaps, autocmds
    │           └── plugins/   # plugin specs
    └── users/
        └── yuda/
            └── default.nix   # User-level Home Manager config, imports shared/*
```

## Apply

```bash
sudo nixos-rebuild switch
```

## Fresh Install

1. Install NixOS and run `nixos-generate-config` to generate `hardware-configuration.nix`
2. Clone this repo into `/etc/nixos/`
3. Run `sudo nixos-rebuild switch`
