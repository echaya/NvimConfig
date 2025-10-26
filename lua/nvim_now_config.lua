require("mini.basics").setup({
  options = { extra_ui = true },
  mappings = { windows = true, option_toggle_prefix = "|" },
})

Snacks = require("snacks")
vim.keymap.set("n", "<leader><leader>", function()
  Snacks.picker.smart()
end, { desc = "smart_open" })
vim.keymap.set("n", "<leader>ff", function()
  Snacks.picker.files()
end, { desc = "find_file" })
vim.keymap.set("n", "<leader>fb", function()
  Snacks.picker.buffers()
end, { desc = "find_buffers" })
vim.keymap.set("n", "<leader>fr", function()
  Snacks.picker.recent()
end, { desc = "find_recent" })
vim.keymap.set("n", "<leader>e", function()
  Snacks.picker.explorer()
  vim.defer_fn(function()
    vim.cmd("wincmd =")
  end, 100)
end, { desc = "find_file" })
vim.keymap.set("n", "<leader>fh", function()
  Snacks.picker.help()
end, { desc = "find_help" })
vim.keymap.set("n", "<leader>fp", function()
  Snacks.picker.files({ cwd = vim.fs.joinpath(vim.fn.stdpath("data"), "site") })
end, { desc = "find_plugin" })
vim.keymap.set("n", "<leader>pp", function()
  Snacks.picker.pickers()
end, { desc = "find_plugin" })
vim.keymap.set("n", "<leader>fk", function()
  Snacks.picker.keymaps()
end, { desc = "find_keymaps" })
vim.keymap.set("n", "<leader>fz", function()
  Snacks.picker.zoxide()
end, { desc = "find_zoxide" })
vim.keymap.set("n", "<leader>fd", function()
  Snacks.picker.diagnostics()
end, { desc = "lsp_diagnostics" })
vim.keymap.set("n", "<leader>fu", function()
  Snacks.picker.undo()
end, { desc = "find_undo" })
vim.keymap.set("n", '<leader>"', function()
  Snacks.picker.registers()
end, { desc = "registers" })
vim.keymap.set("n", "<leader>`", function()
  Snacks.picker.marks()
end, { desc = "marks" })
vim.keymap.set("n", "<leader>/", function()
  Snacks.picker.grep()
end, { desc = "live_grep" })
vim.keymap.set("n", "<leader>gw", function()
  Snacks.picker.grep_word()
end, { desc = "grep_string" })

Snacks.toggle.option("spell", { name = "Spelling" }):map("|s")
Snacks.toggle.option("wrap", { name = "Wrap" }):map("|w")
Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("|r")
Snacks.toggle.option("number", { name = "Number" }):map("|n")
Snacks.toggle.option("hlsearch", { name = "Highlight search" }):map("|h")
Snacks.toggle.option("ignorecase", { name = "Ignorecase" }):map("|i")
Snacks.toggle
  .option("background", { off = "light", on = "dark", name = "Dark Background" })
  :map("|b")
Snacks.toggle.inlay_hints():map("|H")
Snacks.toggle.animate():map("|a")
Snacks.toggle.diagnostics():map("|d")
Snacks.toggle
  .option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 })
  :map("|l")
Snacks.toggle({
  name = "TableMode",
  get = function()
    return vim.b.table_mode_enabled == true
  end,
  set = function(state)
    local current_state_is_active = vim.b.table_mode_enabled
    if state ~= current_state_is_active then
      vim.cmd("TableModeToggle")
      vim.b.table_mode_enabled = state and true or false
    end
  end,
}):map("|t")

Snacks.toggle({
  name = "VerticalCursor",
  get = function()
    return vim.g.snacks_vertical_cursor_enabled == true
  end,

  set = function(desired_state)
    vim.g.snacks_vertical_cursor_enabled = desired_state
    vim.fn.call("ApplyCursorLine", {})
  end,
}):map("|C")
Snacks.toggle({
  name = "CursorLine",

  get = function()
    return vim.g.snacks_main_cursorline_enabled == 1
  end,

  set = function(desired_state)
    vim.g.snacks_main_cursorline_enabled = desired_state and 1 or 0
    vim.fn.call("ApplyCursorLine", {})
  end,
}):map("|c")

vim.keymap.set("n", "<leader>un", function()
  Snacks.notifier.hide()
end, { desc = "Dismiss All Notifications" })

vim.keymap.set("n", "<leader>bd", function()
  Snacks.bufdelete()
end, { desc = "Delete Buffer" })

vim.keymap.set("n", "<leader>n", function()
  Snacks.notifier.show_history()
end, { desc = "notification_history" })

vim.keymap.set("n", "<leader>fm", "<cmd>messages<cr>", { desc = "find_messages" })

vim.keymap.set("n", "<leader>gb", function()
  Snacks.git.blame_line()
end, { desc = "Git Browse" })
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

vim.keymap.set({ "n" }, "<leader>fs", function()
  Snacks.scratch.select()
end, { desc = "Find Scratch" })

vim.keymap.set("n", "<leader>z", function()
  Snacks.zen()
end, { desc = "Toggle Zen Mode" })
vim.keymap.set("n", "<leader>Z", function()
  Snacks.zen.zoom()
end, { desc = "Toggle Zoom" })

Snacks.setup({
  bigfile = { enabled = true },
  notifier = {
    enabled = true,
    timeout = 3000,
  },
  quickfile = { enabled = true },
  statuscolumn = { enabled = true },
  words = { enabled = true },
  indent = { enabled = true },
  scope = { enabled = true },
  scroll = {
    enabled = true,
    animate = {
      duration = { step = 15, total = 150 },
      easing = "linear",
    },
  },
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
    win = {
      width = 160,
      wo = {
        winblend = 0,
      },
    },
  },
  picker = {
    win = {
      -- input window
      input = {
        keys = {
          ["<C-/>"] = { "toggle_help", mode = { "n", "i" } },
          ["<Esc>"] = { "close", mode = { "n", "i" } },
          ["<C-c>"] = { "close", mode = { "n", "i" } },
          ["<Up>"] = { "history_back", mode = { "i", "n" } },
          ["<Down>"] = { "history_forward", mode = { "i", "n" } },
          ["<c-u>"] = { "preview_scroll_up", mode = { "i", "n" } },
          ["<c-d>"] = { "preview_scroll_down", mode = { "i", "n" } },
          ["<c-b>"] = { "list_scroll_up", mode = { "i", "n" } },
          ["<c-f>"] = { "list_scroll_down", mode = { "i", "n" } },
          ["/"] = false,
          ["<c-n>"] = false,
          ["<c-p>"] = false,
          ["<a-l>"] = { "toggle_focus", mode = { "i", "n" } },
        },
      },
      -- result list window
      list = {
        keys = {
          ["<c-b>"] = "list_scroll_up",
          ["<c-f>"] = "list_scroll_down",
          ["<c-d>"] = "preview_scroll_down",
          ["<c-u>"] = "preview_scroll_up",
          ["<Down>"] = false,
          ["<Up>"] = false,
          ["<c-n>"] = false,
          ["<c-p>"] = false,
          ["/"] = false,
          ["<a-l>"] = { "toggle_focus", mode = { "i", "n" } },
        },
      },
      preview = {
        keys = {
          ["<Esc>"] = "close",
          ["q"] = "close",
          ["i"] = "focus_input",
          ["<a-w>"] = "cycle_win",
        },
      },
    },
    db = {
      sqlite3_path = "c:/tools/CliTools/sqlite3.dll",
    },
  },
})

-- vim.highlight.priorities.semantic_tokens = 95 -- Or any number lower than 100, treesitter's priority level
require("kanagawa").setup({
  keywordStyle = { italic = false },
  transparent = false,
  colors = {
    theme = {
      all = {
        ui = {
          bg_gutter = "",
        },
      },
    },
  },
  overrides = function(_)
    return {
      -- Assign a static color to strings
      -- String = { fg = colors.palette.carpYellow, italic = true },
      -- theme colors will update dynamically when you change theme!
      -- SomePluginHl = { fg = colors.theme.syn.type, bold = true },
      LineNr = { fg = "#7f848e" },
      MatchParen = { bg = "#505664", underline = true },
      ["@variable.builtin"] = { italic = false },
    }
  end,
})

local icon = require("mini.icons")
icon.setup()
icon.mock_nvim_web_devicons()
vim.g.nvim_web_devicons = 1

local MiniStatusline = require("mini.statusline")
MiniStatusline.setup({
  content = {
    active = function()
      local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 10000 })
      local git = MiniStatusline.section_git({ trunc_width = 40 })
      local diff = MiniStatusline.section_diff({ trunc_width = 75 })
      local diagnostics = MiniStatusline.section_diagnostics({ trunc_width = 75 })
      local lsp = MiniStatusline.section_lsp({ trunc_width = 75 })
      local filename = MiniStatusline.section_filename({ trunc_width = 300 })
      local fileinfo = MiniStatusline.section_fileinfo({ trunc_width = 300 })

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

local MiniStarter = require("mini.starter")
MiniStarter.setup({
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
    {
      action = 'lua Snacks.terminal("cd d:/Workspace/SiteRepo/; ./UpdateSite.bat; exit")',
      name = "GithubSync",
      section = "Plugin",
    },
    { action = "enew", name = "New buffer", section = "Builtin actions" },
    { action = "qall!", name = "Quit neovim", section = "Builtin actions" },
  },
  content_hooks = {
    MiniStarter.gen_hook.adding_bullet(),
    MiniStarter.gen_hook.padding(vim.o.columns * 0.4, vim.o.lines * 0.25),
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
mini_session.setup({ file = "" })

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
  "<leader>ss",
  "<cmd>lua MiniSessions.select('read')<cr>",
  { desc = "session_load" }
)
vim.keymap.set(
  "n",
  "<leader>sd",
  "<cmd>lua MiniSessions.select('delete')<cr>",
  { desc = "session_delete" }
)
vim.keymap.set("n", "<leader>sS", function()
  SaveMiniSession()
end, { desc = "session_save" })

icon = require("mini.icons")
icon.setup()
icon.mock_nvim_web_devicons()

local actions = require("diffview.actions")
require("diffview").setup({
  view = {
    merge_tool = {
      layout = "diff3_mixed",
      disable_diagnostics = true,
    },
  },
  keymaps = {
    disable_defaults = false, -- Disable the default keymaps
    file_panel = {
      {
        "n",
        "<leader>",
        actions.toggle_stage_entry,
        { desc = "Stage / unstage the selected entry" },
      },
      {
        "n",
        "a",
        actions.stage_all,
        { desc = "Stage all entries" },
      },
      ["s"] = false,
      ["S"] = false,
      ["-"] = false,
    },
  },
})
