local M = {}

M.config = {
    mode = "floating",                            -- "floating" or "bottom"
    dimensions = {
        floating = { width = 0.8, height = 0.8 }, -- Proportion for floating terminal
        bottom = { height = 0.3 },                -- Proportion for bottom terminal
    },
    border = "rounded",                           -- Border style[none,single,double,rounded,solid]
    cmd = { vim.o.shell }
}

M.setup = function(user_config)
    M.config = vim.tbl_deep_extend("force", M.config, user_config or {})
end

local function calculate_dimensions()
    if M.config.mode == "floating" then
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
        return {
            relative = "editor",
            width = vim.o.columns,
            height = math.floor(vim.o.lines * M.config.dimensions.bottom.height),
            col = 0,
            row = vim.o.lines - math.floor(vim.o.lines * M.config.dimensions.bottom.height),
            style = "minimal",
            border = M.config.border,
        }
    end
end

M.toggleterm = function()
    if not vim.api.nvim_buf_is_valid(M.buf or -1) then
        M.buf = vim.api.nvim_create_buf(false, false)
    end

    if not M.win or not vim.api.nvim_win_is_valid(M.win) then
        local win_opts = calculate_dimensions()
        M.win = vim.api.nvim_open_win(M.buf, true, win_opts)
        vim.fn.termopen(M.config.cmd)
        vim.cmd("startinsert")
    else
        if vim.api.nvim_win_is_valid(M.win) then
            vim.api.nvim_win_close(M.win, true)
        else
            local win_opts = calculate_dimensions()
            M.win = vim.api.nvim_open_win(M.buf, true, win_opts)
            vim.cmd("startinsert")
        end
    end
end

M.toggleterm()
