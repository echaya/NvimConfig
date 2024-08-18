require("onedarkpro").setup({
  styles = {
    types = "italic",
    methods = "NONE",
    numbers = "NONE",
    strings = "NONE",
    comments = "italic",
    keywords = "bold",
    constants = "bold",
    functions = "italic",
    operators = "NONE",
    variables = "NONE",
    parameters = "NONE",
    conditionals = "bold",
    virtual_text = "NONE",
  },
  options = {
    cursorline = true,
    transparency = false,
  },
  highlights = {
    ["@variable"] = {},
    ["@variable.member"] = {},
    LineNr = { fg = "#7f848e" },
    MatchParen = { bg = "#505664", underline = true },
  },
})

-- Eviline config for lualine
-- Author: shadmansaleh
-- Credit: glepnir
local lualine = require("lualine")
local navic = require("nvim-navic")
navic.setup({
  separator = "  ",
})

-- Color table for highlights
-- stylua: ignore
local colors = {
  bg       = '#202328',
  fg       = '#bbc2cf',
  yellow   = '#ECBE7B',
  cyan     = '#008080',
  darkblue = '#081633',
  green    = '#98be65',
  orange   = '#FF8800',
  violet   = '#a9a1e1',
  magenta  = '#c678dd',
  blue     = '#51afef',
  red      = '#ec5f67',
}

local mode_color = {
  n = colors.green,
  i = colors.blue,
  v = colors.magenta,
  [""] = colors.magenta,
  V = colors.magenta,
  c = colors.orange,
  no = colors.orange,
  s = colors.magenta,
  S = colors.magenta,
  [""] = colors.magenta,
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
    lualine_a = {},
    lualine_b = {},
    lualine_c = {
      {
        "buffers",
        show_filename_only = true, -- Shows shortened relative path when set to false.
        hide_filename_extension = false, -- Hide filename extension when set to true.
        show_modified_status = true, -- Shows indicator when the buffer is modified.
        max_length = vim.o.columns * 4 / 5,
        mode = 4,
        filetype_names = {
          TelescopePrompt = "Telescope",
        }, -- Shows specific buffer name for that filetype ( { `filetype` = `buffer_name`, ... } )
        use_mode_colors = false,
        buffers_color = {
          active = { fg = colors.magenta, bg = colors.bg },
          inactive = { fg = "#7f848e", bg = colors.bg },
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
    lualine_a = {
      {
        "navic",
        color_correction = "dynamic",
        navic_opts = { highlight = true },
      },
    },
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
    -- auto change color according to neovims mode
    return { bg = mode_color[vim.fn.mode()], fg = colors.darkblue, gui = "bold" }
  end,
})

ins_left({
  "branch",
  icon = "",
  color = { fg = colors.yellow, gui = "bold" },
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
-- ins_left {
--   -- filesize component
--   'filesize',
--   cond = conditions.buffer_not_empty,
-- }

ins_left({
  function()
    return "%="
  end,
})

ins_left({
  "filename",
  cond = conditions.buffer_not_empty,
  color = { fg = colors.magenta, gui = "bold" },
})

-- Insert mid section. You can make any number of sections in neovim :)
-- for lualine it's any number greater then 2

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
        return "lsp"
      end
    end
    return msg
  end,
  icon = " ",
  color = { fg = "#ffffff", gui = "italic" },
})

ins_right({
  "diagnostics",
  sources = { "nvim_diagnostic" },
  symbols = { error = " ", warn = " ", info = " " },
  diagnostics_color = {
    error = { fg = colors.red },
    warn = { fg = colors.yellow },
    info = { fg = colors.cyan },
  },
})

-- Add components to right sections
ins_right({
  "fileformat",
  -- fmt = string.upper,
  icons_enabled = true,
  color = { fg = colors.yellow, gui = "bold" },
})

ins_right({
  "o:encoding", -- option component same as &encoding in viml
  fmt = string.upper, -- I'm not sure why it's upper case either ;)
  cond = conditions.hide_in_width,
  color = { fg = colors.yellow, gui = "bold" },
})

ins_right({ "location", icon = " ", color = { fg = colors.green, gui = "bold" } })

ins_right({ "progress", color = { fg = colors.green, gui = "bold" } })

ins_right({
  function()
    return '▊'
  end,
  color = function()
    -- auto change color according to neovims mode
    return { fg = mode_color[vim.fn.mode()] }
  end,
  padding = { left = 0, right = 0 },
})
-- Now don't forget to initialize lualine
lualine.setup(config)

local wk = require("which-key")
wk.setup({
  present = "modern",
  triggers = {
    { "<auto>", mode = "nixsoc" },
    -- { "<leader>", mode = {"n","v","t"}},
  },
  delay = function(ctx)
    return ctx.plugin and 0 or 150
  end,
  defer = function(ctx)
    return ctx.mode == "V" or ctx.mode == "<C-V>" or ctx.mode == "v"
  end,
  debug = false,
})

require("satellite").setup({
  excluded_filetypes = { "toggleterm", "NvimTree", "oil" },
})
