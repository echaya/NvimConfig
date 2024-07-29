-- better up/down
-- vim.keymap.set({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
-- vim.keymap.set({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })

local leap = require("leap")
leap.opts.case_sensitive = true
leap.set_default_keymaps()
-- vim.keymap.set('o', 's', '<Plug>(leap-forward)')
-- vim.keymap.set('o', 'S', '<Plug>(leap-backward)')

require("nvim-surround").setup()

local augend = require("dial.augend")
require("dial.config").augends:register_group({
	default = {
		augend.integer.alias.decimal,
		augend.integer.alias.hex,
		augend.date.alias["%Y-%m-%d"],
		augend.date.alias["%Y/%m/%d"],
		augend.date.alias["%m/%d"],
		augend.date.alias["%H:%M"],
		augend.date.alias["%H:%M:%S"],
		augend.constant.alias.bool,
		augend.constant.new({ elements = { "True", "False" } }),
	},
	visual = {
		augend.integer.alias.decimal,
		augend.integer.alias.hex,
		augend.date.alias["%Y-%m-%d"],
		augend.date.alias["%Y/%m/%d"],
		augend.date.alias["%m/%d"],
		augend.date.alias["%H:%M"],
		augend.date.alias["%H:%M:%S"],
		augend.constant.alias.bool,
		augend.constant.new({ elements = { "True", "False" } }),
	},
})

vim.keymap.set("n", "<C-a>", function()
	require("dial.map").manipulate("increment", "normal")
end)
vim.keymap.set("n", "<C-x>", function()
	require("dial.map").manipulate("decrement", "normal")
end)
vim.keymap.set("v", "<C-a>", function()
	require("dial.map").manipulate("increment", "visual")
end)
vim.keymap.set("v", "<C-x>", function()
	require("dial.map").manipulate("decrement", "visual")
end)
