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

local function copy_commit(picker, item)
  picker:close()
  if item.commit then
    vim.fn.setreg("+", item.commit)
    vim.notify("Copied commit hash: " .. item.commit)
    local cmd = "CodeDiff " .. item.commit
    vim.cmd(cmd)
  end
end

vim.keymap.set({ "n", "t" }, "<leader>hl", function()
  Snacks.picker.git_log_file({
    confirm = copy_commit,
  })
end, { desc = "find_git_log_file" })

vim.keymap.set({ "n", "t" }, "<leader>hL", function()
  Snacks.picker.git_log({
    confirm = copy_commit,
  })
end, { desc = "find_git_log" })

local function git_pickaxe(opts)
  opts = opts or {}
  local is_global = opts.global or false
  local current_file = vim.api.nvim_buf_get_name(0)

  -- Force global if current buffer is invalid
  if not is_global and (current_file == "" or current_file == nil) then
    vim.notify("Buffer is not a file, switching to global search", vim.log.levels.WARN)
    is_global = true
  end

  local title_scope = is_global and "Global" or vim.fn.fnamemodify(current_file, ":t")
  vim.ui.input({ prompt = "Git Search (-G) in " .. title_scope .. ": " }, function(query)
    if not query or query == "" then
      return
    end

    local args = {
      "log",
      "-G" .. query,
      "-i",
      "--pretty=format:%C(yellow)%h%Creset %s %C(green)(%cr)%Creset %C(blue)<%an>%Creset",
      "--abbrev-commit",
      "--date=short",
    }

    if not is_global then
      table.insert(args, "--")
      table.insert(args, current_file)
    end

    Snacks.picker({
      title = 'Git Log: "' .. query .. '" (' .. title_scope .. ")",
      finder = "proc",
      cmd = "git",
      args = args,

      transform = function(item)
        local clean_text = item.text:gsub("\27%[[0-9;]*m", "")
        local hash = clean_text:match("^%S+")
        if hash then
          item.commit = hash
          if not is_global then
            item.file = current_file
          end
        end
        return item
      end,

      preview = "git_show",
      confirm = copy_commit,
      format = "text",
    })
  end)
end

-- Keymaps
vim.keymap.set("n", "<leader>hs", function()
  git_pickaxe({ global = false })
end, { desc = "Git Search (Buffer)" })
vim.keymap.set("n", "<leader>hS", function()
  git_pickaxe({ global = true })
end, { desc = "Git Search (Global)" })

require("vscode-diff").setup({
  keymaps = {
    view = {
      quit = false,
      toggle_explorer = "<leader>e", -- Toggle explorer visibility (explorer mode only)
      next_hunk = "]v",
      prev_hunk = "[v",
    },
  },
})

vim.keymap.set("n", "<leader>v", function()
  local count = vim.v.count
  vim.g.prev_tab_nr = vim.api.nvim_get_current_tabpage()
  local cmd
  if count > 0 then
    cmd = "CodeDiff HEAD~" .. (count - 1)
  else
    cmd = "CodeDiff"
  end
  vim.notify(cmd, vim.log.levels.INFO)
  vim.cmd(cmd)
end, {
  noremap = true,
  silent = true,
  desc = "CodeDiff [HEAD~(count-1)]",
})

local function get_default_branch_name()
  local res = vim
    .system({ "git", "rev-parse", "--verify", "main" }, { capture_output = true })
    :wait()
  return res.code == 0 and "main" or "master"
end

vim.keymap.set("n", "<leader>hm", function()
  local cmd = "CodeDiff " .. get_default_branch_name()
  vim.notify(cmd, vim.log.levels.INFO)
  vim.cmd(cmd)
end, { desc = "Diff against local master" })

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

-- Helper function to safely get the current buffer's git root using Fugitive
local function get_fugitive_git_root()
  -- FugitiveWorkTree returns the root of the current repo
  -- It may throw an error if not in a git repo, so we wrap it
  local ok, root = pcall(vim.fn.FugitiveWorkTree)
  if ok and root and root ~= "" then
    return root
  end
  return nil
end

vim.api.nvim_create_user_command("GC", function()
  local git_root = get_fugitive_git_root()

  if not git_root then
    vim.notify("GC command: Could not find Git repository root. Aborting.", vim.log.levels.ERROR)
    return
  end

  -- Save state
  vim.g.fugitive_last_repo_root = git_root
  vim.g.fugitive_last_tabpage_nr = vim.api.nvim_get_current_tabpage()

  -- Open new tab with Git commit -v
  -- -v shows the diff inside the commit buffer
  vim.cmd("tab Git commit -v")
end, {
  bang = true,
  desc = "Save root, open new tab, and run Git commit -v",
})

vim.api.nvim_create_user_command("GP", function()
  -- Validation: Ensure we are still in the expected repo context
  local current_root = get_fugitive_git_root()
  local saved_root = vim.g.fugitive_last_repo_root

  if not saved_root then
    vim.notify("GP command: No saved Git root found. Run GC first?", vim.log.levels.ERROR)
    return
  end

  -- Warn if the user switched to a buffer in a different repo
  if current_root ~= saved_root then
    vim.notify(
      string.format(
        "GP Warning: Current buffer is in '%s', but GC was run in '%s'. Pushing anyway...",
        current_root or "nil",
        saved_root
      ),
      vim.log.levels.WARN
    )
    -- If you strictly need to push the SAVED root regardless of current buffer,
    -- you must use raw system command, bypassing Fugitive:
    -- vim.fn.system("git -C " .. vim.fn.fnameescape(saved_root) .. " push")
    -- return
  end

  -- Run async push using Fugitive
  -- We rely on the current buffer context, which is the standard Fugitive way.
  vim.cmd("Git! push")

  -- Clear saved root after successful push command initiation
  vim.g.fugitive_last_repo_root = nil
end, {
  desc = "Git push the current repository (context verified against GC)",
  bang = true,
})

vim.api.nvim_create_user_command("GH", function()
  if vim.bo.filetype ~= "gitcommit" then
    vim.notify("GH command: Not a gitcommit buffer. Aborting.", vim.log.levels.INFO)
    return
  end

  local original_tab_nr = vim.g.fugitive_last_tabpage_nr
  local saved_root = vim.g.fugitive_last_repo_root

  if not saved_root then
    vim.notify("GH command: No saved Git root. Did you run GC?", vim.log.levels.ERROR)
    return
  end

  -- 1. Close the commit buffer (Save & Quit or just Quit)
  local initial_bufnr = vim.api.nvim_get_current_buf()
  local initial_buftype = vim.api.nvim_get_option_value("buftype", { buf = initial_bufnr })
  local initial_modifiable = vim.api.nvim_get_option_value("modifiable", { buf = initial_bufnr })

  local can_write = (initial_modifiable and (initial_buftype == nil or initial_buftype == ""))
  local quit_cmd = can_write and "wq" or "q"

  pcall(vim.cmd, quit_cmd)

  -- 2. Close the tab (GC opened a new tab, so we close it to return to previous state)
  pcall(vim.cmd, "tabc")

  -- 3. Restore context and Push
  vim.schedule(function()
    -- Clear globals
    vim.g.fugitive_last_repo_root = nil
    vim.g.fugitive_last_tabpage_nr = nil

    -- Restore the original tab
    if original_tab_nr and vim.api.nvim_tabpage_is_valid(original_tab_nr) then
      pcall(vim.api.nvim_set_current_tabpage, original_tab_nr)
    end

    -- Verify context matches (Sanity check)
    local current_root = get_fugitive_git_root()
    if current_root ~= saved_root then
      vim.notify(
        "GH Warning: Restored tab is not in the expected repo. Pushing active buffer.",
        vim.log.levels.WARN
      )
    end

    -- Execute Push
    -- Since we restored the tab, we are back in the original buffer/repo.
    -- Fugitive will use this context.
    local ok_push, err_push = pcall(vim.cmd, "Git! push")

    if not ok_push then
      vim.notify("GH command: Error executing push: " .. tostring(err_push), vim.log.levels.ERROR)
    end
  end)
end, {
  desc = "Write/Quit, close tab then Git push",
  nargs = 0,
})
