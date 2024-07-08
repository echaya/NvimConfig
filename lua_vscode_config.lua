vim.keymap.del('x', 'ma')
vim.keymap.del('x', 'mi')
vim.keymap.del('x', 'mA')
vim.keymap.del('x', 'mI')

-- vim.api.nvim_set_hl(0, 'LeapLabel', { fg = '#282c34', bg = '#98c379' })
-- vim.api.nvim_set_hl(0, 'LeapLabelPrimary', { fg = '#dd78c6', bg = '#98c379' })

-- set vim.notify as default notify
local code = require('vscode')
vim.notify = code.notify
