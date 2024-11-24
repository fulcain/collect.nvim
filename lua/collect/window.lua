local M = {}
local constants = require("collect.constants")
local storage = require("collect.storage")

-- Make them part of the module state
M.win_id = nil
M.buf_id = nil

function M.create_win_config(opts)
    local height = opts.height or 15
    local width = opts.width or 70

    return {
        relative = "editor",
        row = math.floor(((vim.o.lines - height) / 2) - 1),
        col = math.floor((vim.o.columns - width) / 2),
        width = width,
        height = height,
        focusable = true,
        border = "single",
        title = opts.title or "Collect",
        title_pos = opts.title_pos or "left",
        style = "minimal",
    }
end

function M.resize(opts)
    if M.win_id and vim.api.nvim_win_is_valid(M.win_id) then
        local config = M.create_win_config(opts)
        vim.api.nvim_win_set_config(M.win_id, config)
    end
end

function M.setup_resize_autocmd(opts)
    vim.api.nvim_create_autocmd("VimResized", {
        callback = function()
            M.resize(opts)
        end,
    })
end

function M.check_for_buf_close()
    for _, value in ipairs(constants.close_keys) do
        vim.keymap.set(value.mode, value.key, function()
            M.close()
        end, vim.tbl_extend("force", value.opts or {}, { buffer = M.buf_id }))
    end
end

function M.is_open()
    return M.win_id and vim.api.nvim_win_is_valid(M.win_id)
end

function M.close()
    if M.is_open() then
        storage.save_buffer_to_memory(M.buf_id)
        storage.save_to_file()

        for _, value in ipairs(constants.close_keys) do
            vim.keymap.del(value.mode, value.key, { buffer = M.buf_id })
        end

        vim.api.nvim_win_close(M.win_id, true)
        M.win_id = nil
        M.buf_id = nil
    end
end

function M.open(opts)
    if M.is_open() then
        vim.api.nvim_set_current_win(M.win_id)
        return
    end

    M.buf_id = vim.api.nvim_create_buf(false, true)
    local config = M.create_win_config(opts)

    vim.api.nvim_set_option_value("buftype", "acwrite", { buf = M.buf_id })
    vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = M.buf_id })
    vim.api.nvim_set_option_value("modifiable", true, { buf = M.buf_id })

    M.win_id = vim.api.nvim_open_win(M.buf_id, true, config)
    vim.api.nvim_win_set_option(M.win_id, "number", true)

    storage.load_memory_to_buffer(M.buf_id)

    vim.api.nvim_create_autocmd("BufWipeout", {
        buffer = M.buf_id,
        callback = function()
            storage.save_buffer_to_memory(M.buf_id)
            storage.save_to_file()
            M.buf_id = nil
            M.win_id = nil
        end,
    })

    M.setup_resize_autocmd(opts)
    M.check_for_buf_close()
end

return M
