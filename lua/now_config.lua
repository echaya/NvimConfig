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
vim.keymap.set("n", "<localleader>e", function()
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
  vim.defer_fn(Snacks.picker.zoxide, 100)
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
          ["/"] = false,
          ["<c-n>"] = false,
          ["<c-p>"] = false,
          ["<c-l>"] = { "focus_preview", mode = { "i", "n" } },
          ["<a-l>"] = { "toggle_focus", mode = { "i", "n" } },
          ["<Del>"] = { "bufdelete", mode = { "n", "i" } },
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
          ["<c-n>"] = false,
          ["<c-p>"] = false,
          ["/"] = false,
          ["<c-l>"] = "focus_preview",
          ["<a-l>"] = { "toggle_focus" },
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
    },
  },
})

local colorscheme_A = "tokyonight-night"
local colorscheme_B = "kanagawa-paper"
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
local palette = require("kanagawa-paper.colors").palette
require("kanagawa-paper").setup({
  dim_inactive = true,
  cache = true,
  colors = {
    theme = {
      ink = { ui = { bg = palette.sumiInk0, bg_dim = palette.sumiInkn1 } },
    },
  },
  overrides = function(colors)
    return {
      NormalFloat = { bg = "none" },
      FloatBorder = { bg = "none" },
      FloatTitle = { bg = "none" },
      LineNr = { fg = colors.palette.dragonGray3 },
      MatchParen = { bg = colors.palette.sumiInk6, bold = true },
      FlashLabel = { fg = colors.palette.carpYellow, bg = colors.palette.sumiInk5, bold = true },
      TabLine = { fg = colors.palette.lotusViolet2 },
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

local function close_buffers_outside_context()
  local FORCE_DELETE = false
  local current_buf = vim.api.nvim_get_current_buf()

  -- 1. Optimized Normalization: Handles Symlinks & Windows Paths
  local function resolve_path(path)
    if not path or path == "" then
      return nil
    end
    -- Expand to absolute path first
    local expanded = vim.fn.fnamemodify(path, ":p")
    -- Try to resolve real path (handles Symlinks/Junctions)
    -- If fs_realpath fails (file doesn't exist on disk yet), fallback to expanded
    local real = vim.uv.fs_realpath(expanded) or expanded
    -- Windows Normalization: Lowercase & Standardize Slashes
    if vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1 then
      real = real:lower()
      real = real:gsub("\\", "/")
    end
    return real
  end
  -- 2. Detect Target Scope
  -- Try Fugitive -> Fallback to Current File Dir -> Fallback to CWD
  local target_dir = nil
  local status, git_dir = pcall(vim.fn.FugitiveWorkTree, current_buf)

  if status and git_dir and #git_dir > 0 then
    target_dir = git_dir
  else
    target_dir = vim.fn.expand("%:p:h")
    if target_dir == "" then
      target_dir = vim.fn.getcwd()
    end
  end

  -- Normalize Target
  target_dir = resolve_path(target_dir)
  -- Ensure trailing slash for directory matching
  if target_dir and target_dir:sub(-1) ~= "/" then
    target_dir = target_dir .. "/"
  else
    return
  end

  -- 3. Efficient Loop & Filter
  local buffers = vim.api.nvim_list_bufs()
  local closed_count = 0
  local kept_count = 0

  for _, buf_id in ipairs(buffers) do
    -- A. Skip Current Buffer (Integer check is fastest)
    if buf_id == current_buf then
      goto continue
    end

    -- B. Skip Unlisted Buffers (Boolean check)
    if not vim.api.nvim_get_option_value("buflisted", { buf = buf_id }) then
      goto continue
    end

    -- C. Skip Special Buftypes (String check)
    local buftype = vim.api.nvim_get_option_value("buftype", { buf = buf_id })
    if buftype ~= "" then
      goto continue
    end

    -- D. Get Name and Filter Protocols
    local buf_name = vim.api.nvim_buf_get_name(buf_id)
    if buf_name == "" then
      goto continue
    end
    -- Skip non-file protocols (e.g., fugitive://, term://) to avoid path errors
    if buf_name:match("^%w+://") then
      goto continue
    end

    -- E. Resolve Path (Most expensive step, done last)
    local buf_path = resolve_path(buf_name)

    -- F. Check Scope
    -- We check if the resolved buffer path starts with the resolved target directory
    if buf_path and not string.find(buf_path, "^" .. vim.pesc(target_dir)) then
      -- G. Delete Logic
      local is_modified = vim.api.nvim_get_option_value("modified", { buf = buf_id })

      if is_modified and not FORCE_DELETE then
        kept_count = kept_count + 1
      else
        local success, err = pcall(vim.api.nvim_buf_delete, buf_id, { force = FORCE_DELETE })
        if success then
          closed_count = closed_count + 1
        else
          vim.notify("Failed to close " .. buf_name .. ": " .. tostring(err), vim.log.levels.ERROR)
        end
      end
    end

    ::continue::
  end

  -- 4. Minimalist Notification
  if closed_count > 0 then
    vim.notify(
      string.format("Scope: %s\nClosed: %d buffers", target_dir, closed_count),
      vim.log.levels.INFO
    )
  elseif kept_count > 0 then
    vim.notify(
      string.format("Scope: %s\nKept %d unsaved buffers", target_dir, kept_count),
      vim.log.levels.WARN
    )
  else
    vim.notify("Workspace clean.", vim.log.levels.INFO)
  end
end

vim.keymap.set("n", "<leader>bD", close_buffers_outside_context, {
  desc = "Close buffers not in current Git repo",
  silent = true,
})
