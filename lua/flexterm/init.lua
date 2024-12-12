local M = {}

M.config = {
    mode = "floating",                            -- Default mode: "floating" or "bottom"
    dimensions = {
        floating = { width = 0.8, height = 0.8 }, -- Proportion for floating terminal
        bottom = { height = 0.3 },                -- Proportion for bottom terminal
    },
    border = "rounded",
    cmd = { vim.o.shell },
}

M.setup = function(user_config)
    M.config = vim.tbl_deep_extend("force", M.config, user_config or {})
end

local function calculate_dimensions()
    if M.config.mode == "floating" then
        -- Floating mode: Terminal in the center of the screen
        return {
            relative = "editor",
            width = math.floor(vim.o.columns * M.config.dimensions.floating.width),
            height = math.floor(vim.o.lines * M.config.dimensions.floating.height),
            col = math.floor((vim.o.columns - vim.o.columns * M.config.dimensions.floating.width) / 2),
            row = math.floor((vim.o.lines - vim.o.lines * M.config.dimensions.floating.height) / 2),
            style = "minimal",
            border = M.config.border,
        }
    else
        -- Bottom mode: Terminal docked at the bottom
        return {
            relative = "editor",
            width = vim.o.columns,                                                           -- Full width
            height = math.floor(vim.o.lines * M.config.dimensions.bottom.height),            -- Proportion of screen height
            col = 0,
            row = vim.o.lines - math.floor(vim.o.lines * M.config.dimensions.bottom.height), -- Position at the bottom
            style = "minimal",
            border = M.config.border,
        }
    end
end

M.toggleterm = function()
    if not vim.api.nvim_buf_is_valid(M.buf or -1) then
        M.buf = vim.api.nvim_create_buf(false, false)
    end

    -- Check if window exists or create it
    if not M.win or not vim.api.nvim_win_is_valid(M.win) then
        local win_opts = calculate_dimensions()
        M.win = vim.api.nvim_open_win(M.buf, true, win_opts)
        vim.fn.termopen(M.config.cmd)
        vim.cmd("startinsert")
    else
        -- Toggle terminal visibility
        local is_open = vim.api.nvim_win_is_valid(M.win)
        if is_open then
            vim.api.nvim_win_close(M.win, true)
        else
            local win_opts = calculate_dimensions()
            M.win = vim.api.nvim_open_win(M.buf, true, win_opts)
            vim.cmd("startinsert")
        end
    end
end

return M
