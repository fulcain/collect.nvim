local M = {}
local window = require("collect.window")
local storage = require("collect.storage")

--- Configuration options for the module
--- @class CollectOptions
--- @field title string? The title displayed in the window (default: "Collect").
--- @field title_pos string? Position of the title, either "left", "center", or "right" (default: "left").
--- @field height number? Height of the floating window (default: 15).
--- @field width number? Width of the floating window (default: 70).
--- @field toggle_keymap string? Keymap for toggling the window (default: "<leader>cn").

--- Sets up the module with the given options.
--- @param opts CollectOptions
function M.setup(opts)
    opts = opts or {}
    M.toggle(opts)
end

function M.toggle(opts)
    vim.keymap.set("n", opts.toggle_keymap or "<leader>cn", function()
        if window.is_open() then
            window.close()
        else
            window.open(opts)
        end
    end, { desc = "Toggle collect.nvim" })
end

-- On startup, load content from file
storage.load_from_file()

return M
