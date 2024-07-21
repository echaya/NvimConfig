local leap = require("leap")
leap.opts.case_sensitive = true
leap.set_default_keymaps()
-- vim.keymap.set('o', 's', '<Plug>(leap-forward)')
-- vim.keymap.set('o', 'S', '<Plug>(leap-backward)')

require("nvim-surround").setup()

