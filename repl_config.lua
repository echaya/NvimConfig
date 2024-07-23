local iron = require("iron.core")

iron.setup({
	config = {
		-- Scope of the repl
		-- By default it is one for the same `pwd`
		-- Other options are `tab_based` and `singleton`
		scope = require("iron.scope").path_based,
		-- Whether a repl should be discarded or not
		scratch_repl = true,
		-- Your repl definitions come here
		repl_definition = {
			python = {
				format = require("iron.fts.common").bracketed_paste,
				command = { "ipython", "--no-autoindent" },
			},
			sh = {
				-- Can be a table or a function that
				-- returns a table (see below)
				command = { "zsh" },
			},
		},
		repl_open_cmd = require("iron.view").split.vertical.botright("55%"),
	},
	keymaps = {
		send_motion = "<Leader>sm",
		-- send_line = "<Leader>sl",
		visual_send = "<CR>",
		send_until_cursor = "<Leader>su",
		-- send_file = "<Leader>sf",
		-- send_mark = "<Leader>sm",
		-- mark_motion = "<Leader>mc",
		-- mark_visual = "<Leader>mc",
		-- remove_mark = "<Leader>md",
		cr = "<CR>",
		interrupt = "<C-I>",
		exit = "<Leader>rq",
		-- clear = "<Leader>cl",
	},
	-- If the highlight is on, you can change how it looks
	-- For the available options, check nvim_set_hl
	highlight = {
		italic = true,
	},
	ignore_blank_lines = true, -- ignore blank lines when sending visual select lines
})

-- iron also has a list of commands, see :h iron-commands for all commands, handled in python.vimrc
-- vim.keymap.set('n', '<Leader>rr', '<cmd>IronRepl<cr>',{silence=True})
-- vim.keymap.set('n', '<Leader>rd', '<cmd>IronRestart<cr>',{silence=True})
-- vim.keymap.set('n', '<Leader>rh', '<cmd>IronHide<cr>')
-- vim.keymap.set('n', '<Leader>rf', '<cmd>IronFocus<cr>')

require("conform").setup({
	formatters_by_ft = {
		lua = { "stylua" },
		-- Conform will run multiple formatters sequentially
		python = { "isort", "black" },
		-- Use a sub-list to run only the first available formatter
		-- javascript = { { "prettierd", "prettier" } },
	},
})

vim.api.nvim_create_user_command("Format", function(args)
	local range = nil
	if args.count ~= -1 then
		local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
		range = {
			start = { args.line1, 0 },
			["end"] = { args.line2, end_line:len() },
		}
	end
	require("conform").format({ async = true, lsp_format = "fallback", range = range })
end, { range = true })
-- async black call
vim.keymap.set("n", "==", "<cmd>Format<cr>")
-- sync black call
vim.keymap.set("n", "<leader>==", ":!black %<cr>")
vim.api.nvim_create_autocmd("FileType", {
	pattern = "vim",
	callback = function(args)
		vim.keymap.set("n", "==", "ggVG=", { buffer = args.buf })
	end,
})

-- autocmd FileType vim nnoremap == ggVG=<C-o>

require("gitsigns").setup({
	on_attach = function(bufnr)
		local gitsigns = require("gitsigns")

		local function map(mode, l, r, opts)
			opts = opts or {}
			opts.buffer = bufnr
			vim.keymap.set(mode, l, r, opts)
		end

		-- navigation
		map("n", "gj", function()
			if vim.wo.diff then
				vim.cmd.normal({ "]c", bang = true })
			else
				gitsigns.nav_hunk("next")
			end
		end, { desc = "next_hunk" })

		map("n", "gk", function()
			if vim.wo.diff then
				vim.cmd.normal({ "[c", bang = true })
			else
				gitsigns.nav_hunk("prev")
			end
		end, { desc = "prev_hunk" })

		-- Actions
		map("v", "hs", function()
			gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }, { desc = "stage_hunk" })
		end)
		map("v", "hu", function()
			gitsigns.undo_stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
		end, { desc = "undo_stage_hunk" })
		map("v", "gZ", function()
			gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v"), { desc = "reset_hunk" } })
		end)
		map("n", "gZ", gitsigns.reset_hunk, { desc = "reset_hunk" })
		map("n", "gJ", gitsigns.preview_hunk, { desc = "preview_hunk" })
		map("n", "gK", '<cmd>lua require"gitsigns".diffthis("~")<CR>')
		map("n", "<leader>td", gitsigns.toggle_deleted)

		-- Text object
		map({ "o", "x" }, "gh", ":<C-U>Gitsigns select_hunk<CR>")
	end,
})

local hipatterns = require("mini.hipatterns")
hipatterns.setup({
	highlighters = {
		-- Highlight standalone 'SKIP', 'IMP', 'TODO', 'NOTE', XXX
		fixme = { pattern = "%f[%w]()SKIP()%f[%W]", group = "MiniHipatternsFixme" },
		hack = { pattern = "%f[%w]()IMP()%f[%W]", group = "MiniHipatternsHack" },
		todo = { pattern = "%f[%w]()TODO()%f[%W]", group = "MiniHipatternsTodo" },
		note = { pattern = "%f[%w]()NOTE()%f[%W]", group = "MiniHipatternsNote" },

		-- Highlight hex color strings (`#rrggbb`) using that color
		hex_color = hipatterns.gen_highlighter.hex_color(),
	},
})

require("nvim-treesitter.configs").setup({
	-- A list of parser names, or "all" (the listed parsers MUST always be installed)
	ensure_installed = { "lua", "vim", "vimdoc", "query", "markdown", "markdown_inline" },
	sync_install = false,
	auto_install = false,
	ignore_install = { "javascript" },
	highlight = {
		enable = true,
		disable = function(lang, buf)
			local max_filesize = 100 * 1024 -- 100 KB
			local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
			if ok and stats and stats.size > max_filesize then
				return true
			end
		end,
		additional_vim_regex_highlighting = false,
	},
})

-- default configuration
require("illuminate").configure({
	providers = {
		"lsp",
		"treesitter",
	},
	delay = 100,
	filetype_overrides = {},
	filetypes_denylist = {
		"dirbuf",
		"dirvish",
		"fugitive",
	},
	filetypes_allowlist = {},
	modes_denylist = { "i", "ic", "ix" },
	under_cursor = true,
	large_file_cutoff = nil,
	large_file_overrides = nil,
	min_count_to_highlight = 2,
	should_enable = function(bufnr)
		return true
	end,
})
