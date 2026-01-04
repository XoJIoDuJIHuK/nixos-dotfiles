-- since this is just an example spec, don't actually load anything here and return an empty spec
-- stylua: ignore
-- if true then return {} end

-- every spec file under the "plugins" directory will be loaded automatically by lazy.nvim
--
-- In your plugin files, you can:
-- * add extra plugins
-- * disable/enabled LazyVim plugins
-- * override the configuration of LazyVim plugins
return {
  -- use mini.starter instead of alpha
  -- { import = "lazyvim.plugins.extras.ui.mini-starter" },

  -- add jsonls and schemastore packages, and setup treesitter for json, json5 and jsonc
  -- { import = "lazyvim.plugins.extras.lang.json" },

  -- change trouble config
  {
    "folke/trouble.nvim",
    -- opts will be merged with the parent spec
    opts = { use_diagnostic_signs = true },
  },

  -- change some telescope options and a keymap to browse plugin files
  {
    "nvim-telescope/telescope.nvim",
    keys = {
      -- add a keymap to browse plugin files
      -- stylua: ignore
      {
        "<leader>fp",
        function() require("telescope.builtin").find_files({ cwd = require("lazy.core.config").options.root }) end,
        desc = "Find Plugin File",
      },
    },
    -- change some options
    opts = {
      defaults = {
        layout_strategy = "horizontal",
        layout_config = { prompt_position = "top" },
        sorting_strategy = "ascending",
        winblend = 0,
      },
    },
  },

  {
    "nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile", "VeryLazy" }, -- Load before LazyFile and ensure it loads
    dependencies = {
      "mason-org/mason.nvim",
      "mason-org/mason-lspconfig.nvim",
    },
    config = function()
      local mason = require("mason")
      mason.setup()
      local mason_lspconfig = require("mason-lspconfig")

      local function get_venv_python()
        local cwd = vim.fn.getcwd()
        for _, name in ipairs({ ".venv", "venv", "env" }) do
          local py = cwd .. "/" .. name .. "/bin/python"
          if vim.fn.executable(py) == 1 then
            return py
          end
        end
        -- you could also check VIRTUAL_ENV:
        if vim.env.VIRTUAL_ENV then
          return vim.env.VIRTUAL_ENV .. "/bin/python"
        end
        return nil
      end

      mason_lspconfig.setup({
        ensure_installed = {
          "ruff",
          "pyright",
          "gopls",
        },
        automatic_enable = true,
      })

      -- Setup LSP servers using the new API
      require("lspconfig").pyright.setup({
        settings = {
          pyright = {
            disableOrganizeImports = true,
          },
          python = {
            pythonPath = get_venv_python() or vim.fn.exepath("python3") or vim.fn.exepath("python"),
            analysis = {
              ignore = { '*' },
            },
          },
        },
      })

      require("lspconfig").ruff.setup({})

      -- Setup gopls for Go
      require("lspconfig").gopls.setup({
        settings = {
          gopls = {
            gofumpt = true,
            codelenses = {
              gc_details = false,
              generate = true,
              regenerate_cgo = true,
              run_govulncheck = true,
              test = true,
              tidy = true,
              upgrade_dependency = true,
              vendor = true,
            },
            hints = {
              assignVariableTypes = true,
              compositeLiteralFields = true,
              compositeLiteralTypes = true,
              constantValues = true,
              functionTypeParameters = true,
              parameterNames = true,
              rangeVariableTypes = true,
            },
            experimentalPostfixCompletions = true,
            analyses = {
              unusedparams = true,
              shadow = true,
            },
            staticcheck = true,
          },
        },
      })
    end,
  },


  -- add more treesitter parsers
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "bash",
        "go",
        "gomod",
        "gosum",
        "html",
        "javascript",
        "json",
        "lua",
        "markdown",
        "markdown_inline",
        "python",
        "query",
        "regex",
        "tsx",
        "typescript",
        "vim",
        "yaml",
      },
    },
  },

  -- the opts function can also be used to change the default opts:
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = function(_, opts)
      table.insert(opts.sections.lualine_x, {
        function()
          return "😄"
        end,
      })
    end,
  },

  {
    "kndndrj/nvim-dbee",
    dependencies = {
      "MunifTanjim/nui.nvim",
    },
    build = function()
      -- Install tries to automatically detect the install method.
      -- if it fails, try calling it with one of these parameters:
      --    "curl", "wget", "bitsadmin", "go"
      require("dbee").install()
    end,
    config = function()
      require("dbee").setup( --[[optional config]])
    end,
  },

  {
    "coder/claudecode.nvim",
    dependencies = { "folke/snacks.nvim" },
    config = true,
    keys = {
      { "<leader>a",  nil,                              desc = "AI/Claude Code" },
      { "<leader>ac", "<cmd>ClaudeCode<cr>",            desc = "Toggle Claude" },
      { "<leader>af", "<cmd>ClaudeCodeFocus<cr>",       desc = "Focus Claude" },
      { "<leader>ar", "<cmd>ClaudeCode --resume<cr>",   desc = "Resume Claude" },
      { "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
      { "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Claude model" },
      { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>",       desc = "Add current buffer" },
      { "<leader>as", "<cmd>ClaudeCodeSend<cr>",        mode = "v",                  desc = "Send to Claude" },
      {
        "<leader>as",
        "<cmd>ClaudeCodeTreeAdd<cr>",
        desc = "Add file",
        ft = { "NvimTree", "neo-tree", "oil", "minifiles", "netrw" },
      },
      -- Diff management
      { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
      { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>",   desc = "Deny diff" },
    },
  },

  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
      "theHamsta/nvim-dap-virtual-text",
      "mfussenegger/nvim-dap-python",
    },
    keys = {
      { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: ")) end, desc = "Breakpoint Condition" },
      { "<leader>db", function() require("dap").toggle_breakpoint() end,                                    desc = "Toggle Breakpoint" },
      { "<leader>dc", function() require("dap").continue() end,                                             desc = "Continue" },
      { "<leader>dC", function() require("dap").run_to_cursor() end,                                        desc = "Run to Cursor" },
      -- { "<leader>dg", function() require("dap").goto_() end,                                                desc = "Go to Line (No Execute)" },
      { "<leader>di", function() require("dap").step_into() end,                                            desc = "Step Into" },
      { "<leader>dj", function() require("dap").down() end,                                                 desc = "Down" },
      { "<leader>dk", function() require("dap").up() end,                                                   desc = "Up" },
      { "<leader>dl", function() require("dap").run_last() end,                                             desc = "Run Last" },
      { "<leader>do", function() require("dap").step_out() end,                                             desc = "Step Out" },
      { "<leader>dO", function() require("dap").step_over() end,                                            desc = "Step Over" },
      { "<leader>dp", function() require("dap").pause() end,                                                desc = "Pause" },
      -- { "<leader>dr", function() require("dap").repl.toggle() end,                                          desc = "Toggle REPL" },
      { "<leader>ds", function() require("dap").session() end,                                              desc = "Session" },
      { "<leader>dt", function() require("dap").terminate() end,                                            desc = "Terminate" },
      -- { "<leader>dw", function() require("dap.ui.widgets").hover() end,                                     desc = "Widgets" },
      { "<leader>du", function() require("dapui").toggle({ reset = true }) end,                             desc = "Dap UI" },
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")
      local dapvt = require("nvim-dap-virtual-text")
      dap.set_log_level('DEBUG')

      -- UI setup (nice windows)
      dapui.setup({
        layouts = {
          {
            elements = {
              { id = "scopes",      size = 0.33 },
              { id = "breakpoints", size = 0.33 },
              { id = "stacks",      size = 0.33 },
              -- { id = "watches",     size = 0.25 },
            },
            size = 40,
            position = "left",
          },
          {
            elements = { "repl", "console" },
            size = 0.25,
            position = "bottom",
          },
        },
      })

      -- Virtual text (inline variable values)
      dapvt.setup()

      -- Auto open/close UI
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open({ reset = true })
      end
      dap.listeners.before.event_terminated["dapui_config"] = dapui.close
      dap.listeners.before.event_exited["dapui_config"] = dapui.close

      ------------------------------------------------------------------
      -- PYTHON + DEBUGPY (remote attach to Docker)
      ------------------------------------------------------------------
      require("dap-python").setup("python") -- uses your current python (debugpy must be installed globally or in venv)

      -- You can also point to Mason's debugpy explicitly (recommended):
      -- require("dap-python").setup("~/.local/share/nvim/mason/packages/debugpy/venv/bin/python")

      table.insert(dap.configurations.python, {
        type = "python",
        request = "attach",
        name = "[Python] Attach to Docker",
        connect = {
          host = function() return vim.fn.input("Host → ", "127.0.0.1") end,
          port = function() return tonumber(vim.fn.input("Port → ", "5678")) end,
        },
        mode = "remote",
        cwd = "${workspaceFolder}",
        pathMappings = {
          {
            -- Change these two paths to match your setup!
            localRoot = "${workspaceFolder}", -- Path on your host machine (where Neovim is open)
            remoteRoot = "./",                -- Path inside the Docker container
            -- Common alternatives:
            -- remoteRoot = "/usr/src/app"
            -- remoteRoot = "/code"
            -- remoteRoot = "/workspace"
          },
        },
        justMyCode = false, -- set to true if you don't want to step into venv/site-packages
      })

      -- Add configuration for launching current file with prompt for args
      table.insert(dap.configurations.python, {
        type = "python",
        request = "launch",
        name = "Python: Current file with custom args",
        program = "${file}",
        args = function()
          local args_input = vim.fn.input("Arguments (space-separated, default: --incremental) → ", "--incremental")
          if args_input == "" then
            return { "--incremental" }
          end
          -- Split by spaces, handling quoted arguments
          local args = {}
          for arg in args_input:gmatch('[^" ]+|"[^"]*"') do
            if arg:sub(1, 1) == '"' and arg:sub(-1) == '"' then
              table.insert(args, arg:sub(2, -2)) -- Remove quotes
            else
              table.insert(args, arg)
            end
          end
          return args
        end,
        console = "integratedTerminal",
        justMyCode = false,
        env = {
          PYTHONPATH = "${workspaceFolder}"
        },
        cwd = "${workspaceFolder}",
      })

      -- Icons (optional, works with nerd fonts)
      vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })

      -- for name, sign in pairs(require("user.icons").dap) do
      --   vim.fn.sign_define("Dap" .. name, { text = sign, texthl = "Dap" .. name, numhl = "" })
      -- end
    end,
  },
}
