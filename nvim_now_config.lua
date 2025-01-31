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
    jump = { reuse_win = false },
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
          ["<ScrollWheelDown>"] = { "list_scroll_wheel_down", mode = { "i", "n" } },
          ["<ScrollWheelUp>"] = { "list_scroll_wheel_up", mode = { "i", "n" } },
          ["G"] = false,
          ["gg"] = false,
          ["j"] = false,
          ["k"] = false,
          ["/"] = false,
          ["q"] = false,
          ["?"] = false,
          ["<c-n>"] = false,
          ["<c-p>"] = false,
        },
        b = {
          minipairs_disable = true,
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
        },
      },
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
  "<leader>sd",
  "<cmd>lua MiniSessions.select('delete')<cr>",
  { desc = "session_delete" }
)
vim.keymap.set("n", "<leader>ss", function()
  SaveMiniSession()
end, { desc = "session_save" })

icon = require("mini.icons")
icon.setup()
icon.mock_nvim_web_devicons()

require("diffview").setup({
  view = {
    merge_tool = {
      layout = "diff3_mixed",
    },
  },
})
