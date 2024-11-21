# collect nvim

a plugin that opens a clipboard (buffer) to collect some data in it

# default options

```lua
    local collect = require("collect")
    collect.setup({
        title = "Collect",
        title_pose = "left",
        height = 25,
        width = 80,
        border = "rounded",
        toggleKeymap = "<leader>cn"
    })
```
