# Go impl for neovim

Lua API to easily provide Go implementation for current type

## Prerequisites

- neovim v0.9+
- [treesitter](https://github.com/nvim-treesitter/nvim-treesitter) with `Go` language support
- Go [impl](https://pkg.go.dev/github.com/josharian/impl) installed (could be via [mason.nvim](https://github.com/williamboman/mason.nvim))

## Installation

[Lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
-- init.lua
{ 'venomlab/goimpl.nvim', tag = "0.1.0" }

```

## Usage

Public function `impl` of `goimpl` module checks if file is of type `Go` and then asks for interface prompt.
If everything is fine, you'll have function stubs for the desired type

The simplest way would be to just set new keybinding somewhere in "after plugins" section:

```lua
-- after/plugin/goimpl.lua
local goimpl = require("goimpl")

vim.keymap.set("n", "<leader>im", function()
    if goimpl.is_go() then -- call impl if current buffer is attached to Go file
        goimpl.impl()
    end
end)
```

Better would be to add it to your LSP config on buffer attach.
Example with [lsp-zero.nvim](https://github.com/VonHeikemen/lsp-zero.nvim):

```lua
-- after/plugin/lsp.lua
lsp_zero.on_attach(function(client, bufnr)
    local opts = { buffer = bufnr, remap = false }

    local goimpl = require("goimpl")
    if goimpl.is_go() then -- register keybinding only if it is Go file
        vim.keymap.set("n", "<leader>im", function()
            goimpl.impl()
        end, opts)
    end

    -- your other keymaps

```
