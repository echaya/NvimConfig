local snacks = require("snacks")
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
  styles = {
    notification = {
      wo = { wrap = true }, -- Wrap notifications
    },
  },
})

snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>ts")
snacks.toggle
  .option("background", { off = "light", on = "dark", name = "Dark Background" })
  :map("<leader>tb")
snacks.toggle.inlay_hints():map("<leader>th")
Snacks.toggle.indent():map("<leader>ti")
Snacks.toggle.dim():map("<leader>tD")

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

icon = require("mini.icons")
icon.setup()
icon.mock_nvim_web_devicons()
vim.g.nvim_web_devicons = 1

-- Eviline config for lualine
local lualine = require("lualine")
local navic = require("nvim-navic")
navic.setup({ separator = "  " })

-- Color table for highlights
-- stylua: ignore
local colors = {
  bg       = '#16161D',
  fg       = '#727169',
  -- fg       = '#DCD7BA',
  yellow   = '#DCA561',
  cyan     = '#6A9589',
  darkblue = '#252535',
  green    = '#76946A',
  orange   = '#FF9E3B',
  violet   = '#957FB8',
  magenta  = '#D27E99',
  blue     = '#7E9CD8',
  red      = '#C34043',
}

local mode_color = {
  n = colors.green,
  i = colors.blue,
  v = colors.violet,
  [""] = colors.violet,
  V = colors.violet,
  c = colors.orange,
  no = colors.orange,
  s = colors.violet,
  S = colors.violet,
  [""] = colors.violet,
  ic = colors.blue,
  R = colors.orange,
  Rv = colors.orange,
  cv = colors.orange,
  ce = colors.orange,
  r = colors.cyan,
  rm = colors.cyan,
  ["r?"] = colors.cyan,
  ["!"] = colors.red,
  t = colors.magenta,
}

local conditions = {
  buffer_not_empty = function()
    return vim.fn.empty(vim.fn.expand("%:t")) ~= 1
  end,
  hide_in_width = function()
    return vim.fn.winwidth(0) > 80
  end,
  check_git_workspace = function()
    local filepath = vim.fn.expand("%:p:h")
    local gitdir = vim.fn.finddir(".git", filepath .. ";")
    return gitdir and #gitdir > 0 and #gitdir < #filepath
  end,
}

-- Config
local config = {
  options = {
    -- Disable sections and component separators
    component_separators = "",
    section_separators = "",
    theme = {
      -- We are going to use lualine_c an lualine_x as left and
      -- right section. Both are highlighted by c theme .  So we
      -- are just setting default looks o statusline
      normal = { c = { fg = colors.fg, bg = colors.bg } },
      inactive = {
        c = { fg = colors.fg, bg = colors.bg },
        b = { fg = colors.fg, bg = colors.bg },
      },
    },
  },
  sections = {
    -- these are to remove the defaults
    lualine_a = {},
    lualine_b = {},
    lualine_y = {},
    lualine_z = {},
    -- These will be filled later
    lualine_c = {},
    lualine_x = {},
  },
  inactive_sections = {
    -- these are to remove the defaults
    lualine_a = {},
    lualine_b = { "%=" },
    lualine_c = { "filename" },
    -- color = { fg = colors.cyan, gui = 'bold' },
    lualine_y = {},
    lualine_z = {},
    lualine_x = {},
  },

  tabline = {
    lualine_c = {},
    lualine_b = {},
    lualine_a = {
      {
        "buffers",
        show_filename_only = true, -- Shows shortened relative path when set to false.
        hide_filename_extension = false, -- Hide filename extension when set to true.
        show_modified_status = true, -- Shows indicator when the buffer is modified.
        max_length = vim.o.columns * 4 / 5,
        mode = 4,
        filetype_names = {
          TelescopePrompt = "Telescope",
          minifiles = "mini.files",
        }, -- Shows specific buffer name for that filetype ( { `filetype` = `buffer_name`, ... } )
        use_mode_colors = false,
        buffers_color = {
          active = { fg = colors.magenta, bg = colors.bg },
          inactive = { fg = colors.fg, bg = colors.bg },
        },
      },
    },
    lualine_x = {},
    lualine_y = {},
    lualine_z = {
      {
        "tabs",
        tabs_color = {
          active = { fg = colors.orange, bg = colors.bg },
          inactive = { fg = "#7f848e", bg = colors.bg },
        },
      },
    },
  },
  winbar = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {},
    lualine_x = {},
    lualine_y = {},
    lualine_z = {},
  },
  inactive_winbar = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {},
    lualine_x = {},
    lualine_y = {},
    lualine_z = {},
  },
}

-- Inserts a component in lualine_c at left section
local function ins_left(component)
  table.insert(config.sections.lualine_c, component)
end

-- Inserts a component in lualine_x at right section
local function ins_right(component)
  table.insert(config.sections.lualine_x, component)
end

-- ins_left({
--   -- mode component
--   function()
--     return " "
--   end,
--   color = function()
--     -- auto change color according to neovims mode
--     return { fg = mode_color[vim.fn.mode()] }
--   end,
--   padding = { left = 0, right = 0 },
-- })

ins_left({
  "mode",
  color = function()
    return { bg = mode_color[vim.fn.mode()], fg = colors.darkblue, gui = "bold" }
  end,
})

ins_left({
  "branch",
  icon = "",
  color = function()
    return { fg = mode_color[vim.fn.mode()], gui = "bold" }
  end,
})

ins_left({
  "diff",
  -- Is it me or the symbol for modified us really weird
  symbols = { added = " ", modified = "󰝤 ", removed = " " },
  diff_color = {
    added = { fg = colors.green },
    modified = { fg = colors.orange },
    removed = { fg = colors.red },
  },
  cond = conditions.hide_in_width,
})

ins_left({
  function()
    return "%="
  end,
})

-- ins_left({"filetype", color = { fg = colors.bg, gui = "bold" }})
ins_left({
  "filename",
  cond = conditions.buffer_not_empty,
  color = { fg = colors.magenta }, -- gui = "bold" },
})

ins_left({
  "navic",
  color_correction = "dynamic",
  navic_opts = { highlight = true },
  cond = function()
    return navic.is_available()
  end,
})

ins_right({
  -- Lsp server name .
  function()
    local msg = ""
    local buf_ft = vim.api.nvim_buf_get_option(0, "filetype")
    local clients = vim.lsp.get_active_clients()
    if next(clients) == nil then
      return msg
    end
    for _, client in ipairs(clients) do
      local filetypes = client.config.filetypes
      if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
        -- return client.name
        return " "
      end
    end
    return msg
  end,
  -- icon = " ",
  color = { fg = "#DCD7BA", gui = "italic" },
})

ins_right({
  "diagnostics",
  sources = { "nvim_diagnostic" },
  symbols = { error = " ", warn = " ", info = " ", hint = " " },
  diagnostics_color = {
    error = { fg = colors.red },
    warn = { fg = colors.yellow },
    info = { fg = colors.cyan },
    hint = { fg = colors.blue },
  },
})
-- ins_left({"filetype", color = { fg = colors.bg, gui = "bold" }})

ins_right({
  "fileformat",
  -- fmt = string.upper,
  icons_enabled = true,
  color = { fg = colors.yellow }, -- gui = "bold" },
})

ins_right({
  "o:encoding", -- option component same as &encoding in viml
  fmt = string.upper, -- I'm not sure why it's upper case either ;)
  cond = conditions.hide_in_width,
  color = { fg = colors.yellow }, -- gui = "bold" },
})

ins_right({
  "location",
  color = function()
    return { fg = mode_color[vim.fn.mode()], gui = "bold" }
  end,
})

ins_right({
  -- filesize by number of lines
  function()
    return vim.api.nvim_buf_line_count(0)
  end,
  cond = conditions.buffer_not_empty,
  icon = " ",
  color = function()
    return { bg = mode_color[vim.fn.mode()], fg = colors.darkblue, gui = "bold" }
  end,
})

-- ins_right({ "progress" })

lualine.setup(config)

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
    { action = "Telescope find_files", name = "Find files", section = "File Picker" },
    { action = "Telescope oldfiles", name = "Old files", section = "File Picker" },
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

vim.o.sessionoptions =
  "buffers,curdir,folds,globals,help,localoptions,resize,skiprtp,tabpages,winpos,winsize"

mini_session = require("mini.sessions")
mini_session.setup({
  autoread = false,
  directory = vim.fn.stdpath("data") .. "/session/",
  file = "",
  hooks = {
    pre = { read = save_session },
  },
})
-- auto save session
local save_session = function()
  local cwd = vim.fn.getcwd()
  cwd = cwd:gsub("[:/\\]$", ""):gsub(":", ""):gsub("[/\\]", "_")
  mini_session.write(cwd)
end

vim.api.nvim_create_autocmd({ "VimLeavePre" }, {
  callback = function()
    save_session()
  end,
})
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
  save_session()
end, { desc = "save_session" })

icon = require("mini.icons")
icon.setup()
icon.mock_nvim_web_devicons()
