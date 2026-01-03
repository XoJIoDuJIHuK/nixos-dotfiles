{ ... }:

{
  programs.nixvim = {
    plugins = {
      # Flash (for quick jumping)
      flash = {
        enable = true;
      };

      # Git integration
      gitsigns = {
        enable = true;
      };

      # TODO comments
      todo-comments = {
        enable = true;
      };

      # Grug-far (search and replace)
      grug-far = {
        enable = true;
      };

      # Mini plugins
      mini = {
        enable = true;
        mockDevIcons = true;
        modules = {
          pairs = {};
          ai = {};
        };
      };

      # Autopairs
      nvim-autopairs = {
        enable = true;
      };

      # Completion
      blink-cmp = {
        enable = true;
        settings = {
          sources = {
            default = [ "lsp" "path" "snippets" "buffer" ];
          };
        };
      };

      # Snippets
      friendly-snippets = {
        enable = true;
      };

      # Database explorer
      dbee = {
        enable = true;
      };

      # Persistence (session management)
      persistence = {
        enable = true;
      };
    };

    # Claude Code integration - keymaps need to be set up
    extraLuaConfig = ''
      vim.keymap.set("n", "<leader>a", nil, { desc = "AI/Claude Code" })
      vim.keymap.set("n", "<leader>ac", "<cmd>ClaudeCode<cr>", { desc = "Toggle Claude" })
      vim.keymap.set("n", "<leader>af", "<cmd>ClaudeCodeFocus<cr>", { desc = "Focus Claude" })
      vim.keymap.set("n", "<leader>ar", "<cmd>ClaudeCode --resume<cr>", { desc = "Resume Claude" })
      vim.keymap.set("n", "<leader>aC", "<cmd>ClaudeCode --continue<cr>", { desc = "Continue Claude" })
      vim.keymap.set("n", "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", { desc = "Add current buffer" })
      vim.keymap.set("v", "<leader>as", "<cmd>ClaudeCodeSend<cr>", { desc = "Send to Claude" })
      -- Diff management
      vim.keymap.set("n", "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", { desc = "Accept diff" })
      vim.keymap.set("n", "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", { desc = "Deny diff" })
    '';
  };
}
