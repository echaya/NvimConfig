Snacks = require("snacks")
vim.keymap.set("n", "<leader><leader>", function()
  Snacks.picker.smart()
end, { desc = "smart_open" })
vim.keymap.set("n", "<leader>ff", function()
  Snacks.picker.files()
end, { desc = "find_file" })
vim.keymap.set("n", "<leader>fr", function()
  Snacks.picker.recent()
end, { desc = "find_recent" })
vim.keymap.set("n", "<leader>bb", function()
  Snacks.picker.buffers()
end, { desc = "find_buffers" })
vim.keymap.set("n", "<leader>bd", function()
  Snacks.bufdelete()
end, { desc = "Delete Buffer" })
vim.keymap.set("n", "<leader>E", function()
  Snacks.picker.explorer()
  vim.defer_fn(function()
    vim.cmd("wincmd =")
  end, 100)
end, { desc = "snacks_explorer" })

vim.keymap.set({ "n" }, "<leader>fs", function()
  Snacks.picker.lsp_symbols({
    filter = {
      lua = {
        "Class",
        "Function",
        "Module",
      },
      python = {
        "Class",
        "Function",
        "Constant",
      },
    },
  })
end, { desc = "Find Symbols" })
vim.keymap.set({ "n" }, "<leader>fS", function()
  Snacks.picker.lsp_symbols({
    filter = {
      lua = {
        "Class",
        "Constructor",
        "Enum",
        "Field",
        "Function",
        "Interface",
        "Method",
        "Module",
        "Namespace",
        -- "Package" is commented out, as the docs note luals uses it for control flow
        "Property",
        "Struct",
        "Trait",
        "Variable", -- Include module-level variables
      },
      python = {
        "Class",
        "Constructor", -- Catches __init__
        "Method",
        "Function",
        "Module", -- Catches file-level scope
        "Variable", -- Shows module/class-level variables
        "Constant",
        "Field", -- Shows class attributes
        "Property",
        "Enum",
      },
    },
  })
end, { desc = "Find More Symbols" })

vim.keymap.set("n", "<leader>fh", function()
  Snacks.picker.help()
end, { desc = "find_help" })
vim.keymap.set("n", "<leader>fc", function()
  Snacks.picker.colorschemes()
end, { desc = "find_colorscheme" })
vim.keymap.set("n", "<leader>fp", function()
  Snacks.picker.files({ cwd = vim.fs.joinpath(vim.fn.stdpath("data"), "site") })
end, { desc = "find_plugin_files" })
vim.keymap.set("n", "<leader>pp", function()
  Snacks.picker.pickers()
end, { desc = "find_plugin" })
vim.keymap.set("n", "<leader>fk", function()
  Snacks.picker.keymaps()
end, { desc = "find_keymaps" })
vim.keymap.set("n", "<leader>fz", function()
  Snacks.picker.zoxide()
end, { desc = "find_zoxide" })
vim.keymap.set("n", "<leader>T", function()
  vim.cmd("tabnew")
  vim.defer_fn(Snacks.picker.zoxide, 200)
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
Snacks.toggle.inlay_hints():map("|H")
Snacks.toggle.animate():map("|a")
Snacks.toggle.diagnostics():map("|d")
Snacks.toggle({
  name = "TableMode",
  notify = false,
  get = function()
    return vim.b.table_mode_enabled or false
  end,
  set = function(state)
    local current_state = vim.b.table_mode_enabled or false
    if state ~= current_state then
      vim.cmd("TableModeToggle")
      vim.b.table_mode_enabled = state
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

Snacks.toggle({
  name = "TSContext",
  get = function()
    if vim.b.ts_context_enabled == nil then
      vim.b.ts_context_enabled = true
    end
    return vim.b.ts_context_enabled
  end,
  set = function(state)
    if state then
      vim.cmd("TSContext enable")
    else
      vim.cmd("TSContext disable")
    end
    vim.b.ts_context_enabled = state
  end,
}):map("|T")

vim.keymap.set("n", "<leader>un", function()
  Snacks.notifier.hide()
end, { desc = "Dismiss All Notifications" })
vim.keymap.set("n", "<leader>n", function()
  Snacks.notifier.show_history()
end, { desc = "notification_history" })

vim.keymap.set("n", "<leader>m", "<cmd>messages<cr>", { desc = "find_messages" })

vim.keymap.set("n", "<leader>gb", function()
  Snacks.gitbrowse()
end, { desc = "Git Browse" })

vim.keymap.set({ "n", "t" }, "<a-.>", function()
  Snacks.lazygit()
end, { desc = "Lazygit" })

vim.keymap.set({ "n", "t" }, "<a-`>", function()
  Snacks.terminal()
end, { desc = "Toggle terminal" })

vim.keymap.set({ "n" }, "<leader>y", function()
  Snacks.terminal("yazi;exit", {
    win = {
      style = "lazygit",
    },
  })
end, { desc = "yazi" })

vim.keymap.set({ "n" }, "<leader>.", function()
  Snacks.scratch()
end, { desc = "Toggle Scratch Buffer" })

vim.keymap.set({ "n" }, "<leader>f.", function()
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
  explorer = { enabled = true },
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
      input = {
        keys = {
          ["<C-/>"] = { "toggle_help", mode = { "n", "i" } },
          ["<Esc>"] = { "close", mode = { "n", "i" } },
          ["<c-c>"] = { "close", mode = { "n", "i" } },
          ["<Up>"] = { "history_back", mode = { "i", "n" } },
          ["<Down>"] = { "history_forward", mode = { "i", "n" } },
          ["<c-u>"] = { "preview_scroll_up", mode = { "i", "n" } },
          ["<c-d>"] = { "preview_scroll_down", mode = { "i", "n" } },
          ["<c-b>"] = { "list_scroll_up", mode = { "i", "n" } },
          ["<c-f>"] = { "list_scroll_down", mode = { "i", "n" } },
          ["<c-l>"] = { "focus_preview", mode = { "i", "n" } },
          ["<a-l>"] = { "toggle_focus", mode = { "i", "n" } },
          ["<Del>"] = { "bufdelete", mode = { "n", "i" } },
          ["/"] = false,
          ["<c-n>"] = false,
          ["<a-p>"] = false,
          ["<c-p>"] = { "toggle_preview", mode = { "i", "n" } },
        },
      },
      list = {
        keys = {
          ["<c-b>"] = "list_scroll_up",
          ["<c-f>"] = "list_scroll_down",
          ["<c-d>"] = "preview_scroll_down",
          ["<c-u>"] = "preview_scroll_up",
          ["<Esc>"] = "close",
          ["v"] = "edit_vsplit",
          ["s"] = "edit_split",
          ["q"] = "close",
          ["<c-c>"] = "close",
          ["<Down>"] = false,
          ["<Up>"] = false,
          ["/"] = false,
          ["<c-l>"] = "focus_preview",
          ["<a-l>"] = { "toggle_focus" },
          ["<c-n>"] = false,
          ["<a-p>"] = false,
          ["<c-p>"] = { "toggle_preview", mode = { "i", "n" } },
        },
      },
      preview = {
        keys = {
          ["<Esc>"] = "close",
          ["q"] = "close",
          ["<c-c>"] = "close",
          ["<c-h>"] = "focus_list",
        },
      },
    },
    db = {
      sqlite3_path = "c:/tools/CliTools/sqlite3.dll",
    },
    sources = {
      zoxide = {
        confirm = { "tcd", "picker_files", "close" },
      },
      lsp_definitions = {
        focus = "list",
        auto_confirm = false,
      },
      lsp_references = {
        focus = "list",
        auto_confirm = false,
      },
      explorer = {
        win = {
          input = {
            keys = {
              ["<c-l>"] = false,
              ["<esc>"] = { "", mode = "n" },
            },
          },
          list = {
            keys = {
              ["<c-l>"] = false,
              ["<esc>"] = { "", mode = "n" },
            },
          },
        },
      },
    },
  },
})

local colorscheme_A = "tokyonight-night"
local colorscheme_B = "kanagawa"
Snacks.toggle({
  name = "",
  notify = false,
  get = function()
    return vim.g.colors_name == colorscheme_A
  end,
  set = function(state)
    local new_scheme = state and colorscheme_A or colorscheme_B
    vim.cmd("colorscheme " .. new_scheme)
  end,
  wk_desc = {
    enabled = "Switch to " .. colorscheme_B,
    disabled = "Switch to " .. colorscheme_A,
  },
}):map("|b")

-- vim.highlight.priorities.semantic_tokens = 95 -- Or any number lower than 100, treesitter's priority level
require("kanagawa").setup({
  compile = true,
  keywordStyle = { italic = false },
  dimInactive = true,
  colors = {
    theme = {
      all = { ui = { bg_gutter = "" } },
    },
  },
  overrides = function(colors)
    return {
      -- Assign a static color to strings
      BlinkCmpMenu = { bg = colors.palette.dragonBlack3 },
      BlinkCmpLabelDetail = { bg = colors.palette.dragonBlack3 },
      BlinkCmpMenuSelection = { bg = colors.palette.waveBlue1 },

      NormalFloat = { bg = "none" },
      FloatBorder = { bg = "none" },
      FloatTitle = { bg = "none" },
      LineNr = { fg = colors.palette.dragonGray3 },
      MatchParen = { bg = colors.palette.sumiInk6, bold = true },
      FlashLabel = { fg = colors.palette.carpYellow, bg = colors.palette.sumiInk5, bold = true },
      TabLine = { fg = colors.palette.lotusViolet2 },
      ["@variable.builtin"] = { italic = false },
      ["@diff.minus"] = { bg = colors.palette.winterRed },
      ["@diff.plus"] = { bg = colors.palette.winterGreen },
      ["@diff.delta"] = { bg = colors.palette.winterYellow },
    }
  end,
})

require("tokyonight").setup({
  -- available options: moon, storm, night
  style = "night",
  dim_inactive = true, -- dims inactive windows
  styles = {
    keywords = { italic = false },
  },
  on_colors = function(colors)
    colors.git.add = colors.green
    colors.git.change = colors.blue
    colors.git.delete = colors.red
  end,
  on_highlights = function(hl, colors)
    local commentColor = colors.comment
    hl.LineNrAbove = {
      fg = commentColor,
    }
    hl.LineNrBelow = {
      fg = commentColor,
    }
    hl.MatchParen = { bg = "#505664", underline = true }
    hl.LineNr = {
      fg = commentColor,
    }
    hl.TabLine = { fg = commentColor }
    hl.TabLineSel = { bg = colors.bg_visual }
  end,
})
