{ ... }:

{
  programs.nixvim = {
    autoCmd = [
      {
        event = "BufWritePost";
        pattern = [ "*.py" "*.js" "*.ts" "*.jsx" "*.tsx" "*.vue" "*.css" "*.html" "*.go" "*.lua" "*.toml" ];
        callback = {
          __raw = "function() vim.cmd('lua vim.lsp.buf.format()') end";
        };
        group = "AutoFormat";
      }
      {
        event = "LspAttach";
        callback = {
          __raw = ''
            function(args)
              local client = vim.lsp.get_client_by_id(args.data.client_id)
              if client == nil then
                return
              end
              if client.name == "ruff" then
                client.server_capabilities.hoverProvider = false
              end
            end
          '';
        };
        group = "lsp_attach_disable_ruff_hover";
        desc = "LSP: Disable hover capability from Ruff";
      }
    ];

    # Define autocmd groups
    augroups = {
      AutoFormat = {
        clear = true;
      };
      lsp_attach_disable_ruff_hover = {
        clear = true;
      };
    };
  };
}
