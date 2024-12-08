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
require("nvim-autopairs").setup({
  disable_filetype = { "TelescopePrompt", "NvimTree", "oil", "minifiles" },
})
local cmp_autopairs = require("nvim-autopairs.completion.cmp")
cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())

-- Setup LSP
local lsp = require("lspconfig")
local navic = require("nvim-navic")

local custom_attach = function(client, bufnr)
  -- vim.keymap.set("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>")
  -- vim.keymap.set("n", "gD", ":vsplit | lua vim.lsp.buf.definition()<CR>")
  -- vim.keymap.set("n", "gD", function()
  --   vim.cmd("vsplit")
  --   require("telescope.builtin").lsp_definitions({ reuse_win = true })
  -- end, { desc = "V_lsp_definition" })
  -- vim.keymap.set('n','gr','<cmd>lua vim.lsp.buf.references()<CR>')
  -- vim.keymap.set(
  --   "n",
  --   "gR",
  --   require("telescope.builtin").lsp_references,
  --   { desc = "lsp_references" }
  -- )
  vim.keymap.set("n", "gh", "<cmd>lua vim.lsp.buf.hover()<CR>")
  vim.keymap.set("n", "gD", "<cmd>lua vim.lsp.buf.definition()<CR>")
  vim.keymap.set("n", "gd", "<CMD>Glance definitions<CR>")
  vim.keymap.set("n", "gR", "<cmd>lua vim.lsp.buf.references()<CR>")
  vim.keymap.set("n", "gr", "<CMD>Glance references<CR>")
  vim.keymap.set("n", "<F2>", "<cmd>lua vim.lsp.buf.rename()<CR>")
  vim.keymap.set("n", "gl", "<cmd>lua vim.diagnostic.open_float()<CR>")
  -- ]d and [d goto next and prev diagnostic
  vim.keymap.set("n", "]D", "<cmd>lua vim.diagnostic.goto_next({severity='error'})<CR>")
  vim.keymap.set("n", "[D", "<cmd>lua vim.diagnostic.goto_prev({severity='error'})<CR>")
  navic.attach(client, bufnr)
  -- end
end

-- Lua configuration
local glance = require("glance")
local actions = glance.actions

glance.setup({
  height = 25, -- Height of the window
  zindex = 45,

  border = {
    enable = true, -- Show window borders. Only horizontal borders allowed
    top_char = "─",
    bottom_char = "─",
  },

  mappings = {
    list = {
      ["j"] = actions.next, -- Bring the cursor to the next item in the list
      ["k"] = actions.previous, -- Bring the cursor to the previous item in the list
      ["<Tab>"] = actions.next_location, -- Bring the cursor to the next location skipping groups in the list
      ["<S-Tab>"] = actions.previous_location, -- Bring the cursor to the previous location skipping groups in the list
      ["<C-u>"] = actions.preview_scroll_win(5),
      ["<C-d>"] = actions.preview_scroll_win(-5),
      ["v"] = actions.jump_vsplit,
      ["s"] = actions.jump_split,
      ["t"] = actions.jump_tab,
      ["<CR>"] = actions.jump,
      ["o"] = actions.jump,
      ["l"] = actions.open_fold,
      ["h"] = actions.close_fold,
      ["<a-h>"] = actions.enter_win("preview"), -- Focus preview window
      ["q"] = actions.close,
      ["Q"] = actions.close,
      ["<Esc>"] = actions.close,
      ["<C-q>"] = actions.quickfix,
      -- ['<Esc>'] = false -- disable a mapping
    },
    preview = {
      ["q"] = actions.close,
      ["Q"] = actions.close,
      ["<Esc>"] = actions.close,
      ["<Tab>"] = actions.next_location,
      ["<S-Tab>"] = actions.previous_location,
      ["<a-l>"] = actions.enter_win("list"), -- Focus list window
    },
  },
})

lsp.basedpyright.setup({
  on_attach = custom_attach,
  capabilities = capabilities,
  settings = {
    basedpyright = {
      analysis = {
        useLibraryCodeForTypes = true,
        diagnosticMode = "openFilesOnly",
        typeCheckingMode = "basic",
        diagnosticSeverityOverrides = {
          reportAbstractUsage = "information",
          reportUnusedVariable = "information",
          reportUnusedFunction = "information",
          reportDuplicateImport = "warning",
          reportAttributeAccessIssue = "none",
          reportOptionalSubscript = "none",
          reportOptionalMemberAccess = "none",
          reportArgumentType = "none",
          reportAssignmentType = "information",
          reportPossiblyUnboundVariable = "information",
          reportIndexIssue = "none",
          reportCallIssue = "information",
          reportRedeclaration = "information",
          reportOperatorIssue = "information",
          reportOptionalOperand = "information",
          reportGeneralTypeIssues = "none",
        },
      },
    },
  },
})

vim.diagnostic.config({
  virtual_text = false,
  signs = true,
  float = {
    border = "single",
    format = function(diagnostic)
      return string.format(
        "%s (%s) [%s]",
        diagnostic.message,
        diagnostic.source,
        diagnostic.code or diagnostic.user_data.lsp.code
      )
    end,
  },
})
