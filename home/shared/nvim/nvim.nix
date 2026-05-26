{ pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  xdg.configFile = {
    "nvim/init.lua".source = ./init.lua;
    "nvim/lazyvim.json".source = ./lazyvim.json;
    "nvim/.neoconf.json".source = ./.neoconf.json;
    "nvim/stylua.toml".source = ./stylua.toml;
    "nvim/lua/config/autocmds.lua".source = ./lua/config/autocmds.lua;
    "nvim/lua/config/keymaps.lua".source = ./lua/config/keymaps.lua;
    "nvim/lua/config/lazy.lua".source = ./lua/config/lazy.lua;
    "nvim/lua/config/options.lua".source = ./lua/config/options.lua;
    "nvim/lua/plugins/color-scheme.lua".source = ./lua/plugins/color-scheme.lua;
    "nvim/lua/plugins/fzf-lua.lua".source = ./lua/plugins/fzf-lua.lua;
    "nvim/lua/plugins/gitgraph.lua".source = ./lua/plugins/gitgraph.lua;
    "nvim/lua/plugins/render-markdown.lua".source = ./lua/plugins/render-markdown.lua;
  };
}
