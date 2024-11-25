# Collect.nvim

A plugin that opens a clipboard (buffer) to collect some data in it.

## Table of Contents

<details>
<summary>Click to show</summary>
    
* [Requirements](#requirements)
* [Installation](#installation)
* [Default Options](#default-options)
</details>

## Requirements

- Neovim >= `0.9.0`
- [plenary](https://github.com/nvim-lua/plenary.nvim)

---

## Installation

[lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
    "fulcain/collect.nvim",
    config = function()
        local collect = require("collect")
        collect.setup({})
    end,
    dependencies = { "nvim-lua/plenary.nvim" }
}
```

[packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
    return require('packer').startup(function(use)
    use {
        "fulcain/collect.nvim",
        config = function()
            local collect = require("collect")
            collect.setup({})
        end,
        requires = { {"nvim-lua/plenary.nvim"} }
    }
end)
```

[vim-plug](https://github.com/junegunn/vim-plug)

```lua
call plug#begin('~/.vim/plugged')

Plug 'fulcain/collect.nvim'
Plug 'nvim-lua/plenary.nvim' 

call plug#end()

" Plugin configuration
lua << EOF
local collect = require("collect")
collect.setup({})
EOF
```

## Default options

```lua
local collect = require("collect")
collect.setup({
    title = "Collect",
    title_pose = "left",
    height = 15,
    width = 70,
    toggle_keymap = "<leader>cn"
})
```
