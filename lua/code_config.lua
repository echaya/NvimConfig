-- Setup Autocomplete
local cmp = require("blink.cmp")
cmp.setup({
  keymap = {
    preset = "none",
    ["<C-e>"] = { "show", "show_documentation", "hide_documentation" },
    ["<Esc>"] = { "cancel", "fallback" },
    ["<C-f>"] = { "cancel", "fallback" },
    ["<CR>"] = { "accept", "fallback" },
    ["<Up>"] = { "scroll_documentation_up", "fallback" },
    ["<Down>"] = { "scroll_documentation_down", "fallback" },
    ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
    ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
  },

  appearance = {
    use_nvim_cmp_as_default = false,
    nerd_font_variant = "mono",
  },
  fuzzy = {
    prebuilt_binaries = { download = true },
    implementation = "rust",
  },
  completion = {
    list = { selection = { preselect = true, auto_insert = true } },
    documentation = {
      auto_show = true,
      auto_show_delay_ms = 250,
    },
  },
  sources = {
    default = { "lsp", "path", "snippets", "buffer" },
    providers = {
      lsp = {
        min_keyword_length = 1, -- Number of characters to trigger porvider
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
        min_keyword_length = 0,
        max_items = 5,
      },
    },
  },
  cmdline = {
    keymap = {
      preset = "none",
      ["<C-e>"] = { "show", "show_documentation", "hide_documentation" },
      ["<Esc>"] = { "cancel", "fallback" },
      ["<C-f>"] = { "cancel", "fallback" },
      ["<CR>"] = { "accept_and_enter", "fallback" },
      ["<Tab>"] = { "select_next", "fallback" },
      ["<S-Tab>"] = { "select_prev", "fallback" },
    },
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
    completion = {
      menu = { auto_show = true },
      list = { selection = { preselect = false, auto_insert = true } },
    },
  },
  term = {
    enabled = true,
    keymap = { preset = "inherit" }, -- Inherits from top level `keymap` config when not set
    sources = { "buffer" },
    completion = {
      list = { selection = { preselect = true, auto_insert = true } },
      menu = { auto_show = false },
      ghost_text = { enabled = false },
    },
  },
})

require("mini.pairs").setup({
  mappings = {
    -- Opening brackets: Auto-pair if character after is not a letter or digit
    ["("] = { neigh_pattern = "[^\\][^%a%d]" },
    ["["] = { neigh_pattern = "[^\\][^%a%d]" },
    ["{"] = { neigh_pattern = "[^\\][^%a%d]" },
    -- Opening double quotation: Auto-pair if character after is not a letter or digit
    ['"'] = { neigh_pattern = "[^\\][^%a%d]" },
    -- Quotes: Auto-close if character before AND after is not a letter or digit
    ["'"] = { neigh_pattern = "[^%a%d][^%a%d]" },
    ["`"] = { neigh_pattern = "[^%a%d][^%a%d]" },
  },
})

require("conform").setup({
  formatters_by_ft = {
    lua = { "stylua" },
    python = { "isort", "ruff_format" },
  },
  format_on_save = function()
    if vim.g.disable_autoformat then
      return
    end
    return { timeout_ms = 2000, lsp_format = "fallback" }
  end,
})

Snacks.toggle({
  name = "Format on Save",
  get = function()
    return not (vim.g.disable_autoformat or false)
  end,
  set = function(state)
    if state == true then
      vim.g.disable_autoformat = false
      local conform_ok, conform = pcall(require, "conform")
      if conform_ok then
        conform.format({
          timeout_ms = 500,
          lsp_format = "fallback",
          async = true,
        })
      else
        vim.notify("conform plugin not found", vim.log.levels.ERROR)
      end
    else
      vim.g.disable_autoformat = true
    end
  end,
}):map("|f")

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
      vim.keymap.set("n", "==", "ggVG=", { buffer = args.buf, desc = "vim_format" })
    else
      vim.keymap.set("n", "==", "<cmd>Format<cr>", { buffer = args.buf, desc = "conform_format" })
    end
  end,
})

local hi_words = require("mini.extra").gen_highlighter.words
local hipatterns = require("mini.hipatterns")
hipatterns.setup({
  highlighters = {
    hack = hi_words({ "IMP", "Hack" }, "MiniHipatternsHack"),
    fixme = hi_words({ "XXX", "FIXME" }, "MiniHipatternsFixme"),
    todo = hi_words({ "TODO", "Todo" }, "MiniHipatternsTodo"),
    note = hi_words({ "NOTE", "Note" }, "MiniHipatternsNote"),
    -- Highlight hex color strings (`#rrggbb`) using that color
    hex_color = hipatterns.gen_highlighter.hex_color(),
  },
})

require("render-markdown").setup({
  file_types = { "markdown" },
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

local toggle_qf = function()
  local qf_exists = false
  for _, win in pairs(vim.fn.getwininfo()) do
    if win["quickfix"] == 1 then
      qf_exists = true
    end
  end
  if qf_exists == true then
    vim.cmd("cclose")
    return
  end
  if not vim.tbl_isempty(vim.fn.getqflist()) then
    vim.cmd("copen")
  end
end
vim.keymap.set("n", "<localleader>qf", toggle_qf, { desc = "Toggle quickfix" })

require("neowiki").setup({
  wiki_dirs = {
    { name = "wiki", path = vim.g.MDir },
  },
  discover_nested_roots = true,
  keymaps = {
    toggle_task = "<leader>tt",
    rename_page = "<f2>",
  },
  todo = {
    show_todo_progress = true,
    todo_progress_hl_group = "DiffText",
  },
  floating_wiki = {
    style = { winblend = 0 },
  },
})

vim.keymap.set("n", "<leader>wW", require("neowiki").open_wiki, { desc = "open wiki" })
vim.keymap.set(
  "n",
  "<leader>ww",
  require("neowiki").open_wiki_floating,
  { desc = "open wiki floating" }
)
vim.keymap.set(
  "n",
  "<leader>wt",
  require("neowiki").open_wiki_new_tab,
  { desc = "open wiki in new tab" }
)

vim.api.nvim_create_autocmd("TabLeave", {
  callback = function()
    local current_tab = vim.api.nvim_get_current_tabpage()
    vim.g.last_active_tab = current_tab
  end,
})

vim.keymap.set("n", "J", "<cmd>tabp<cr>", { noremap = true, silent = true, desc = "Previous Tab" })
vim.keymap.set("n", "K", "<cmd>tabn<cr>", { noremap = true, silent = true, desc = "Next Tab" })
vim.keymap.set("n", "T", "<cmd>tabnew<cr>", { noremap = true, silent = true, desc = "New Tab" })

vim.keymap.set("n", "<Del>", function()
  local target_tab = vim.g.last_active_tab
  local current_tab = vim.api.nvim_get_current_tabpage()

  pcall(vim.api.nvim_command, "tabc")

  if target_tab and target_tab ~= current_tab and vim.api.nvim_tabpage_is_valid(target_tab) then
    pcall(vim.api.nvim_set_current_tabpage, target_tab)
  end
end, { noremap = true, silent = true, desc = "Close and return to last used" })
