-- Set up nvim-cmp.
local cmp = require("cmp")
local luasnip = require("luasnip")

cmp.setup({
  snippet = {
    expand = function(args)
      require("luasnip").lsp_expand(args.body) -- For `luasnip` users.
    end,
  },
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
  mapping = cmp.mapping.preset.insert({
    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<C-e>"] = cmp.mapping.abort(),
    ["<CR>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        if luasnip.expandable() then
          luasnip.expand()
        else
          cmp.confirm({
            select = true,
          })
        end
      else
        fallback()
      end
    end),

    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.locally_jumpable(1) then
        luasnip.jump(1)
      else
        fallback()
      end
    end, { "i", "s" }),

    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.locally_jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { "i", "s" }),
  }),

  sources = cmp.config.sources({
    { name = "async_path" },
  }, {
    { name = "luasnip" },
    { name = "nvim_lsp" },
  }, {
    { name = "buffer" },
  }),
  matching = {
    disallow_fuzzy_matching = true,
    disallow_fullfuzzy_matching = true,
    disallow_partial_fuzzy_matching = true,
    disallow_partial_matching = false,
    disallow_prefix_unmatching = true,
    disallow_symbol_nonprefix_matching = false,
  },
})

-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline({ "/", "?" }, {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = "buffer" },
  },
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(":", {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = "async_path" },
  }, {
    { name = "cmdline" },
  }),
})

-- Setup luasnip
require("luasnip.loaders.from_vscode").lazy_load()
require("luasnip").filetype_extend("vimwiki", { "markdown" })
luasnip.config.set_config({
  region_check_events = "InsertEnter",
  delete_check_events = "InsertLeave",
})

-- Setup Autocomplete
require('mini.pairs').setup()

require("conform").setup({
  formatters_by_ft = {
    lua = { "stylua" },
    python = { "isort", "black" },
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
      vim.keymap.set("n", "==", "ggVG=<C-o>", { buffer = args.buf, desc = "vim_format" })
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
    delete = { text = "_" },
    topdelete = { text = "‾" },
    changedelete = { text = "~" },
    untracked = { text = "󰇝" },
  },
  signs_staged = {
    add = { text = "┃" },
    change = { text = "┃" },
    delete = { text = "󱘹" },
    topdelete = { text = "󱘹" },
    changedelete = { text = "󰜥" },
    untracked = { text = "┆" },
  },
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
    map("n", "<leader>td", gitsigns.toggle_deleted, { desc = "gitsign: toggle_deleted" })

    -- Text object
    map({ "o", "x" }, "gh", ":<C-U>Gitsigns select_hunk<CR>")
  end,
})

require("diffview").setup({
  view = {
    merge_tool = {
      layout = "diff3_mixed",
    },
  },
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

require("nvim-treesitter.configs").setup({
  -- A list of parser names, or "all" (the listed parsers MUST always be installed)
  ensure_installed = {
    "lua",
    "markdown",
    "markdown_inline",
    "python",
    "query",
    "vim",
    "vimdoc",
    "bash",
  },
  sync_install = false,
  auto_install = false,
  ignore_install = { "javascript" },
  highlight = {
    enable = true,
    disable = function(lang, buf)
      local max_filesize = 100 * 1024 -- 100 KB
      local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
      if ok and stats and stats.size > max_filesize then
        return true
      end
    end,
    additional_vim_regex_highlighting = false,
  },
})
vim.treesitter.language.register("markdown", "vimwiki")

