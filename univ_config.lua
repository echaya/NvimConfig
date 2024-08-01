-- better up/down
-- vim.keymap.set({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
-- vim.keymap.set({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })

local leap = require("leap")
leap.opts.case_sensitive = true
-- leap.set_default_keymaps()
-- Define equivalence classes for brackets and quotes, in addition to <space>
leap.opts.equivalence_classes = { " \t\r\n", "([{", ")]}", "'\"`" }
vim.keymap.set({ "n" }, "s", "<Plug>(leap-forward-to)")
vim.keymap.set({ "n" }, "S", "<Plug>(leap-backward-to)")
vim.keymap.set({ "x", "o" }, "z", "<Plug>(leap-forward-to)", { desc = "leap forward textobj" })
vim.keymap.set({ "x", "o" }, "Z", "<Plug>(leap-backward-to)", { desc = "leap back textobj" })
vim.keymap.set({ "n" }, "gs", "<Plug>(leap-from-window)",{desc = "leap from window"})
-- s<CR> to traverse forward, s<BS> to traverse backward
vim.keymap.set(
	{ "n", "x", "o" },
	"ga",
	'<cmd> lua require("leap.treesitter").select()<cr>',
	{ desc = "select treesitter textobj" }
)
vim.keymap.set(
	{ "n", "x", "o" },
	"gA",
	'V<cmd>lua require("leap.treesitter").select()<cr>',
	{ desc = "select treesitter textobj" }
)

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
-- abcdefghijklmn

-- lua, default settings
require("better_escape").setup {
    timeout = 200,
    default_mappings = false,
    mappings = {
        i = {
            j = {
                -- These can all also be functions
                k = "<Esc>",
            },
        },
        c = {
            j = {
                k = "<Esc>",
            },
        },
        t = {
            j = {
                k = "<Esc>",
            },
        },
        v = {
            j = {
                k = "<Esc>",
            },
        },
        s = {
            j = {
                k = "<Esc>",
            },
        },
    },
}
