local leap = require("leap")
leap.opts.case_sensitive = true
leap.set_default_keymaps()
-- vim.keymap.set('o', 's', '<Plug>(leap-forward)')
-- vim.keymap.set('o', 'S', '<Plug>(leap-backward)')

require("nvim-surround").setup()
vim.cmd("highlight NvimSurroundHighlight guifg='#edc41f' gui=underline ctermfg='yellow' cterm=underline")

-- require("better_escape").setup {
--     timeout = vim.o.timeoutlen,
--     default_mappings = false,
--     mappings = {
--         i = {
--             j = {
--                 -- These can all also be functions
--                 k = "<Esc>",
--             },
--         },
--         c = {
--             j = {
--                 k = "<Esc>",
--             },
--         },
--         t = {
--             j = {
--                 k = "<Esc>",
--             },
--         },
--         v = {
--             j = {
--                 k = "<Esc>",
--             },
--         },
--         s = {
--             j = {
--                 k = "<Esc>",
--             },
--         },
--     },
-- }
