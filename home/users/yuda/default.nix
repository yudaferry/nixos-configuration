{ pkgs, ... }:
{
  home-manager.users.yuda = {
    home.stateVersion = "25.11";

    imports = [
      ../../shared/tmux.nix
      ../../shared/nvim/nvim.nix
    ];
  };
}
