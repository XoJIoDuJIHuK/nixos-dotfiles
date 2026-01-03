{ pkgs, ... }:

{
  programs.nixvim = {
    plugins.treesitter = {
      enable = true;

      settings = {
        highlight = {
          enable = true;
        };
        indent = {
          enable = true;
        };
      };

      grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
        bash
        go
        gomod
        gosum
        html
        javascript
        json
        lua
        markdown
        markdown-inline
        python
        tsx
        typescript
        vim
        vimdoc
        yaml
      ];
    };
  };
}
