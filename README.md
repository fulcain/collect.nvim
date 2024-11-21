# Collect.nvim

A plugin that opens a clipboard (buffer) to collect some data in it.

## Table of Contents

- [Requirements](#requirements)
- [Installation](#installation)
  - [lazy.nvim](#lazynvim)
  - [packer.nvim](#packernvim)
  - [vim-plug](#vim-plug)
- [Default Options](#default-options)

---

## Requirements

- Neovim >= `0.9.0`

---

## Installation

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
    "fulcain/collect.nvim",
    config = function()
        local collect = require("collect")
        collect.setup({})
    end,
}
```

### [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
    return require('packer').startup(function(use)
    use {
        "fulcain/collect.nvim",
        config = function()
            local collect = require("collect")
            collect.setup({})
        end,
    }
end)
```

### [vim-plug](https://github.com/junegunn/vim-plug)

```lua
call plug#begin('~/.vim/plugged')

Plug 'fulcain/collect.nvim'

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
    height = 25,
    width = 80,
    toggleKeymap = "<leader>cn"
})
```
