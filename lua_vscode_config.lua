vim.keymap.del('x', 'ma')
vim.keymap.del('x', 'mi')
vim.keymap.del('x', 'mA')
vim.keymap.del('x', 'mI')

-- set vim.notify as default notify
local code = require('vscode')
vim.notify = code.notify
