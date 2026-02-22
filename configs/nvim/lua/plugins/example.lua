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
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        javascript = { "prettier" },
        javascriptreact = { "prettier" },
        typescript = { "prettier" },
        typescriptreact = { "prettier" },
        vue = { "prettier" },
      },
    },
  },

  {
    "neovim/nvim-lspconfig",
    opts = {
      -- Options for vim.diagnostic.config()
      diagnostics = {
        underline = true,
        update_in_insert = false,
        virtual_text = false,
        inline = true,
        severity_sort = true,
      },
      -- Register the servers you want
      servers = {
        -- ========================================================================
        -- PYTHON CONFIGURATION (Pyright + Ruff)
        -- ========================================================================
        pyright = {
          -- 1. Disable features handled by Ruff to avoid conflicts
          settings = {
            pyright = {
              disableOrganizeImports = true, -- Using Ruff for this
            },
            python = {
              analysis = {
                typeCheckingMode = "basic", -- "off" disables too much, "basic" is standard

                -- 1. Disable stylistic/linter rules (let Ruff handle these)
                reportUnusedImport = "none",
                reportUnusedClass = "none",
                reportUnusedFunction = "none",
                reportUnusedVariable = "none",
                reportDuplicateImport = "none",

                -- 2. Enable critical type/validity checks (what you actually want)
                reportMissingImports = "error",
                reportUndefinedVariable = "error",
                reportGeneralTypeIssues = "error",   -- Helps with type mismatches
                reportOptionalMemberAccess = "none", -- Set to "error" if you want strict null checks
              },
            },
          },
          -- 2. DYNAMIC VENV DETECTION
          -- This function runs before the LSP attaches to the buffer.
          -- It finds the venv relative to the *current file's project root*, not just cwd.
          on_init = function(client)
            local function get_venv_path(root_dir)
              -- Try to find .venv, venv, or env in the project root
              for _, name in ipairs({ ".venv", "venv", "env" }) do
                local venv = root_dir .. "/" .. name
                if vim.fn.isdirectory(venv) == 1 then
                  local python_bin = venv .. "/bin/python"
                  if vim.fn.executable(python_bin) == 1 then
                    return python_bin
                  end
                end
              end
              return nil
            end

            -- If the client has a root directory, try to find the venv there
            if client.config.root_dir then
              local python_path = get_venv_path(client.config.root_dir)
              -- Fallback to system python or active virtual_env if not found locally
              if not python_path and vim.env.VIRTUAL_ENV then
                python_path = vim.env.VIRTUAL_ENV .. "/bin/python"
              end

              -- Inject the python path into the config
              if python_path then
                client.config.settings.python.pythonPath = python_path
                -- Notify the server of the configuration change
                client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
              end
            end
          end,
        },

        -- Ruff (Linter & Formatter)
        -- Latest LazyVim uses the native "ruff" server (written in Rust), replacing "ruff_lsp"
        ruff = {
          cmd_env = { RUFF_TRACE = "messages" },
          init_options = {
            settings = {
              logLevel = "error",
            },
          },
          keys = {
            {
              "<leader>co",
              function()
                vim.lsp.buf.code_action({
                  apply = true,
                  context = {
                    only = { "source.organizeImports" },
                    diagnostics = {},
                  },
                })
              end,
              desc = "Organize Imports",
            },
          },
        },

        -- ========================================================================
        -- REACT / TYPESCRIPT / WEB CONFIGURATION
        -- ========================================================================

        -- "vtsls" is the new standard for LazyVim (superior to tsserver/ts_ls)
        -- It handles JS, TS, JSX, and TSX
        vtsls = {
          filetypes = {
            "javascript",
            "javascriptreact",
            "javascript.jsx",
            "typescript",
            "typescriptreact",
            "typescript.tsx",
            "vue",
          },
          settings = {
            complete_function_calls = true,
            vtsls = {
              enableMoveToFileCodeAction = true,
              autoUseWorkspaceTsdk = true,
              experimental = {
                completion = {
                  enableServerSideFuzzyMatch = true,
                },
              },
              tsserver = {
                globalPlugins = {
                  {
                    name = "@vue/typescript-plugin",
                    location = vim.fn.expand("~/.local/share/nvim/mason/packages/vue-language-server/node_modules/@vue/language-server"),
                    languages = { "vue" },
                    configNamespace = "typescript",
                    enableForWorkspaceTypeScriptVersions = true,
                  },
                },
              },
            },
            typescript = {
              updateImportsOnFileMove = { enabled = "always" },
              suggest = {
                completeFunctionCalls = true,
              },
              inlayHints = {
                parameterNames = { enabled = "literals" },
                parameterTypes = { enabled = true },
                variableTypes = { enabled = true },
                propertyDeclarationTypes = { enabled = true },
                functionLikeReturnTypes = { enabled = true },
                enumMemberValues = { enabled = true },
              },
            },
          },
        },

        -- HTML Support
        html = {
          filetypes = { "html", "javascript", "javascriptreact", "typescriptreact" },
        },

        -- CSS Support
        cssls = {},

        -- (Optional) Emmet for fast HTML/CSS writing
        emmet_language_server = {
          filetypes = { "html", "css", "javascriptreact", "typescriptreact", "vue", "eruby" },
        },

        -- Vue.js Support
        vue_ls = {
          init_options = {
            vue = {
              -- Disable "hybrid mode" manually if you encounter dual-server issues,
              -- but standard Volar 2.0+ works best with it enabled (default).
              -- hybridMode = true, 
            },
          },
        },
      },

      -- Ensure these are installed via Mason
      setup = {
        -- This logic ensures that if you are using 'vtsls', standard 'ts_ls' is disabled to avoid conflicts
        ts_ls = function()
          return true -- Prevent ts_ls from loading since we use vtsls
        end,
      },
    },
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
        "vue",
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

  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    build = "cd app && npm install",
    init = function()
      vim.g.mkdp_filetypes = { "markdown" }
    end,
    ft = { "markdown" },
    keys = {
      { "<leader>m", "<cmd>MarkdownPreviewToggle<cr>", desc = "Markdown Preview", ft = "markdown" },
    },
  },

  {
    "antosha417/nvim-lsp-file-operations",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = function()
      require("lsp-file-operations").setup()
    end,
  },
}
