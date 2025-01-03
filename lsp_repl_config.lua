-- Setup treesitter
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

-- REPL using iron
vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  group = vim.api.nvim_create_augroup("python-repl", { clear = true }),
  callback = function(args)
    local iron = require("iron.core")
    local view = require("iron.view")
    iron.setup({
      config = {
        scope = require("iron.scope").path_based,
        scratch_repl = true,
        repl_definition = {
          python = {
            format = require("iron.fts.common").bracketed_paste,
            command = { "ipython", "--no-autoindent" },
          },
        },
        repl_open_cmd = view.split.vertical.botright(function()
          return math.max(vim.o.columns * 0.35, 80)
        end),
      },
      keymaps = {},
      highlight = {
        italic = true,
      },
      ignore_blank_lines = false, -- ignore blank lines when sending visual select lines
    })
    -- TODO norm! gv after Iron start/restart
    vim.keymap.set({ "n", "v" }, [[<a-\>]], function()
      vim.cmd("IronRepl")
      vim.cmd("wincmd =")
    end, { buffer = args.buf, desc = "repl_toggle" })
    vim.keymap.set({ "n", "v" }, "<localleader>r", function()
      vim.cmd("IronRestart")
      vim.cmd("IronRepl")
      vim.cmd("wincmd =")
    end, { buffer = args.buf, desc = "repl_restart" })

    local send_magic_paste = function()
      vim.cmd("call SelectVisual()")
      vim.cmd("norm! y`>")
      vim.defer_fn(function()
        iron.send(nil, "%paste")
      end, 100)
      vim.cmd("norm! j")
    end
    local send_cr = function()
      iron.send(nil, string.char(13))
    end

    vim.keymap.set("t", [[<a-\>]], "<cmd>q<cr>", { desc = "repl_toggle" })
    vim.keymap.set("n", "<localleader><cr>", send_cr, { buffer = args.buf, desc = "repl_cr" })
    vim.keymap.set("n", "<C-CR>", send_cr, { buffer = args.buf, desc = "repl_cr" })
    if vim.fn.has("linux") == 1 then
      vim.keymap.set("n", "<S-CR>", function()
        vim.cmd("call SelectVisual()")
        iron.visual_send()
        vim.cmd("norm! j")
      end, { buffer = args.buf, desc = "repl_send_cell" })
    else
      vim.keymap.set(
        "n",
        "<S-CR>",
        send_magic_paste,
        { buffer = args.buf, desc = "repl_send_cell" }
      )
    end
    vim.keymap.set("n", "<localleader>y", function()
      vim.cmd("norm! yiwo")
      vim.cmd("norm! pA.to_clipboard()")
      vim.cmd("norm! V")
      iron.visual_send()
      vim.cmd("norm! dd")
    end, { buffer = args.buf, desc = "repl_df_to_clipboard" })
    vim.keymap.set("n", "<localleader>p", function()
      vim.cmd("norm! yiwoprint(")
      vim.cmd("norm! pA)")
      vim.cmd("norm! V")
      iron.visual_send()
      vim.cmd("norm! dd")
    end, { buffer = args.buf, desc = "repl_print" })
    vim.keymap.set("v", "<CR>", function()
      iron.visual_send()
      vim.cmd("norm! j")
    end, { buffer = args.buf, desc = "repl_v_send" })
    vim.keymap.set({ "n", "v" }, "<localleader>u", function()
      iron.send_until_cursor()
      vim.api.nvim_input("<ESC>") -- to escape from visual mode
    end, { buffer = args.buf, desc = "repl_send_until" })
    vim.keymap.set({ "n", "v" }, "<localleader>qq", function()
      iron.close_repl()
      iron.send(nil, string.char(13))
    end, { buffer = args.buf, desc = "repl_exit" })
    vim.keymap.set({ "n", "v" }, "<localleader>c", function()
      iron.send(nil, string.char(03))
    end, { buffer = args.buf, desc = "repl_interrupt" })
    vim.keymap.set({ "n", "v" }, "<a-del>", function()
      iron.send(nil, string.char(12))
    end, { buffer = args.buf, desc = "repl_clear" })
    vim.keymap.set(
      "n",
      "<localleader>]",
      "<cmd>IronFocus<cr>i",
      { buffer = args.buf, desc = "repl_focus" }
    )
    vim.keymap.set({ "n" }, "<localleader>t", function()
      vim.cmd("normal V")
      require("leap.treesitter").select()
      iron.visual_send()
      vim.cmd("norm! j")
    end, { buffer = args.buf, desc = "repl_send_tree" })
    -- sync black call
    vim.keymap.set("n", "<localleader>==", ":!black %<cr>")
  end,
})

-- in cmdline use :lua =XYZ to shorthand :lua print(XYZ)
vim.api.nvim_create_autocmd("FileType", {
  pattern = "lua",
  group = vim.api.nvim_create_augroup("lua-repl", { clear = true }),
  callback = function(args)
    vim.keymap.set(
      "n",
      "<localleader><localleader>f",
      "<cmd>source %<CR>",
      { buffer = args.buf, desc = "execute lua file" }
    )
    vim.keymap.set(
      "n",
      "<localleader>l",
      ":.lua<cr>",
      { buffer = args.buf, desc = "execute lua line" }
    )
    vim.keymap.set("v", "<CR>", ":lua<cr>", { buffer = args.buf, desc = "execute lua line" })
  end,
})
