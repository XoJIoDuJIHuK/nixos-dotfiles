{ pkgs, ... }:

{
  programs.nixvim = {
    plugins.dap = {
      enable = true;

      adapters = {
        python = {
          __raw = ''
            {
              type = "executable";
              command = "${pkgs.python3Packages.debugpy}/bin/python";
              args = { "-m", "debugpy.adapter" };
            }
          '';
        };
      };

      configurations = {
        python = [
          {
            type = "python";
            request = "attach";
            name = "[Python] Attach to Docker";
            connect = {
              host = {
                __raw = "function() return vim.fn.input('Host → ', '127.0.0.1') end";
              };
              port = {
                __raw = "function() return tonumber(vim.fn.input('Port → ', '5678')) end";
              };
            };
            mode = "remote";
            cwd = "\${workspaceFolder}";
            pathMappings = [
              {
                localRoot = "\${workspaceFolder}";
                remoteRoot = "./";
              }
            ];
            justMyCode = false;
          }
          {
            type = "python";
            request = "launch";
            name = "Python: Current file with custom args";
            program = "\${file}";
            args = {
              __raw = ''
                function()
                  local args_input = vim.fn.input("Arguments (space-separated, default: --incremental) → ", "--incremental")
                  if args_input == "" then
                    return { "--incremental" }
                  end
                  local args = {}
                  for arg in args_input:gmatch('[^" ]+|"[^"]*"') do
                    if arg:sub(1, 1) == '"' and arg:sub(-1) == '"' then
                      table.insert(args, arg:sub(2, -2))
                    else
                      table.insert(args, arg)
                    end
                  end
                  return args
                end
              '';
            };
            console = "integratedTerminal";
            justMyCode = false;
            env = {
              PYTHONPATH = "\${workspaceFolder}";
            };
            cwd = "\${workspaceFolder}";
          }
        ];
      };

      signs = {
        DapStopped = { text = "󰁕 "; texthl = "DapStopped"; linehl = "DapStoppedLine"; };
        DapBreakpoint = { text = " "; texthl = "DapBreakpoint"; };
        DapBreakpointCondition = { text = " "; texthl = "DapBreakpointCondition"; };
        DapBreakpointRejected = { text = " "; texthl = "DapBreakpointRejected"; };
        DapLogPoint = { text = ".>"; texthl = "DapLogPoint"; };
      };

      keymaps = {
        "<leader>dB" = {
          action = "set_breakpoint";
          lua = true;
          desc = "Breakpoint Condition";
        };
        "<leader>db" = {
          action = "toggle_breakpoint";
          desc = "Toggle Breakpoint";
        };
        "<leader>dc" = {
          action = "continue";
          desc = "Continue";
        };
        "<leader>dC" = {
          action = "run_to_cursor";
          desc = "Run to Cursor";
        };
        "<leader>di" = {
          action = "step_into";
          desc = "Step Into";
        };
        "<leader>dj" = {
          action = "down";
          desc = "Down";
        };
        "<leader>dk" = {
          action = "up";
          desc = "Up";
        };
        "<leader>dl" = {
          action = "run_last";
          desc = "Run Last";
        };
        "<leader>do" = {
          action = "step_out";
          desc = "Step Out";
        };
        "<leader>dO" = {
          action = "step_over";
          desc = "Step Over";
        };
        "<leader>dp" = {
          action = "pause";
          desc = "Pause";
        };
        "<leader>ds" = {
          action = "session";
          desc = "Session";
        };
        "<leader>dt" = {
          action = "terminate";
          desc = "Terminate";
        };
      };
    };

    plugins.dap-ui = {
      enable = true;

      floatingMappings = {
        expand = "<CR>";
        open = "o";
        remove = "d";
        edit = "e";
        repl = "r";
        toggle = "t";
      };

      layouts = [
        {
          elements = [
            { id = "scopes"; size = 0.33; }
            { id = "breakpoints"; size = 0.33; }
            { id = "stacks"; size = 0.33; }
          ];
          size = 40;
          position = "left";
        }
        {
          elements = [
            { id = "repl"; size = 1.0; }
          ];
          size = 10;
          position = "bottom";
        }
      ];
    };

    plugins.dap-virtual-text = {
      enable = true;
    };

    extraPackages = with pkgs; [
      python3Packages.debugpy
    ];
  };
}
