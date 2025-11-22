-- Setup Autocomplete
local cmp = require("blink.cmp")
cmp.setup({
  keymap = {
    preset = "none",
    ["<C-e>"] = { "show", "show_documentation", "hide_documentation" },
    ["<Esc>"] = { "cancel", "fallback" },
    ["<C-f>"] = { "cancel", "fallback" },
    ["<CR>"] = { "accept", "fallback" },
    ["<C-u>"] = { "scroll_documentation_up", "fallback" },
    ["<C-d>"] = { "scroll_documentation_down", "fallback" },
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
        min_keyword_length = 2,
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
    return { timeout_ms = 500, lsp_format = "fallback" }
  end,
})

Snacks.toggle({
  name = "Format-on-Save",
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

local actions = require("diffview.actions")
require("diffview").setup({
  view = {
    merge_tool = {
      layout = "diff3_mixed",
      disable_diagnostics = true,
    },
  },
  keymaps = {
    disable_defaults = false, -- Disable the default keymaps
    file_panel = {
      {
        "n",
        "<leader>",
        actions.toggle_stage_entry,
        { desc = "Stage / unstage the selected entry" },
      },
      {
        "n",
        "a",
        actions.stage_all,
        { desc = "Stage all entries" },
      },
      ["s"] = false,
      ["S"] = false,
      ["-"] = false,
    },
  },
})

local mini_git = require("mini.git")
mini_git.setup()

vim.api.nvim_create_user_command("GC", function()
  local git_data = mini_git.get_buf_data(0)

  if not git_data or not git_data.root then
    vim.notify("GC command: Could not find Git repository root. Aborting.", vim.log.levels.ERROR)
    return
  end

  vim.g.minigit_last_repo_root = git_data.root
  vim.g.minigit_last_tabpage_nr = vim.api.nvim_get_current_tabpage()

  vim.cmd("Git diff --staged")
  vim.cmd("Git commit")
end, {
  bang = true,
  desc = "Run Git diff --staged, save root path, and Git commit",
})

vim.api.nvim_create_user_command("GP", function()
  local repo_root_path = vim.g.minigit_last_repo_root
  if not repo_root_path or repo_root_path == "" then
    vim.notify(
      "GP command: Could not find saved Git root path. Did you run GC first?",
      vim.log.levels.ERROR
    )
    return
  end

  vim.g.minigit_last_repo_root = nil
  local escaped_repo_root = vim.fn.fnameescape(repo_root_path)

  local push_cmd = string.format("Git! -C %s push", escaped_repo_root)
  local ok_push, err_push = pcall(vim.api.nvim_command, push_cmd)

  if not ok_push then
    vim.notify(
      "GP command: Error executing '" .. push_cmd .. "': " .. err_push,
      vim.log.levels.ERROR
    )
  end
end, {
  desc = "Git push the last repository captured by GC",
  bang = true,
})

vim.api.nvim_create_user_command("GH", function()
  local current_filetype = vim.api.nvim_get_option_value("filetype", { buf = 0 })
  if current_filetype ~= "gitcommit" then
    vim.notify("GH command: Not a gitcommit buffer. Aborting.", vim.log.levels.INFO)
    return
  end

  local repo_root_path = vim.g.minigit_last_repo_root
  local original_tab_nr = vim.g.minigit_last_tabpage_nr

  if not repo_root_path or repo_root_path == "" then
    vim.notify(
      "GH command: Could not find saved Git root path. Did you run GC?",
      vim.log.levels.ERROR
    )
    return
  end

  vim.g.minigit_last_repo_root = nil
  vim.g.minigit_last_tabpage_nr = nil
  local escaped_repo_root = vim.fn.fnameescape(repo_root_path)

  local initial_bufnr = vim.api.nvim_get_current_buf()
  local initial_buftype = vim.api.nvim_get_option_value("buftype", { buf = initial_bufnr })
  local initial_modifiable = vim.api.nvim_get_option_value("modifiable", { buf = initial_bufnr })
  local can_write_initial = (
    initial_modifiable and (initial_buftype == nil or initial_buftype == "")
  )
  local cmd_to_run = "q"
  if can_write_initial then
    cmd_to_run = "wq"
  end
  pcall(vim.api.nvim_command, cmd_to_run)
  pcall(vim.api.nvim_command, "tabc")

  vim.schedule(function()
    if original_tab_nr and vim.api.nvim_tabpage_is_valid(original_tab_nr) then
      pcall(vim.api.nvim_set_current_tabpage, original_tab_nr)
    end

    local push_cmd = string.format("Git! -C %s push", escaped_repo_root)
    local ok_push, err_push = pcall(vim.api.nvim_command, push_cmd)

    if not ok_push then
      vim.notify(
        "GH command: Error executing '" .. push_cmd .. "': " .. err_push,
        vim.log.levels.ERROR
      )
    end
  end)
end, {
  desc = "Write/Quit, close tab, check new tab & close if diffview, then Git push",
  nargs = 0,
})

require("mini.diff").setup({
  view = {
    style = "sign",
  },
  mappings = {
    goto_first = "[C",
    goto_prev = "[c",
    goto_next = "]c",
    goto_last = "]C",
  },
  options = {
    algorithm = "patience",
  },
})

vim.keymap.set(
  "n",
  "<leader>hv",
  "<cmd>DiffviewFileHistory %<CR>",
  { desc = "diffview: file_history" }
)

vim.keymap.set(
  "n",
  "<leader>hV",
  "<cmd>DiffviewFileHistory<CR>",
  { desc = "diffview: log_history" }
)

vim.keymap.set("n", "<leader>v", function()
  local count = vim.v.count
  if next(require("diffview.lib").views) == nil then
    vim.g.prev_tab_nr = vim.api.nvim_get_current_tabpage()
    if count > 0 then
      vim.cmd("DiffviewOpen HEAD~" .. count)
    else
      vim.cmd("DiffviewOpen")
    end
  else
    vim.cmd("DiffviewClose")
  end
end, {
  noremap = true,
  silent = true,
  desc = "Diffview Open [HEAD~count]",
})

local function get_default_branch_name()
  local res = vim
    .system({ "git", "rev-parse", "--verify", "main" }, { capture_output = true })
    :wait()
  return res.code == 0 and "main" or "master"
end

vim.keymap.set("n", "<leader>hm", function()
  vim.cmd("DiffviewOpen " .. get_default_branch_name())
end, { desc = "Diff against local master" })

vim.keymap.set("n", "<leader>hM", function()
  vim.cmd("DiffviewOpen HEAD..origin/" .. get_default_branch_name())
end, { desc = "Diff against (remote) origin/master" })

vim.keymap.set("n", "<leader>hy", function()
  return require("mini.diff").operator("yank") .. "gh"
end, { expr = true, remap = true, desc = "Yank hunk Reference" })

vim.keymap.set(
  "n",
  "<leader>hh",
  "<cmd>lua MiniDiff.toggle_overlay()<CR>",
  { desc = "toggle hunk overlay" }
)

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

vim.keymap.set("n", "J", function()
  local current_tab = vim.api.nvim_get_current_tabpage()
  pcall(vim.api.nvim_command, "tabp")
  vim.g.prev_tab_nr = current_tab
end, { noremap = true, silent = true, desc = "Go to previous tab" })

vim.keymap.set("n", "K", function()
  local current_tab = vim.api.nvim_get_current_tabpage()
  pcall(vim.api.nvim_command, "tabn")
  vim.g.prev_tab_nr = current_tab
end, { noremap = true, silent = true, desc = "Go to next tab" })

vim.keymap.set("n", "T", function()
  local current_tab = vim.api.nvim_get_current_tabpage()
  pcall(vim.api.nvim_command, "tabnew")
  vim.g.prev_tab_nr = current_tab
end, { noremap = true, silent = true, desc = "Create new tab" })

vim.keymap.set("n", "<Del>", function()
  pcall(vim.api.nvim_command, "tabc")
  local prev_tab = vim.g.prev_tab_nr
  if prev_tab then
    vim.g.prev_tab_nr = nil
    if vim.api.nvim_tabpage_is_valid(prev_tab) then
      pcall(vim.api.nvim_set_current_tabpage, prev_tab)
    end
  end
end, {
  noremap = true,
  silent = true,
  desc = "Close tab and return to Diffview opener",
})
