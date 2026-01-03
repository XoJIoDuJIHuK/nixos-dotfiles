{ config, pkgs, ... }:

{
  imports = [
    ./core.nix
    ./keymaps.nix
    ./autocmds.nix
    ./plugins/lsp.nix
    ./plugins/dap.nix
    ./plugins/telescope.nix
    ./plugins/treesitter.nix
    ./plugins/theme.nix
    ./plugins/ui.nix
    ./plugins/editor.nix
  ];

  programs.nixvim = {
    enable = true;
    defaultEditor = true;

    viAlias = true;
    vimAlias = true;

    # Performance settings
    performance = {
      combinePlugins = {
        enable = true;
      };
    };
  };
}
