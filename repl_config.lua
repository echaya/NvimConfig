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
        format = require("iron.fts.common").bracketed_paste_python,
        command = { "ipython", "-i", "--no-autoindent" },
      },
    },
    repl_open_cmd = require("iron.view").split.vertical.botright("45%"),
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
    -- TODO norm! gv after Iron start/restart
    vim.keymap.set(
      { "n", "v" },
      [[<a-\>]],
      "<cmd>IronRepl<cr>",
      { buffer = args.buf, desc = "repl_toggle" }
    )
    vim.keymap.set({ "n", "v" }, "<localleader>r", function()
      vim.cmd("IronRestart")
      vim.cmd("IronRepl")
    end, { buffer = args.buf, desc = "repl_restart" })
    vim.keymap.set("n", "<localleader><cr>", function()
      iron.send(nil, string.char(13))
    end, { buffer = args.buf, desc = "repl_cr" })
    vim.keymap.set("n", "<localleader><localleader>", function()
      vim.cmd("call SelectVisual()")
      vim.cmd("norm! y`>")
      iron.send(nil, "%paste")
      vim.cmd("norm! j")
    end, { buffer = args.buf, desc = "repl_%paste" })
    vim.keymap.set("n", "<localleader>]", function()
      vim.cmd("call SelectVisual()")
      iron.visual_send()
      vim.cmd("norm! j")
    end, { buffer = args.buf, desc = "repl_send_cell" })
    vim.keymap.set("n", "<localleader>y", function()
      vim.cmd("norm! yiwo")
      vim.cmd("norm! pA.to_clipboard()")
      vim.cmd("norm! V")
      iron.visual_send()
      vim.cmd("norm! dd")
    end, { buffer = args.buf, desc = "repl_df_to_clipboard" })
    vim.keymap.set("n", "<localleader>p", function()
      vim.cmd("norm! yiwoprint(")
      vim.cmd("norm! pA)")
      vim.cmd("norm! V")
      iron.visual_send()
      vim.cmd("norm! dd")
    end, { buffer = args.buf, desc = "repl_print" })
    vim.keymap.set("v", "<CR>", function()
      iron.visual_send()
      vim.cmd("norm! j")
    end, { buffer = args.buf, desc = "repl_v_send" })
    vim.keymap.set({ "n", "v" }, "<localleader>u", function()
      iron.send_until_cursor()
      vim.api.nvim_input("<ESC>") -- to escape from visual mode
    end, { buffer = args.buf, desc = "repl_send_until" })
    vim.keymap.set({ "n", "v" }, "<localleader>q", function()
      iron.close_repl()
      iron.send(nil, string.char(13))
    end, { buffer = args.buf, desc = "repl_exit" })
    vim.keymap.set({ "n", "v" }, "<localleader>c", function()
      iron.send(nil, string.char(03))
    end, { buffer = args.buf, desc = "repl_interrupt" })
    vim.keymap.set({ "n", "v" }, "<a-del>", function()
      iron.send(nil, string.char(12))
    end, { buffer = args.buf, desc = "repl_clear" })
    vim.keymap.set(
      "n",
      "<localleader>f",
      "<cmd>IronFocus<cr>i",
      { buffer = args.buf, desc = "repl_focus" }
    )
    vim.keymap.set({ "n" }, "<localleader>t", function()
      vim.cmd("normal V")
      require("leap.treesitter").select()
      iron.visual_send()
      vim.cmd("norm! j")
    end, { buffer = args.buf, desc = "repl_send_tree" })
  end,
})
vim.keymap.set("t", [[<a-\>]], "<cmd>q<cr>", { desc = "repl_toggle" })

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
  require("conform").format({
    async = true,
    lsp_format = "fallback",
    range = range,
  })
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
    map("n", "<leader>hs", gitsigns.stage_hunk, { desc = "hunk_stage" })
    map("n", "<leader>hr", gitsigns.reset_hunk, { desc = "hunk_reset" })
    map("n", "<leader>hu", gitsigns.undo_stage_hunk, { desc = "hunk_unstage" })
    map("v", "<leader>hs", function()
      gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
    end, { desc = "hunk_stage" })
    map("v", "<leader>hr", function()
      gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
    end, { desc = "hunk_reset" })
    map("v", "<leader>hu", function()
      gitsigns.undo_stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
    end, { desc = "hunk_unstage" })
    map({ "n", "v" }, "<leader>hh", gitsigns.preview_hunk, { desc = "hunk_hover" })
    map("n", "<leader>hd", "<cmd>DiffviewFileHistory %<CR>", { desc = "diffview: file_history" })
    map("v", "<leader>hd", ":'<,'>DiffviewFileHistory<CR>", { desc = "diffview: hunk_history" })
    map("n", "<leader>htd", gitsigns.toggle_deleted, { desc = "gitsign: toggle_deleted" })

    -- Text object
    map({ "o", "x" }, "gh", ":<C-U>Gitsigns select_hunk<CR>")
  end,
})

local hipatterns = require("mini.hipatterns")
hipatterns.setup({
  highlighters = {
    -- Highlight standalone 'XXX', 'IMP', 'TODO', 'NOTE'
    fixme = {
      pattern = "%f[%w]()XXX()%f[%W]",
      group = "MiniHipatternsFixme",
    },
    hack = { pattern = "%f[%w]()IMP()%f[%W]", group = "MiniHipatternsHack" },
    todo = {
      pattern = "%f[%w]()TODO()%f[%W]",
      group = "MiniHipatternsTodo",
    },
    note = {
      pattern = "%f[%w]()NOTE()%f[%W]",
      group = "MiniHipatternsNote",
    },

    -- Highlight hex color strings (`#rrggbb`) using that color
    hex_color = hipatterns.gen_highlighter.hex_color(),
  },
})

require("nvim-treesitter.configs").setup({
  -- A list of parser names, or "all" (the listed parsers MUST always be installed)
  ensure_installed = {
    "lua",
    "markdown",
    "markdown_inline",
    "python",
    "query",
    "vim",
    "vimdoc",
  },
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
vim.treesitter.language.register("markdown", "vimwiki")

-- default configuration
require("illuminate").configure({
  providers = {
    "lsp",
    "treesitter",
    "regex",
  },
  delay = 200,
  filetype_overrides = {},
  filetypes_denylist = {
    "dirbuf",
    "dirvish",
    "fugitive",
    "minifiles",
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
      return vim.o.columns * 0.3
    end
  end,
  direction = "horizontal",
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

vim.keymap.set(
  { "n", "t" },
  "<a-z>",
  "<cmd>lua _lazygit_toggle()<CR>",
  { noremap = true, silent = true, desc = "lazygit" }
)

vim.keymap.set(
  { "n", "t" },
  "<a-`>",
  "<cmd>ToggleTerm<CR>",
  { noremap = true, silent = true, desc = "ToggleTerm" }
)

vim.keymap.set("n", "<a-`>", function()
  return "<cmd>" .. vim.v.count .. "ToggleTerm<cr>"
end, { expr = true, desc = "X ToggleTerm" })

vim.keymap.set({ "n", "t" }, "<a-d>", function()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local bufnr = vim.api.nvim_win_get_buf(win)
    if vim.bo[bufnr].buftype == "terminal" then
      local _, term = require("toggleterm.terminal").identify(vim.api.nvim_buf_get_name(bufnr))
      if term and term:is_split() then
        cur_dir = term.direction
        if cur_dir == "horizontal" then
          return "<Cmd>ToggleTerm<CR><Cmd>ToggleTerm direction=vertical<CR>"
        else
          return "<Cmd>ToggleTerm<CR><Cmd>ToggleTerm direction=tab<CR>"
        end
      end
    end
  end
  return "<Cmd>ToggleTerm<CR><Cmd>ToggleTerm direction=horizontal<CR>"
end, { expr = true, desc = "ToggleTerm direction" })

vim.keymap.set("n", "<leader>ft", "<Cmd>TermSelect<CR>", { desc = "find_terminal" })
