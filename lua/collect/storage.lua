local M = {}
local Path = require("plenary.path")

local data_path = vim.fn.stdpath("data")
local current_dir = vim.fn.getcwd()
local cache_config = string.format("%s/%s_collect.json", data_path, vim.fn.fnamemodify(current_dir, ":p:h:t"))

local content_storage = {}
local memory_key = "collect_data"

function M.save_to_file()
    local json_data = vim.fn.json_encode(content_storage)
    local path = Path:new(cache_config)
    path:parent():mkdir({ recursive = true })
    path:write(json_data, "w")
end

function M.load_from_file()
    local path = Path:new(cache_config)
    if path:exists() then
        local json_data = path:read()
        local decoded = vim.fn.json_decode(json_data)
        if decoded then
            content_storage = decoded
        end
    end
end

function M.save_buffer_to_memory(buf_id)
    if not buf_id or not vim.api.nvim_buf_is_valid(buf_id) then
        return
    end
    local lines = vim.api.nvim_buf_get_lines(buf_id, 0, -1, false)
    content_storage[memory_key] = lines
end

function M.load_memory_to_buffer(buf_id)
    if not buf_id or not vim.api.nvim_buf_is_valid(buf_id) then
        return
    end
    local lines = content_storage[memory_key] or {}
    vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, lines)
end

return M
