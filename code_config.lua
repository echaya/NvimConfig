-- Set up nvim-cmp.
local cmp = require("blink.cmp")
cmp.setup({
  keymap = {
    preset = "none",
    ["<C-e>"] = { "show", "show_documentation", "hide_documentation" },
    ["<Esc>"] = { "cancel", "fallback" },
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
    list = {
      selection = {
        preselect = function(ctx)
          return ctx.mode ~= "cmdline"
            and not require("blink.cmp").snippet_active({ direction = 1 })
        end,
      },
    },
    documentation = {
      auto_show = true,
      auto_show_delay_ms = 250,
    },
  },
  cmdline = {
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
    completion = { menu = { auto_show = true } },
  },
  sources = {
    default = { "lsp", "path", "snippets", "buffer" },
    providers = {
      lsp = {
        min_keyword_length = 0, -- Number of characters to trigger porvider
        score_offset = 0, -- Boost/penalize the score of the items
      },
      path = {
        min_keyword_length = 1,
      },
      snippets = {
        min_keyword_length = 2,
        score_offset = 5, -- Boost/penalize the score of the items
      },
      buffer = {
        min_keyword_length = 2,
        max_items = 5,
      },
    },
  },
})
-- Setup Autocomplete
require('mini.pairs').setup({
  mappings = {
    -- Opening brackets: Auto-pair if character after is not a letter
    ['('] = { action = 'open', pair = '()', neigh_pattern = '[^\\][^%a%d]' },
    ['['] = { action = 'open', pair = '[]', neigh_pattern = '[^\\][^%a%d]' },
    ['{'] = { action = 'open', pair = '{}', neigh_pattern = '[^\\][^%a%d]' },
    -- Closing brackets (unchanged, for skipping behavior)
    [')'] = { action = 'close', pair = '()', neigh_pattern = '[^\\].' },
    [']'] = { action = 'close', pair = '[]', neigh_pattern = '[^\\].' },
    ['}'] = { action = 'close', pair = '{}', neigh_pattern = '[^\\].' },
    -- Quotes: Auto-close if character before AND after is not a letter
    ['"'] = { action = 'closeopen', pair = '""', neigh_pattern = '[^%a%d][^%a%d]', register = { cr = false } },
    ["'"] = { action = 'closeopen', pair = "''", neigh_pattern = '[^%a%d][^%a%d]', register = { cr = false } },
    ['`'] = { action = 'closeopen', pair = '``', neigh_pattern = '[^%a%d][^%a%d]', register = { cr = false } },
  }
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
      vim.keymap.set("n", "==", "<cmd>Format<cr>", { desc = "conform_format" })
    end
  end,
})

local gitsigns = require("gitsigns")
gitsigns.setup({
  signs = {
    add = { text = "" }, -- dashed / double line for unstaged
    change = { text = "" },
    delete = { text = "=", show_count = true },
    topdelete = { text = "󰘣", show_count = true },
    changedelete = { text = "󰾞", show_count = true },
    untracked = { text = "󰇝" },
  },
  signs_staged = {
    add = { text = "┃" },
    change = { text = "┃" },
    delete = { text = "_", show_count = true },
    topdelete = { text = "‾", show_count = true },
    changedelete = { text = "~", show_count = true },
    untracked = { text = "┆" },
  },
  count_chars = { "₁", "₂", "₃", "₄", "₅", "₆", "₇", "₈", "₉", ["+"] = "+" },
  on_attach = function(bufnr)
    local function map(mode, l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end

    -- navigation
    map("n", "]c", function()
      if vim.wo.diff then
        vim.cmd.normal({ "]c", bang = true })
      else
        gitsigns.nav_hunk("next")
      end
    end, { desc = "next_hunk" })

    map("n", "[c", function()
      if vim.wo.diff then
        vim.cmd.normal({ "[c", bang = true })
      else
        gitsigns.nav_hunk("prev")
      end
    end, { desc = "prev_hunk" })

    map("n", "]C", function()
      gitsigns.nav_hunk("last")
    end, { desc = "Last Hunk" })
    map("n", "[C", function()
      gitsigns.nav_hunk("first")
    end, { desc = "First Hunk" })
    -- Actions
    map("n", "<leader>hs", gitsigns.stage_hunk, { desc = "hunk_stage" })
    map("n", "<leader>hr", gitsigns.reset_hunk, { desc = "hunk_reset" })
    map("n", "<leader>hu", gitsigns.undo_stage_hunk, { desc = "hunk_unstage" })
    map("v", "<leader>hs", function()
      gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
    end, { desc = "hunk_stage" })
    map("v", "<leader>hr", function()
      gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
    end, { desc = "hunk_reset" })
    map("v", "<leader>hu", function()
      gitsigns.undo_stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
    end, { desc = "hunk_unstage" })
    map({ "n", "v" }, "<leader>hh", gitsigns.preview_hunk, { desc = "hunk_hover" })
    map("n", "<leader>hd", "<cmd>DiffviewFileHistory %<CR>", { desc = "diffview: file_history" })
    map("v", "<leader>hd", ":'<,'>DiffviewFileHistory<CR>", { desc = "diffview: hunk_history" })
    map("n", "<leader>td", gitsigns.toggle_deleted, { desc = "gitsigns: toggle_deleted" })

    -- Text object
    map({ "o", "x" }, "gh", ":<C-U>Gitsigns select_hunk<CR>")
  end,
})

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
