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

-- Предполагается, что это находится в вашем файле конфигурации nvim,
-- например, init.lua или в специальном файле для yarepl.

local yarepl = require("yarepl")

yarepl.setup({
  -- buflisted = true, -- Default, REPL buffer will appear in buffer list
  scratch = true, -- Default, REPL buffer is a scratch buffer
  -- ft = 'REPL', -- Default filetype for REPL buffer
  close_on_exit = true, -- Default, closes window when REPL process exits
  scroll_to_bottom_after_sending = true, -- Default
  -- format_repl_buffers_names = true, -- Default

  metas = {
    ipython = {
      cmd = { "ipython", "--no-autoindent" },
      formatter = "bracketed_pasting", -- Maps to iron's bracketed_paste
      source_syntax = "ipython", -- Useful for REPLSourceVisual/Operator if you use them
      -- This wincmd function replicates your iron.nvim dynamic vertical split
      wincmd = function(bufnr, _repl_name)
        local width = math.floor(math.max(vim.o.columns * 0.35, 80))
        local current_win_id = vim.api.nvim_get_current_win()

        -- Ensure 'splitright' is set if we want 'botright vertical' to behave as typical vertical split to the right
        local old_splitright = vim.o.splitright
        vim.o.splitright = true
        vim.cmd(string.format("vertical botright %d split", width))
        vim.o.splitright = old_splitright

        local new_win_id = vim.api.nvim_get_current_win() -- new split becomes current
        vim.api.nvim_win_set_buf(new_win_id, bufnr)

        -- Optional: yarepl might handle focusing the REPL or returning to original window.
        -- If you want to ensure focus stays on the original window after REPL opens:
        -- vim.api.nvim_set_current_win(current_win_id)
        -- If you want to focus the REPL (usually the case):
        -- vim.api.nvim_input('i') -- or similar if you want to go to insert mode in REPL
      end,
    },
    -- You can define other REPLs here if needed
  },
  os = {
    windows = {
      send_delayed_cr_after_sending = true, -- Default, good for Windows
    },
  },
})

-- Autocmd to set up Python-specific keybindings
vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  group = vim.api.nvim_create_augroup("python-repl-yarepl", { clear = true }),
  callback = function(args)
    local start_repl = function()
      vim.cmd("REPLStart! ipython")
      vim.cmd("wincmd p")
      vim.cmd("wincmd =") -- Original command to resize, yarepl's wincmd handles initial size.
    end
    -- TODO: norm! gv after REPLStart or restart (user's original TODO)
    vim.keymap.set(
      { "n", "v" },
      [[<a-\>]],
      start_repl,
      { buffer = args.buf, desc = "yarepl_start_attach_ipython" }
    )

    vim.keymap.set({ "n", "v" }, "<localleader>r", function()
      vim.cmd("REPLExec $ipython exit()")
      vim.cmd("REPLClose ipython") -- Close the window
      vim.defer_fn(function()
        start_repl()
      end, 500)
    end, { buffer = args.buf, desc = "yarepl_restart_ipython" })

    -- Sends a carriage return to the ipython REPL
    local send_cr_to_ipython = function()
      -- REPLExec sends command. Sending literal CR.
      -- Using string.char(13) which is \r
      -- $ipython ensures it goes to an ipython instance.
      vim.cmd("REPLExec $ipython " .. vim.fn.nr2char(13))
    end

    vim.keymap.set("t", [[<a-\>]], "<cmd>q<cr>", { desc = "yarepl_terminal_quit_window" }) -- This is for the terminal window itself
    vim.keymap.set(
      "n",
      "<localleader><cr>",
      send_cr_to_ipython,
      { buffer = args.buf, desc = "yarepl_cr_ipython" }
    )
    vim.keymap.set(
      "n",
      "<C-CR>",
      send_cr_to_ipython,
      { buffer = args.buf, desc = "yarepl_cr_ipython" }
    )

    vim.keymap.set("n", "<S-CR>", function()
      vim.cmd("call SelectVisual()") -- User's custom function
      vim.cmd("REPLSendVisual ipython")
      vim.cmd("norm! j")
    end, { buffer = args.buf, desc = "yarepl_send_cell_visual_ipython" })

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

      -- This complex buffer manipulation logic remains the same
      vim.api.nvim_buf_set_lines(
        args.buf,
        current_line_1_indexed,
        current_line_1_indexed,
        false,
        { command_to_send }
      )
      vim.api.nvim_win_set_cursor(0, { current_line_1_indexed + 1, 0 })
      vim.cmd("normal! V")
      vim.cmd("REPLSendVisual ipython")
      vim.notify(string.format("Sent to REPL: %s", command_to_send), vim.log.levels.INFO)
      vim.api.nvim_buf_set_lines(
        args.buf,
        current_line_1_indexed,
        current_line_1_indexed + 1,
        false,
        {}
      )
      vim.api.nvim_win_set_cursor(0, original_cursor_pos)
    end, { buffer = args.buf, desc = "yarepl_df_to_clipboard_os_aware_ipython" })

    local function create_repl_sender_yarepl(key, desc, command_format_string)
      vim.keymap.set("n", key, function()
        local original_cursor_pos = vim.api.nvim_win_get_cursor(0)
        local current_line_1_indexed = original_cursor_pos[1]
        local var_name = vim.fn.expand("<cword>")
        if not var_name or var_name == "" then
          vim.notify("No word under cursor", vim.log.levels.WARN)
          return
        end
        local command_to_send = string.format(command_format_string, var_name)
        -- Buffer manipulation logic remains the same
        vim.api.nvim_buf_set_lines(
          args.buf,
          current_line_1_indexed,
          current_line_1_indexed,
          false,
          { command_to_send }
        )
        vim.api.nvim_win_set_cursor(0, { current_line_1_indexed + 1, 0 })
        vim.cmd("normal! V")
        vim.cmd("REPLSendVisual ipython")
        vim.notify(string.format("Sent: %s", command_to_send), vim.log.levels.INFO)
        vim.api.nvim_buf_set_lines(
          args.buf,
          current_line_1_indexed,
          current_line_1_indexed + 1,
          false,
          {}
        )
        vim.api.nvim_win_set_cursor(0, original_cursor_pos)
      end, { buffer = args.buf, desc = desc .. "_ipython" })
    end

    create_repl_sender_yarepl("<localleader>pp", "yarepl_print", "print(%s)")
    create_repl_sender_yarepl("<localleader>pl", "yarepl_print_last", "print(%s.iloc[-1].T)")
    create_repl_sender_yarepl("<localleader>pf", "yarepl_print_first", "print(%s.iloc[0].T)")
    create_repl_sender_yarepl("<localleader>pi", "yarepl_print_info", "print(%s.info())")

    vim.keymap.set("v", "<CR>", function()
      vim.cmd("REPLSendVisual ipython")
      vim.cmd("norm! j")
    end, { buffer = args.buf, desc = "yarepl_v_send_ipython" })

    vim.keymap.set({ "n", "v" }, "<localleader>u", function()
      -- iron.send_until_cursor() equivalent: visually select then send
      local original_cursor_pos = vim.api.nvim_win_get_cursor(0) -- [line, col]
      vim.cmd("normal! ggVG") -- Select from start of file to current line
      -- If you only want up to cursor, not whole lines:
      -- vim.fn.execute("normal! ggv" .. original_cursor_pos[1] .. "G" .. original_cursor_pos[2] .. "l")
      vim.cmd("REPLSendVisual ipython")
      vim.api.nvim_input("<ESC>") -- Exit visual mode
      vim.api.nvim_win_set_cursor(0, original_cursor_pos) -- Restore cursor
    end, { buffer = args.buf, desc = "yarepl_send_until_cursor_ipython" })

    -- REPL Window Scrolling: yarepl focuses the REPL window. Standard terminal scrolling works there.
    -- To scroll without focusing manually first:
    local scroll_repl_window = function(scroll_cmd)
      local current_w = vim.api.nvim_get_current_win()
      vim.cmd("REPLFocus ipython") -- Focus the ipython REPL window
      vim.api.nvim_feedkeys(
        vim.api.nvim_replace_termcodes(scroll_cmd, true, false, true),
        "n",
        true
      )
      vim.api.nvim_set_current_win(current_w) -- Return to original window
    end

    vim.keymap.set("n", "<localleader><PageUp>", function()
      scroll_repl_window("<C-u>")
    end, { buffer = args.buf, desc = "yarepl_scroll_prev_ipython" })
    vim.keymap.set("n", "<localleader><PageDown>", function()
      scroll_repl_window("<C-d>")
    end, { buffer = args.buf, desc = "yarepl_scroll_next_ipython" })

    vim.keymap.set({ "n", "v" }, "<localleader>qq", function()
      -- To make ipython exit, send 'exit()' or 'quit()'
      vim.cmd("REPLExec $ipython exit()")
      vim.cmd("REPLClose ipython") -- Close the window
      -- The iron.send(nil, string.char(13)) after close_repl was likely to confirm exit in the terminal.
      -- REPLExec exit() should handle it.
    end, { buffer = args.buf, desc = "yarepl_exit_ipython" })

    vim.keymap.set({ "n", "v" }, "<localleader>c", function()
      -- Send Ctrl-C (ASCII 03)
      vim.cmd("REPLExec $ipython " .. vim.fn.nr2char(3))
    end, { buffer = args.buf, desc = "yarepl_interrupt_ipython" })

    vim.keymap.set({ "n", "v" }, "<a-del>", function()
      -- Send Ctrl-L (ASCII 12) to clear screen
      vim.cmd("REPLExec $ipython " .. vim.fn.nr2char(12))
    end, { buffer = args.buf, desc = "yarepl_clear_ipython" })

    vim.keymap.set(
      "n",
      "<localleader>]",
      "<cmd>REPLFocus ipython<cr>i",
      { buffer = args.buf, desc = "yarepl_focus_insert_ipython" }
    )

    -- These are custom functions, they should work as is if defined elsewhere
    vim.keymap.set("n", "]]", function()
      vim.cmd("call JumpCell()")
      vim.cmd("norm! zvzz")
    end, { buffer = args.buf, desc = "yarepl_jump_cell_fwd" })

    vim.keymap.set("n", "[[", function()
      vim.cmd("call JumpCellBack()")
      vim.cmd("norm! zvzz")
    end, { buffer = args.buf, desc = "yarepl_jump_cell_back" })

    vim.keymap.set(
      "n",
      "<localleader>==",
      ":!ruff format %<cr>",
      { buffer = args.buf, desc = "format_ruff_sync" }
    )
  end,
})

print("yarepl.nvim configuration for Python loaded.")
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
