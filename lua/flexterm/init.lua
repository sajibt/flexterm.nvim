local M = {}

M.config = {
    mode = "floating",                            -- "floating" or "bottom"
    dimensions = {
        floating = { width = 0.8, height = 0.8 }, -- Proportion for floating terminal
        bottom = { height = 0.3 },                -- Proportion for bottom terminal
    },
    border = "rounded",                           -- Border style [none, single, double, rounded, solid]
    cmd = vim.o.shell,
}

M.setup = function(user_config)
    M.config = vim.tbl_deep_extend("force", M.config, user_config or {})
end

-- Calculate dimensions for terminal
local function calculate_dimensions()
    if M.config.mode == "floating" then
        return {
            relative = "editor",
            width = math.floor(vim.o.columns * M.config.dimensions.floating.width),
            height = math.floor(vim.o.lines * M.config.dimensions.floating.height),
            col = math.floor((vim.o.columns - vim.o.columns * M.config.dimensions.floating.width) / 2),
            row = math.floor((vim.o.lines - vim.o.lines * M.config.dimensions.floating.height) / 2),
            style = "minimal",        -- Keep the style minimal, no color
            border = M.config.border, -- Apply the border style (rounded, solid, etc.)
        }
    else
        return {
            relative = "editor",
            width = vim.o.columns,
            height = math.floor(vim.o.lines * M.config.dimensions.bottom.height),
            col = 0,
            row = vim.o.lines - math.floor(vim.o.lines * M.config.dimensions.bottom.height),
            style = "minimal",        -- Keep the style minimal, no color
            border = M.config.border, -- Apply the border style (rounded, solid, etc.)
        }
    end
end

-- Automatically resize the terminal when the window is resized
local function resize_terminal()
    if M.win and vim.api.nvim_win_is_valid(M.win) then
        vim.api.nvim_win_set_config(M.win, calculate_dimensions())
    end
end

vim.api.nvim_create_autocmd("VimResized", {
    callback = resize_terminal,
})

M.toggleterm = function()
    if M.win and vim.api.nvim_win_is_valid(M.win) then
        -- If the terminal window is open, close it
        vim.api.nvim_win_close(M.win, true)
        M.win = nil
    else
        -- If the terminal window is not open, create/reuse buffer and open window
        if not M.buf or not vim.api.nvim_buf_is_valid(M.buf) then
            -- Create a new buffer if it doesn't exist or is invalid
            M.buf = vim.api.nvim_create_buf(false, false)
            vim.bo[M.buf].buftype = "nofile"
            vim.bo[M.buf].swapfile = false
            vim.bo[M.buf].bufhidden = "hide"
        end

        -- Open a new window with the appropriate dimensions
        local win_opts = calculate_dimensions()
        M.win = vim.api.nvim_open_win(M.buf, true, win_opts)

        -- Start terminal in insert mode
        if not M.terminal_started then
            vim.fn.termopen(M.config.cmd, {
                on_exit = function()
                    -- Reset buffer and window after exiting
                    if vim.api.nvim_buf_is_valid(M.buf) then
                        vim.api.nvim_buf_delete(M.buf, { force = true })
                    end
                    M.buf = nil
                    M.win = nil
                    M.terminal_started = false
                end,
            })
            M.terminal_started = true
        end

        vim.cmd("startinsert")
    end
end

return M

