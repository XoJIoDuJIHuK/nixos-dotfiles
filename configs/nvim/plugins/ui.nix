{ ... }:

{
  programs.nixvim = {
    plugins = {
      # Trouble
      trouble = {
        enable = true;
        settings = {
          use_diagnostic_signs = true;
        };
      };

      # Lualine with custom emoji
      lualine = {
        enable = true;
        settings = {
          sections = {
            lualine_x = [
              {
                __raw = ''
                  function()
                    return "😄"
                  end
                '';
              }
            ];
          };
        };
      };

      # Which-key
      which-key = {
        enable = true;
      };

      # Noice (for UI)
      noice = {
        enable = true;
      };

      # Bufferline
      bufferline = {
        enable = true;
      };
    };
  };
}
