-- better up/down
-- vim.keymap.set({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
-- vim.keymap.set({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })

local leap = require("leap")
leap.opts.case_sensitive = true
leap.set_default_keymaps()
-- vim.keymap.set('o', 's', '<Plug>(leap-forward)')
-- vim.keymap.set('o', 'S', '<Plug>(leap-backward)')

require("nvim-surround").setup()

