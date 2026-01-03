{ pkgs, ... }:

{
  programs.nixvim = {
    plugins.lsp = {
      enable = true;

      servers = {
        # Python
        pyright = {
          enable = true;
          settings = {
            pyright = {
              disableOrganizeImports = true;
            };
            python = {
              analysis = {
                ignore = [ "*" ];
              };
            };
          };
        };

        ruff = {
          enable = true;
          # Disable hover (configured in autocmds)
        };

        # Go
        gopls = {
          enable = true;
          settings = {
            gopls = {
              gofumpt = true;
              codelenses = {
                gc_details = false;
                generate = true;
                regenerate_cgo = true;
                run_govulncheck = true;
                test = true;
                tidy = true;
                upgrade_dependency = true;
                vendor = true;
              };
              hints = {
                assignVariableTypes = true;
                compositeLiteralFields = true;
                compositeLiteralTypes = true;
                constantValues = true;
                functionTypeParameters = true;
                parameterNames = true;
                rangeVariableTypes = true;
              };
              experimentalPostfixCompletions = true;
              analyses = {
                unusedparams = true;
                shadow = true;
              };
              staticcheck = true;
            };
          };
        };

        # TypeScript (from lazyvim.json)
        ts-language-server = {
          enable = true;
        };

        # HTML/CSS/JSON
        html = {
          enable = true;
        };
        cssls = {
          enable = true;
        };
        jsonls = {
          enable = true;
        };

        # Lua
        lua-ls = {
          enable = true;
          settings = {
            Lua = {
              workspace = {
                checkThirdParty = false;
              };
              completion = {
                callSnippet = "Replace";
              };
            };
          };
        };
      };

      # Keymaps for LSP
      keymaps.lspBuf = {
        K = "hover";
        gd = "definition";
        gD = "declaration";
        gi = "implementation";
        gt = "type_definition";
        gn = "rename";
        ca = "code_action";
        f = "format";
      };

      keymaps.diagnostic = {
        "[d" = "goto_prev";
        "]d" = "goto_next";
      };
    };

    # Install language server packages
    extraPackages = with pkgs; [
      # Python LSPs
      pyright
      ruff

      # Go LSP
      gopls
      gofumpt

      # TypeScript/JavaScript LSP
      typescript-language-server

      # Web development LSPs
      vscode-langservers-extracted  # html, css, json
    ];
  };
}
