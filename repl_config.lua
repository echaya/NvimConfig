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
	keymaps = {},
	-- If the highlight is on, you can change how it looks
	-- For the available options, check nvim_set_hl
	highlight = {
		italic = true,
	},
	ignore_blank_lines = false, -- ignore blank lines when sending visual select lines
})
vim.api.nvim_create_autocmd("FileType", {
	pattern = "python",
	callback = function(args)
		vim.keymap.set("v", "<CR>", iron.visual_send, { buffer = args.buf, desc = "repl_v_send" })
		vim.keymap.set("n", [[\r]], "<cmd>IronRepl<cr>", { buffer = args.buf, desc = "repl_toggle" })
		vim.keymap.set("n", [[\d]], "<cmd>IronRestart<cr>", { buffer = args.buf, desc = "repl_repl_restart" })
		vim.keymap.set("n", [[\u]], iron.send_until_cursor, { buffer = args.buf, desc = "repl_send_until" })
		vim.keymap.set("n", [[\q]], iron.close_repl, { buffer = args.buf, desc = "repl_exit" })
		vim.keymap.set("n", "<CR>", function()
			iron.send(nil, string.char(13))
		end, { buffer = args.buf, desc = "repl_cr" })
		vim.keymap.set("n", [[\s]], function()
			iron.run_motion("send_motion")
		end, { buffer = args.buf, desc = "repl_send_motion" })
		vim.keymap.set("n", [[\c]], function()
			iron.send(nil, string.char(03))
		end, { buffer = args.buf, desc = "repl_interrupt" })
		vim.keymap.set("n", [[\l]], function()
			iron.send(nil, string.char(12))
		end, { buffer = args.buf, desc = "repl_clear" })
	end,
})

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
vim.keymap.set("n", "==", "<cmd>Format<cr>", { desc = "conform_format" })
-- sync black call
vim.keymap.set("n", "<leader>==", ":!black %<cr>")
vim.api.nvim_create_autocmd("FileType", {
	pattern = "vim",
	callback = function(args)
		vim.keymap.set("n", "==", "ggVG=", { buffer = args.buf, desc = "vim_format" })
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
		map("n", "]c", function()
			if vim.wo.diff then
				vim.cmd.normal({ "]c", bang = true })
			else
				gitsigns.nav_hunk("next")
			end
		end, { desc = "next_hunk" })

		map("n", "[c", function()
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
		map("v", "gz", function()
			gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
		end, { desc = "reset_hunk" })
		map("n", "gz", gitsigns.reset_hunk, { desc = "reset_hunk" })
		map("n", "gJ", gitsigns.preview_hunk, { desc = "preview_hunk" })
		-- map("n", "gK", '<cmd>lua require"gitsigns".diffthis("~")<CR>', { desc = "gitsign: diffthis" })
		map("n", "gK", "<cmd>DiffviewFileHistory %<CR>", { desc = "diffview: file_history" })
		map("n", "<leader>td", gitsigns.toggle_deleted, { desc = "gitsign: toggle_deleted" })

		-- Text object
		map({ "o", "x" }, "gh", ":<C-U>Gitsigns select_hunk<CR>")
	end,
})

local hipatterns = require("mini.hipatterns")
hipatterns.setup({
	highlighters = {
		-- Highlight standalone 'SKIP', 'IMP', 'TODO', 'NOTE'
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

require("toggleterm").setup({
	size = function(term)
		if term.direction == "horizontal" then
			return 15
		elseif term.direction == "vertical" then
			return vim.o.columns * 0.4
		else
			return 30
		end
	end,
})

local Terminal = require("toggleterm.terminal").Terminal
local lazygit = Terminal:new({
	cmd = "lazygit",
	dir = "git_dir",
	direction = "tab",
	name = "Lazygit",
})

function _lazygit_toggle()
	lazygit:toggle()
end

vim.api.nvim_set_keymap(
	"n",
	"<leader>lg",
	"<cmd>lua _lazygit_toggle()<CR>",
	{ noremap = true, silent = true, desc = "lazygit" }
)

local ipython = Terminal:new({
	cmd = "ipython --no-autoindent",
	dir = "git_dir",
	direction = "vertical",
	name = "ipython",
	hidden = true,
})

function _ipython_toggle()
	ipython:toggle()
end

vim.api.nvim_set_keymap(
	"n",
	"<leader>py",
	"<cmd>lua _ipython_toggle()<CR>",
	{ noremap = true, silent = true, desc = "ipython" }
)

local pwsh = Terminal:new({
	-- cmd = "ipython --no-autoindent",
	-- dir = "git_dir",
	direction = "horizontal",
	name = "powershell",
	hidden = true,
})

function _pwsh_toggle()
	pwsh:toggle()
end

vim.api.nvim_set_keymap(
	"n",
	"<a-`>",
	"<cmd>lua _pwsh_toggle()<CR>",
	{ noremap = true, silent = true, desc = "powershell" }
)
