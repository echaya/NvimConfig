Snacks = require("snacks")
require("snacks").setup({
  bigfile = { enabled = true },
  notifier = {
    enabled = true,
    timeout = 3000,
  },
  quickfile = { enabled = true },
  statuscolumn = { enabled = true, refresh = 50 },
  words = { enabled = true },
  indent = { enabled = true },
  scope = { enabled = true },
  styles = {
    notification = {
      wo = { wrap = true }, -- Wrap notifications
    },
    zen = { width = 160 },
  },
  zen = {
    toggles = {
      dim = false,
      git_signs = true,
    },
  },
  picker = {
    ---@class snacks.picker.matcher.Config
    win = {
      -- input window
      input = {
        keys = {
          ["<C-h>"] = { "toggle_help", mode = { "n", "i" } },
          ["<Esc>"] = { "close", mode = { "n", "i" } },
          ["<C-c>"] = { "close", mode = { "n", "i" } },
          ["<CR>"] = { "confirm", mode = { "n", "i" } },
          ["<a-d>"] = { "inspect", mode = { "n", "i" } },
          ["<a-m>"] = { "toggle_maximize", mode = { "i", "n" } },
          ["<a-p>"] = { "toggle_preview", mode = { "i", "n" } },
          ["<a-i>"] = { "toggle_ignored", mode = { "i", "n" } },
          ["<a-h>"] = { "toggle_hidden", mode = { "i", "n" } },
          ["<a-w>"] = { "cycle_win", mode = { "i", "n" } },
          ["<c-a>"] = "select_all",
          ["<C-w>"] = { "<c-s-w>", mode = { "i" }, expr = true, desc = "delete word" },
          ["<C-Up>"] = { "history_back", mode = { "i", "n" } },
          ["<C-Down>"] = { "history_forward", mode = { "i", "n" } },
          ["<Tab>"] = { "select_and_next", mode = { "i", "n" } },
          ["<S-Tab>"] = { "select_and_prev", mode = { "i", "n" } },
          ["<Down>"] = { "list_down", mode = { "i", "n" } },
          ["<Up>"] = { "list_up", mode = { "i", "n" } },
          ["<c-j>"] = { "list_down", mode = { "i", "n" } },
          ["<c-k>"] = { "list_up", mode = { "i", "n" } },
          ["<c-u>"] = { "preview_scroll_up", mode = { "i", "n" } },
          ["<c-f>"] = { "list_scroll_down", mode = { "i", "n" } },
          ["<c-b>"] = { "list_scroll_up", mode = { "i", "n" } },
          ["<c-d>"] = { "preview_scroll_down", mode = { "i", "n" } },
          ["<c-g>"] = { "toggle_live", mode = { "i", "n" } },
          ["<ScrollWheelDown>"] = { "list_scroll_wheel_down", mode = { "i", "n" } },
          ["<ScrollWheelUp>"] = { "list_scroll_wheel_up", mode = { "i", "n" } },
          ["<c-v>"] = { "edit_vsplit", mode = { "i", "n" } },
          ["<c-s>"] = { "edit_split", mode = { "i", "n" } },
          ["<c-q>"] = { "qflist", mode = { "i", "n" } },
          ["G"] = false,
          ["gg"] = false,
          ["j"] = false,
          ["k"] = false,
          ["/"] = false,
          ["q"] = false,
          ["?"] = false,
        },
        b = {
          minipairs_disable = true,
        },
      },
      -- result list window
      list = {
        keys = {
          ["<CR>"] = "confirm",
          ["gg"] = "list_top",
          ["G"] = "list_bottom",
          ["i"] = "focus_input",
          ["j"] = "list_down",
          ["k"] = "list_up",
          ["q"] = "close",
          ["<Tab>"] = "select_and_next",
          ["<S-Tab>"] = "select_and_prev",
          ["<Down>"] = "list_down",
          ["<Up>"] = "list_up",
          ["<a-d>"] = "inspect",
          ["<c-f>"] = "list_scroll_down",
          ["<c-b>"] = "list_scroll_up",
          ["zt"] = "list_scroll_top",
          ["zb"] = "list_scroll_bottom",
          ["zz"] = "list_scroll_center",
          ["/"] = "toggle_focus",
          ["<ScrollWheelDown>"] = "list_scroll_wheel_down",
          ["<ScrollWheelUp>"] = "list_scroll_wheel_up",
          ["<c-a>"] = "select_all",
          ["<c-d>"] = "preview_scroll_down",
          ["<c-u>"] = "preview_scroll_up",
          ["<c-v>"] = "edit_vsplit",
          ["<c-s>"] = "edit_split",
          ["<c-j>"] = "list_down",
          ["<c-k>"] = "list_up",
          ["<c-n>"] = "list_down",
          ["<c-p>"] = "list_up",
          ["<a-w>"] = "cycle_win",
          ["<Esc>"] = "close",
        },
      },
      -- preview window
      preview = {
        keys = {
          ["<Esc>"] = "close",
          ["q"] = "close",
          ["i"] = "focus_input",
          ["<ScrollWheelDown>"] = "list_scroll_wheel_down",
          ["<ScrollWheelUp>"] = "list_scroll_wheel_up",
          ["<a-w>"] = "cycle_win",
        },
      },
    },
  },
})

Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>ts")
Snacks.toggle
  .option("background", { off = "light", on = "dark", name = "Dark Background" })
  :map("<leader>tb")
Snacks.toggle.inlay_hints():map("<leader>th")

vim.keymap.set("n", "<leader>un", function()
  Snacks.notifier.hide()
end, { desc = "Dismiss All Notifications" })

vim.keymap.set("n", "<leader>bd", function()
  Snacks.bufdelete()
end, { desc = "Delete Buffer" })

vim.keymap.set("n", "<leader>fn", function()
  Snacks.notifier.show_history()
end, { desc = "find_notification" })

vim.keymap.set("n", "<leader>fm", "<cmd>messages<cr>", { desc = "find_messages" })

vim.keymap.set("n", "<leader>gB", function()
  Snacks.gitbrowse()
end, { desc = "Git Browse" })

vim.keymap.set({ "n", "t" }, "<a-.>", function()
  Snacks.lazygit()
end, { desc = "Lazygit" })

vim.keymap.set({ "n", "t" }, "<a-`>", function()
  Snacks.terminal()
end, { desc = "Toggle terminal" })

vim.keymap.set({ "n" }, "<leader>.", function()
  Snacks.scratch()
end, { desc = "Toggle Scratch Buffer" })

vim.keymap.set({ "n" }, "<leader>fS", function()
  Snacks.scratch.select()
end, { desc = "Find Scratch" })
vim.keymap.set("n", "<leader>z", function()
  Snacks.zen()
end, { desc = "Toggle Zen Mode" })
vim.keymap.set("n", "<leader>Z", function()
  Snacks.zen.zoom()
end, { desc = "Toggle Zoom" })
-- vim.highlight.priorities.semantic_tokens = 95 -- Or any number lower than 100, treesitter's priority level
require("kanagawa").setup({
  keywordStyle = { italic = false },
  transparent = false,
  colors = {
    theme = {
      all = {
        ui = {
          bg_gutter = "#16161d",
        },
      },
    },
  },
  overrides = function(colors)
    return {
      -- Assign a static color to strings
      -- String = { fg = colors.palette.carpYellow, italic = true },
      -- theme colors will update dynamically when you change theme!
      -- SomePluginHl = { fg = colors.theme.syn.type, bold = true },
      LineNr = { fg = "#7f848e" },
      MatchParen = { bg = "#505664", underline = true },
    }
  end,
})

local icon = require("mini.icons")
icon.setup()
icon.mock_nvim_web_devicons()
vim.g.nvim_web_devicons = 1

-- require("mini.tabline").setup()

local MiniStatusline = require("mini.statusline")
MiniStatusline.setup({
  content = {
    active = function()
      local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 10000 })
      local git = MiniStatusline.section_git({ trunc_width = 40 })
      local diff = MiniStatusline.section_diff({ trunc_width = 75 })
      local diagnostics = MiniStatusline.section_diagnostics({ trunc_width = 75 })
      local lsp = MiniStatusline.section_lsp({ trunc_width = 75 })
      local filename = MiniStatusline.section_filename({ trunc_width = 140 })
      local fileinfo = MiniStatusline.section_fileinfo({ trunc_width = 140 })

      return MiniStatusline.combine_groups({
        { hl = mode_hl, strings = { mode } },
        { hl = "MiniStatuslineDevinfo", strings = { git, diff, diagnostics } },
        "%<", -- Mark general truncate point
        { hl = "MiniStatuslineFilename", strings = { filename } },
        "%=", -- End left alignment
        { hl = "MiniStatuslineFileinfo", strings = { fileinfo, lsp } },
        { hl = mode_hl, strings = { tostring(vim.api.nvim_buf_line_count(0)) } },
      })
    end,
  },
})
local format_summary = function(data)
  local summary = vim.b[data.buf].minigit_summary
  vim.b[data.buf].minigit_summary_string = summary.head_name or ""
end

local au_opts = {
  group = vim.api.nvim_create_augroup("minigit-summary", { clear = true }),
  pattern = "MiniGitUpdated",
  callback = format_summary,
}
vim.api.nvim_create_autocmd("User", au_opts)

require("satellite").setup({
  handlers = {
    cursor = {
      enable = true,
      symbols = { ">" },
    },
  },
  excluded_filetypes = { "toggleterm", "NvimTree", "oil", "minifiles" },
})

require("noice").setup({
  lsp = {
    -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
    override = {
      ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
      ["vim.lsp.util.stylize_markdown"] = true,
      ["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
    },
  },
  signature = { auto_open = { throttle = 10 } },
  presets = {
    bottom_search = true, -- use a classic bottom cmdline for search
    command_palette = true, -- position the cmdline and popupmenu together
    long_message_to_split = true, -- long messages will be sent to a split
    inc_rename = false, -- enables an input dialog for inc-rename.nvim
    lsp_doc_border = true, -- add a border to hover docs and signature help
  },
})

vim.api.nvim_create_autocmd("RecordingEnter", {
  callback = function()
    local msg = string.format("Register:  %s", vim.fn.reg_recording())
    _MACRO_RECORDING_STATUS = true
    vim.notify(msg, vim.log.levels.INFO, {
      title = "Macro Recording",
      keep = function()
        return _MACRO_RECORDING_STATUS
      end,
    })
  end,
  group = vim.api.nvim_create_augroup("NoiceMacroNotfication", { clear = true }),
})

vim.api.nvim_create_autocmd("RecordingLeave", {
  callback = function()
    _MACRO_RECORDING_STATUS = false
    vim.notify("Success!", vim.log.levels.INFO, {
      title = "Macro Recording End",
      timeout = 2000,
    })
  end,
  group = vim.api.nvim_create_augroup("NoiceMacroNotficationDismiss", { clear = true }),
})

local starter = require("mini.starter")
starter.setup({
  evaluate_single = true,
  items = {
    -- starter.sections.sessions(10, true),
    -- starter.sections.recent_files(10, false),
    -- starter.sections.builtin_actions(),
    {
      action = "lua MiniSessions.read(MiniSessions.get_latest())",
      name = "Latest",
      section = "Sessions",
    },
    { action = "lua MiniSessions.select('read')", name = "Saved", section = "Sessions" },
    {
      action = "lua MiniSessions.select('delete')",
      name = "Delete",
      section = "Sessions",
    },
    { action = "lua MiniFiles.open()", name = "Explorer", section = "File Picker" },
    {
      action = "lua require('snacks').picker.files()",
      name = "Find files",
      section = "File Picker",
    },
    {
      action = "lua require('snacks').picker.recent()",
      name = "Recent files",
      section = "File Picker",
    },
    { action = "DepsUpdate", name = "Update", section = "Plugin" },
    { action = "DepsClean", name = "Clean", section = "Plugin" },
    { action = "enew", name = "New buffer", section = "Builtin actions" },
    { action = "qall!", name = "Quit neovim", section = "Builtin actions" },
  },
  content_hooks = {
    starter.gen_hook.adding_bullet(),
    starter.gen_hook.padding(vim.o.columns * 0.4, vim.o.lines * 0.25),
  },
  footer = os.date(),
  header = table.concat({
    [[
███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝]],
  }, "\n"),
  query_updaters = [[abcdefghilmnopqrstuvwxyz0123456789_-,.ABCDEFGHILMNOPQRSTUVWXYZ]],
})
vim.cmd([[
  augroup MiniStarterJK
    au!
    au User MiniStarterOpened nmap <buffer> j <Cmd>lua MiniStarter.update_current_item('next')<CR>
    au User MiniStarterOpened nmap <buffer> k <Cmd>lua MiniStarter.update_current_item('prev')<CR>
  augroup END
]])

vim.o.sessionoptions = "buffers,curdir,folds,globals,help,skiprtp,tabpages"
local mini_session = require("mini.sessions")
mini_session.setup({
  file = "",
  hooks = {
    pre = { read = SaveMiniSession },
  },
})

-- save session functions copy from nvim-session-manager
local function is_restorable(buffer)
  if #vim.api.nvim_get_option_value("bufhidden", { buf = buffer }) ~= 0 then
    return false
  end
  local buftype = vim.api.nvim_get_option_value("buftype", { buf = buffer })
  if #buftype == 0 then
    -- Normal buffer, check if it listed.
    if not vim.api.nvim_get_option_value("buflisted", { buf = buffer }) then
      return false
    end
    -- Check if it has a filename.
    if #vim.api.nvim_buf_get_name(buffer) == 0 then
      return false
    end
  elseif buftype ~= "terminal" and buftype ~= "help" then
    -- Buffers other then normal, terminal and help are impossible to restore.
    return false
  end
  return true
end

local clean_up_buffer = function()
  -- Remove all non-file and utility buffers because they cannot be saved.
  for _, buffer in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buffer) and not is_restorable(buffer) then
      vim.api.nvim_buf_delete(buffer, { force = true })
    end
  end
  -- Clear all passed arguments to avoid re-executing them.
  if vim.fn.argc() > 0 then
    vim.api.nvim_command("%argdel")
  end
end

SaveMiniSession = function()
  clean_up_buffer()
  local cwd = vim.fn.getcwd()
  cwd = cwd:gsub("[:/\\]$", ""):gsub(":", ""):gsub("[/\\]", "_")
  mini_session.write(cwd)
end

vim.keymap.set(
  "n",
  "<leader>fs",
  "<cmd>lua MiniSessions.select('read')<cr>",
  { desc = "find_session" }
)
vim.keymap.set(
  "n",
  "<leader>ds",
  "<cmd>lua MiniSessions.select('delete')<cr>",
  { desc = "delete_session" }
)
vim.keymap.set("n", "<leader>fS", function()
  SaveMiniSession()
end, { desc = "save_session" })

icon = require("mini.icons")
icon.setup()
icon.mock_nvim_web_devicons()

local animate = require("mini.animate")
animate.setup({
  cursor = {
    timing = animate.gen_timing.linear({ duration = 20, unit = "total" }),
    path = animate.gen_path.line({
      predicate = function()
        return true
      end,
    }),
  },
  scroll = {
    timing = animate.gen_timing.linear({ duration = 40, unit = "total" }),
    subscroll = animate.gen_subscroll.equal({ max_output_steps = 40 }),
  },
  resize = { enable = false },
  open = { enable = false },
  close = { enable = false },
})
vim.keymap.set(
  "n",
  "<C-d>",
  [[<Cmd>lua vim.cmd('normal! <C-d>'); MiniAnimate.execute_after('scroll', 'normal! zvzz')<CR>]]
)
vim.keymap.set(
  "n",
  "<C-u>",
  [[<Cmd>lua vim.cmd('normal! <C-u>'); MiniAnimate.execute_after('scroll', 'normal! zvzz')<CR>]]
)

vim.keymap.set(
  "n",
  "n",
  [[<Cmd>lua vim.cmd('normal! n'); MiniAnimate.execute_after('scroll', 'normal! zvzz')<CR>]]
)
vim.keymap.set(
  "n",
  "N",
  [[<Cmd>lua vim.cmd('normal! N'); MiniAnimate.execute_after('scroll', 'normal! zvzz')<CR>]]
)

require("diffview").setup({
  view = {
    merge_tool = {
      layout = "diff3_mixed",
    },
  },
})
