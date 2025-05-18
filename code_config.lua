-- Set up nvim-cmp.
local cmp = require("blink.cmp")
cmp.setup({
  keymap = {
    preset = "none",
    ["<C-e>"] = { "show", "show_documentation", "hide_documentation" },
    ["<Esc>"] = { "cancel", "fallback" },
    ["<C-c>"] = { "cancel", "fallback" },
    ["<CR>"] = { "accept", "fallback" },
    ["<C-u>"] = { "scroll_documentation_up", "fallback" },
    ["<C-d>"] = { "scroll_documentation_down", "fallback" },
    ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
    ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
  },

  appearance = {
    use_nvim_cmp_as_default = true,
    nerd_font_variant = "mono",
  },
  fuzzy = {
    prebuilt_binaries = { download = vim.g.update_blink },
    implementation = "rust",
  },
  completion = {
    list = { selection = { preselect = true, auto_insert = true } },
    documentation = {
      auto_show = true,
      auto_show_delay_ms = 250,
    },
  },
  sources = {
    default = { "lsp", "path", "snippets", "buffer" },
    providers = {
      lsp = {
        min_keyword_length = 2, -- Number of characters to trigger porvider
        score_offset = 0, -- Boost/penalize the score of the items
      },
      path = {
        min_keyword_length = 2,
      },
      snippets = {
        min_keyword_length = 2,
        score_offset = 5, -- Boost/penalize the score of the items
      },
      buffer = {
        min_keyword_length = 1,
        max_items = 5,
      },
    },
  },
  cmdline = {
    keymap = {
      preset = "none",
      ["<C-e>"] = { "show", "show_documentation", "hide_documentation" },
      ["<Esc>"] = { "cancel", "fallback" },
      ["<C-c>"] = { "cancel", "fallback" },
      ["<CR>"] = { "accept_and_enter", "fallback" },
      ["<Tab>"] = { "select_next", "fallback" },
      ["<S-Tab>"] = { "select_prev", "fallback" },
    },
    sources = function()
      local type = vim.fn.getcmdtype()
      if type == "/" or type == "?" then
        return { "buffer" }
      end
      if type == ":" or type == "@" then
        return { "cmdline" }
      end
      return {}
    end,
    completion = {
      menu = { auto_show = true },
      list = { selection = { preselect = false, auto_insert = true } },
    },
  },
  term = {
    enabled = true,
    keymap = { preset = "inherit" }, -- Inherits from top level `keymap` config when not set
    sources = { "buffer" },
    completion = {
      list = { selection = { preselect = false, auto_insert = true } },
      menu = { auto_show = true },
      ghost_text = { enabled = false },
    },
  },
})
-- Setup Autocomplete
require("mini.pairs").setup({
  mappings = {
    -- Opening brackets: Auto-pair if character after is not a letter or digit
    ["("] = { neigh_pattern = "[^\\][^%a%d]" },
    ["["] = { neigh_pattern = "[^\\][^%a%d]" },
    ["{"] = { neigh_pattern = "[^\\][^%a%d]" },
    -- Opening double quotation: Auto-pair if character after is not a letter or digit
    ['"'] = { neigh_pattern = "[^\\][^%a%d]" },
    -- Quotes: Auto-close if character before AND after is not a letter or digit
    ["'"] = { neigh_pattern = "[^%a%d][^%a%d]" },
    ["`"] = { neigh_pattern = "[^%a%d][^%a%d]" },
  },
})

require("conform").setup({
  formatters_by_ft = {
    lua = { "stylua" },
    python = { "isort", "ruff_format" },
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

vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  group = vim.api.nvim_create_augroup("conform-format", { clear = true }),
  callback = function(args)
    if vim.bo.filetype == "vim" then
      -- autocmd FileType vim nnoremap == ggVG=<C-o> for vim_format
      vim.keymap.set("n", "==", "ggVG=<C-o>zz", { buffer = args.buf, desc = "vim_format" })
    else
      vim.keymap.set("n", "==", "<cmd>Format<cr>", { buffer = args.buf, desc = "conform_format" })
    end
  end,
})

require("mini.diff").setup({
  view = {
    style = "sign",
  },
  mappings = {
    goto_first = "[C",
    goto_prev = "[c",
    goto_next = "]c",
    goto_last = "]C",
  },
  options = {
    algorithm = "patience",
  },
})

vim.keymap.set(
  "n",
  "<leader>hd",
  "<cmd>DiffviewFileHistory %<CR>",
  { desc = "diffview: file_history" }
)
vim.keymap.set(
  "v",
  "<leader>hd",
  "<cmd>'<,'>DiffviewFileHistory<CR>",
  { desc = "diffview: hunk_history" }
)
vim.keymap.set("n", "<leader>ho", function()
  local count = vim.v.count
  if count > 0 then
    vim.cmd("DiffviewOpen HEAD~" .. count)
  else
    vim.cmd("DiffviewOpen")
  end
end, {
  noremap = true, -- Non-recursive mapping
  silent = true, -- Don't echo the command being run
  desc = "Diffview Open [HEAD~count]", -- Description for which-key or help
})

vim.keymap.set("n", "<leader>hy", function()
  return require("mini.diff").operator("yank") .. "gh"
end, { expr = true, remap = true, desc = "Yank hunk Reference" })
vim.keymap.set(
  "n",
  "<leader>hh",
  "<cmd>lua MiniDiff.toggle_overlay()<CR>",
  { desc = "toggle hunk overlay" }
)

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

require("render-markdown").setup({
  file_types = { "markdown", "vimwiki" },
  enabled = true,
  code = {
    sign = false,
    width = "block",
    right_pad = 1,
  },
  heading = {
    sign = false,
    icons = {},
  },
  bullet = {
    left_pad = 0,
    right_pad = 1,
  },
})
vim.keymap.set("n", "<F5>", "<cmd>RenderMarkdown toggle<cr>", { desc = "Render Markdown" })

vim.keymap.set("n", "<localleader>qf", function()
  require("quicker").toggle({ open_cmd_mods = { split = "botright" } })
end, {
  desc = "Toggle quickfix",
})
require("quicker").setup({
  opts = {
    winfixheight = false,
  },
  keys = {
    {
      ">",
      function()
        require("quicker").expand({ before = 2, after = 2, add_to_existing = true })
      end,
      desc = "Expand quickfix context",
    },
    {
      "<",
      function()
        require("quicker").collapse()
      end,
      desc = "Collapse quickfix context",
    },
  },
})

-- REPL using iron
vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  group = vim.api.nvim_create_augroup("python-repl", { clear = true }),
  callback = function(args)
    local iron = require("iron.core")
    local view = require("iron.view")
    iron.setup({
      config = {
        scope = require("iron.scope").path_based,
        scratch_repl = true,
        repl_definition = {
          python = {
            format = require("iron.fts.common").bracketed_paste,
            command = { "ipython", "--no-autoindent" },
          },
        },
        repl_open_cmd = view.split.vertical.botright(function()
          return math.max(vim.o.columns * 0.35, 80)
        end),
      },
      keymaps = {},
      highlight = {
        italic = true,
      },
      ignore_blank_lines = false, -- ignore blank lines when sending visual select lines
    })
    -- TODO norm! gv after Iron start/restart
    vim.keymap.set({ "n", "v" }, [[<a-\>]], function()
      vim.cmd("IronRepl")
      vim.cmd("wincmd =")
    end, { buffer = args.buf, desc = "repl_toggle" })
    vim.keymap.set({ "n", "v" }, "<localleader>r", function()
      vim.cmd("IronRestart")
      vim.cmd("wincmd =")
    end, { buffer = args.buf, desc = "repl_restart" })

    local send_magic_paste = function()
      vim.cmd("call SelectVisual()")
      vim.cmd("norm! y`>")
      vim.defer_fn(function()
        iron.send(nil, "%paste")
      end, 100)
      vim.cmd("norm! j")
    end
    local send_cr = function()
      iron.send(nil, string.char(13))
    end

    vim.keymap.set("t", [[<a-\>]], "<cmd>q<cr>", { desc = "repl_toggle" })
    vim.keymap.set("n", "<localleader><cr>", send_cr, { buffer = args.buf, desc = "repl_cr" })
    vim.keymap.set("n", "<C-CR>", send_cr, { buffer = args.buf, desc = "repl_cr" })
    if vim.fn.has("linux") == 1 then
      vim.keymap.set("n", "<S-CR>", function()
        vim.cmd("call SelectVisual()")
        iron.visual_send()
        vim.cmd("norm! j")
      end, { buffer = args.buf, desc = "repl_send_cell" })
    else
      vim.keymap.set(
        "n",
        "<S-CR>",
        send_magic_paste,
        { buffer = args.buf, desc = "repl_send_cell" }
      )
    end
    vim.keymap.set("n", "<localleader>y", function()
      local original_cursor_pos = vim.api.nvim_win_get_cursor(0)
      local current_line_1_indexed = original_cursor_pos[1]
      local var_name = vim.fn.expand("<cword>")
      if not var_name or var_name == "" then
        vim.notify("No word under cursor.", vim.log.levels.WARN)
        return
      end

      local command_to_send

      if vim.fn.has("unix") == 1 then
        command_to_send =
          string.format("import linutils.cb_helper; linutils.cb_helper.to_clipboard(%s)", var_name)
        vim.notify("Using linutils.cb_helper.to_clipboard()", vim.log.levels.INFO)
      else
        command_to_send = string.format("%s.to_clipboard()", var_name)
        vim.notify("Using default .to_clipboard()", vim.log.levels.INFO)
      end
      vim.api.nvim_buf_set_lines(
        args.buf,
        current_line_1_indexed,
        current_line_1_indexed,
        false,
        { command_to_send }
      )
      vim.api.nvim_win_set_cursor(0, { current_line_1_indexed + 1, 0 })
      vim.cmd("normal! V")
      iron.visual_send()
      vim.notify(string.format("Sent to REPL: %s", command_to_send), vim.log.levels.INFO)
      vim.api.nvim_buf_set_lines(
        args.buf,
        current_line_1_indexed,
        current_line_1_indexed + 1,
        false,
        {}
      )
      vim.api.nvim_win_set_cursor(0, original_cursor_pos)
    end, {
      buffer = args.buf,
      desc = "repl_df_to_clipboard (OS-aware)",
    })
    local function create_repl_sender(key, desc, command_format_string)
      vim.keymap.set("n", key, function()
        local original_cursor_pos = vim.api.nvim_win_get_cursor(0)
        local current_line_1_indexed = original_cursor_pos[1]
        local var_name = vim.fn.expand("<cword>")
        if not var_name or var_name == "" then
          vim.notify("No word under cursor", vim.log.levels.WARN)
          return
        end
        local command_to_send = string.format(command_format_string, var_name)
        vim.api.nvim_buf_set_lines(
          args.buf,
          current_line_1_indexed,
          current_line_1_indexed,
          false,
          { command_to_send }
        )
        vim.api.nvim_win_set_cursor(0, { current_line_1_indexed + 1, 0 })
        vim.cmd("normal! V")
        iron.visual_send()
        vim.notify(string.format("Sent: %s", command_to_send), vim.log.levels.INFO)
        vim.api.nvim_buf_set_lines(
          args.buf,
          current_line_1_indexed,
          current_line_1_indexed + 1,
          false,
          {}
        )
        vim.api.nvim_win_set_cursor(0, original_cursor_pos)
      end, {
        buffer = args.buf, -- Keymap is buffer-local, requires args.buf
        desc = desc,
      })
    end
    create_repl_sender("<localleader>pp", "repl_print", "print(%s)")
    create_repl_sender("<localleader>pl", "repl_print_last", "print(%s.iloc[-1].T)")
    create_repl_sender("<localleader>pf", "repl_print_first", "print(%s.iloc[0].T)")
    create_repl_sender("<localleader>pi", "repl_print_info", "print(%s.info())")
    vim.keymap.set("v", "<CR>", function()
      iron.visual_send()
      vim.cmd("norm! j")
    end, { buffer = args.buf, desc = "repl_v_send" })
    vim.keymap.set({ "n", "v" }, "<localleader>u", function()
      iron.send_until_cursor()
      vim.api.nvim_input("<ESC>") -- to escape from visual mode
    end, { buffer = args.buf, desc = "repl_send_until" })
    vim.keymap.set(
      "n",
      "<localleader><PageUp>",
      ":wincmd w<CR><C-u>:wincmd p<CR>",
      { buffer = args.buf, noremap = true, silent = true, desc = "repl_prev" }
    )
    vim.keymap.set(
      "n",
      "<localleader><PageDown>",
      ":wincmd w<CR><C-d>:wincmd p<CR>",
      { buffer = args.buf, noremap = true, silent = true, desc = "repl_next" }
    )
    vim.keymap.set({ "n", "v" }, "<localleader>qq", function()
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
      "<localleader>]",
      "<cmd>IronFocus<cr>i",
      { buffer = args.buf, desc = "repl_focus" }
    )
    vim.keymap.set("n", "]]", function()
      vim.cmd("call JumpCell()")
      vim.cmd("norm! zvzz")
    end, { buffer = args.buf, desc = "repl_jump_cell_fwd" })
    vim.keymap.set("n", "[[", function()
      vim.cmd("call JumpCellBack()")
      vim.cmd("norm! zvzz")
    end, { buffer = args.buf, desc = "repl_jump_cell_back" })
    vim.keymap.set(
      "n",
      "<localleader>==",
      ":!ruff format %<cr>",
      { buffer = args.buf, desc = "repl_sync_format" }
    )
  end,
})

-- in cmdline use :lua =XYZ to shorthand :lua print(XYZ)
vim.api.nvim_create_autocmd("FileType", {
  pattern = "lua",
  group = vim.api.nvim_create_augroup("lua-repl", { clear = true }),
  callback = function(args)
    vim.keymap.set(
      "n",
      "<localleader><localleader>f",
      "<cmd>source %<CR>",
      { buffer = args.buf, desc = "execute lua file" }
    )
    vim.keymap.set(
      "n",
      "<localleader>l",
      ":.lua<cr>",
      { buffer = args.buf, desc = "execute lua line" }
    )
    vim.keymap.set("v", "<CR>", ":lua<cr>", { buffer = args.buf, desc = "execute lua line" })
  end,
})
