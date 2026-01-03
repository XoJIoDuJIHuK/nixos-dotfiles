{ ... }:

{
  programs.nixvim = {
    colorschemes.tokyonight = {
      enable = true;
      settings = {
        style = "moon";
      };
    };
  };
}
