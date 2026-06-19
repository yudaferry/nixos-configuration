{ ... }:
{
  home.file.".config/lazygit/config.yml" = {
    force = true;
    text = ''
      os:
        editPreset: nvim
      git:
        allBranchesLogCmds:
          - git log --graph --all --date-order --color=always --decorate --pretty=format:'%C(white)%h%C(auto)%d %C(blue)%<(12,trunc)%an %C(reset)%<(40,trunc)%s %C(green)%cr'
          - git log --graph --all --color=always --abbrev-commit --decorate --date=relative --pretty=medium
    '';
  };
}
