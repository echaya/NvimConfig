Snacks = require("snacks")
vim.keymap.set("n", "<leader><leader>", function()
  Snacks.picker.smart()
end, { desc = "smart open" })
vim.keymap.set("n", "<leader>ff", function()
  Snacks.picker.files()
end, { desc = "find file" })
vim.keymap.set("n", "<leader>fr", function()
  Snacks.picker.recent()
end, { desc = "find recent" })
vim.keymap.set("n", "<leader>bb", function()
  Snacks.picker.buffers()
end, { desc = "find buffers" })
vim.keymap.set("n", "<leader>bd", function()
  Snacks.bufdelete()
end, { desc = "delete buffer" })
vim.keymap.set("n", "<leader>E", function()
  Snacks.picker.explorer()
  vim.defer_fn(function()
    vim.cmd("wincmd =")
  end, 100)
end, { desc = "snacks explorer" })

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
end, { desc = "find symbols" })
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
end, { desc = "find more symbols" })

vim.keymap.set("n", "<leader>fh", function()
  Snacks.picker.help()
end, { desc = "find help" })
vim.keymap.set("n", "<leader>fc", function()
  Snacks.picker.colorschemes()
end, { desc = "find colorscheme" })
vim.keymap.set("n", "<leader>fP", function()
  Snacks.picker.files({ cwd = vim.fs.joinpath(vim.fn.stdpath("data"), "site") })
end, { desc = "find plugin files" })
vim.keymap.set("n", "<leader>fp", function()
  Snacks.picker.pickers()
end, { desc = "find picker" })
vim.keymap.set("n", "<leader>fk", function()
  Snacks.picker.keymaps()
end, { desc = "find keymaps" })
vim.keymap.set("n", "<leader>fz", function()
  Snacks.picker.zoxide()
end, { desc = "find zoxide" })
vim.keymap.set("n", "<leader>T", function()
  vim.cmd("tabnew")
  vim.defer_fn(Snacks.picker.zoxide, 200)
end, { desc = "zoxide in new tab" })
vim.keymap.set("n", "<leader>fd", function()
  Snacks.picker.diagnostics()
end, { desc = "lsp diagnostics" })
vim.keymap.set("n", "<leader>fu", function()
  Snacks.picker.undo()
end, { desc = "find undo" })
vim.keymap.set("n", '<leader>"', function()
  Snacks.picker.registers()
end, { desc = "registers" })
vim.keymap.set("n", "<leader>`", function()
  Snacks.picker.marks()
end, { desc = "marks" })
vim.keymap.set("n", "<leader>/", function()
  Snacks.picker.grep()
end, { desc = "live grep" })
vim.keymap.set("n", "<leader>fw", function()
  Snacks.picker.grep_word()
end, { desc = "grep (find) word" })

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
end, { desc = "dismiss all notifications" })
vim.keymap.set("n", "<leader>n", function()
  Snacks.notifier.show_history()
end, { desc = "notification history" })

vim.keymap.set("n", "<leader>m", "<cmd>messages<cr>", { desc = "message history" })

vim.keymap.set("n", "<leader>hb", function()
  Snacks.gitbrowse()
end, { desc = "git browse" })

vim.keymap.set({ "n", "t" }, "<a-.>", function()
  Snacks.lazygit()
end, { desc = "lazygit" })

vim.keymap.set({ "n", "t" }, "<a-`>", function()
  Snacks.terminal()
end, { desc = "toggle terminal" })

vim.keymap.set({ "n" }, "<leader>y", function()
  Snacks.terminal("yazi;exit", {
    win = {
      style = "lazygit",
    },
  })
end, { desc = "yazi" })

vim.keymap.set({ "n" }, "<leader>.", function()
  Snacks.scratch()
end, { desc = "toggle scratch buffer" })

vim.keymap.set({ "n" }, "<leader>f.", function()
  Snacks.scratch.select()
end, { desc = "find scratch" })

vim.keymap.set("n", "<leader>z", function()
  Snacks.zen()
end, { desc = "toggle zen mode" })
vim.keymap.set("n", "<leader>Z", function()
  Snacks.zen.zoom()
end, { desc = "toggle zoom" })

vim.opt.shortmess:append("WcCS")
vim.opt.wildmenu = true
vim.opt.wildmode = "longest:full,full"
vim.opt.wildoptions = "pum"
vim.opt.showmode = false

Snacks.setup({
  bigfile = { enabled = true },
  notifier = {
    enabled = true,
    timeout = 3000,
    style = "compact", -- Options: "compact", "minimal", "fancy"
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

vim.api.nvim_create_user_command("GithubSync", function()
  vim.cmd('lua Snacks.terminal("cd d:/Workspace/SiteRepo/; ./UpdateSite.bat; exit")')
end, {
  desc = "Sync Site Repo to Github via snacks.terminal() call",
  nargs = 0,
})

local colorscheme_A = "tokyonight-night"
local colorscheme_B = "kanagawa"
Snacks.toggle({
  name = "Colorscheme",
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
