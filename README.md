# flexterm.nvim

A flexible, customizable terminal toggle plugin for Neovim. It supports both **floating** and **bottom** terminal modes, giving you full control over the terminal window appearance and positioning.

## Installation

Use [lazy.nvim](https://github.com/folke/lazy.nvim) to install the plugin:

```lua
require("lazy").setup({
    {
        "sajibt/flexterm.nvim",  
        config = function()
            local flexterm = require("flexterm")
            
            -- Configure the terminal mode (bottom or floating)
            flexterm.setup({
                mode = "bottom",  -- Set the terminal mode here (bottom or floating)
            })
            
            -- Set up keybindings for toggling the terminal
            vim.keymap.set('n', '<C-j>', flexterm.toggleterm, { desc = "Toggle Terminal" })
            vim.keymap.set('t', '<C-j>', flexterm.toggleterm, { desc = "Toggle Terminal" })
        end,
    }
})

