vim.keymap.set("n", "<localleader>x", function()
  vim.cmd("!start " .. vim.fn.shellescape(vim.fn.expand("<cfile>"), true))
end, { noremap = true, silent = true, desc = "Open file under cursor in default program" })

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
      auto_show_delay_ms = 200,
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
    -- { name = "todo", path = "todo" }, --for neowiki development
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

vim.keymap.set(
  "n",
  "<leader>ww",
  require("neowiki").open_wiki_floating,
  { desc = "open wiki floating" }
)
vim.keymap.set(
  "n",
  "<leader>wW",
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

  vim.schedule(function()
    pcall(vim.api.nvim_command, "tabc")

    if target_tab and target_tab ~= current_tab and vim.api.nvim_tabpage_is_valid(target_tab) then
      pcall(vim.api.nvim_set_current_tabpage, target_tab)
    end
  end)
end, { noremap = true, silent = true, desc = "Close and return to last used" })

local Formatter = {}
local executable_cache = {}
local timeout_ms = 2000
local max_file_size = 10000
Formatter.formatters_by_ft = {
  lua = function(bufnr)
    local filename = vim.api.nvim_buf_get_name(bufnr)
    if filename == "" then
      filename = "unnamed.lua"
    end
    return {
      { "stylua", "--search-parent-directories", "--stdin-filepath", filename, "-" },
    }
  end,
  python = function(bufnr)
    local filename = vim.api.nvim_buf_get_name(bufnr)
    if filename == "" then
      filename = "unnamed.py"
    end
    return {
      { "isort", "--filename", filename, "-" },
      { "ruff", "format", "--stdin-filename", filename, "-" },
    }
  end,
}

local function apply_text(bufnr, initial_tick, text)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end
  if vim.b[bufnr].changedtick ~= initial_tick then
    vim.notify("Buffer modified. Formatting aborted.", vim.log.levels.WARN)
    return
  end
  local old_lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local old_text = table.concat(old_lines, "\n") .. "\n"
  if text == "" and old_text:match("%S") then
    vim.notify("Formatter returned empty text. Aborted to prevent data loss.", vim.log.levels.ERROR)
    return
  end
  text = text:gsub("\r\n", "\n")
  local new_lines = vim.split(text, "\n")
  if new_lines[#new_lines] == "" then
    table.remove(new_lines)
  end
  local new_text = table.concat(new_lines, "\n") .. "\n"

  if old_text == new_text then
    return
  end

  local indices = vim.diff(old_text, new_text, { result_type = "indices" })

  for i = #indices, 1, -1 do
    local hunk = indices[i]
    local start_a, count_a, start_b, count_b = hunk[1], hunk[2], hunk[3], hunk[4]
    local start_row = (count_a == 0) and start_a or (start_a - 1)
    local end_row = start_row + count_a

    local replacement = {}
    for j = start_b, start_b + count_b - 1 do
      table.insert(replacement, new_lines[j])
    end

    vim.api.nvim_buf_set_lines(bufnr, start_row, end_row, false, replacement)
  end
end

local function is_executable(bin)
  if executable_cache[bin] then
    return true
  end
  if vim.fn.executable(bin) == 1 then
    executable_cache[bin] = true
    return true
  end
  return false
end

local function are_executables_missing(cmds)
  for _, cmd in ipairs(cmds) do
    if not is_executable(cmd[1]) then
      vim.notify("Formatter missing: " .. cmd[1] .. ". Falling back to LSP.", vim.log.levels.WARN)
      return true
    end
  end
  return false
end

local function extract_error(obj)
  if obj.stderr and obj.stderr ~= "" then
    return obj.stderr
  end
  if obj.stdout and obj.stdout ~= "" then
    return obj.stdout
  end
  return "Unknown error"
end

local function run_async_pipeline(cmds, input_text, file_dir, bufnr, initial_tick)
  local function next_step(idx, text)
    if idx > #cmds then
      vim.schedule(function()
        apply_text(bufnr, initial_tick, text)
      end)
      return
    end
    local cmd = cmds[idx]
    local opts = { text = true, stdin = text, cwd = file_dir }
    vim.system(cmd, opts, function(obj)
      if obj.code == 0 then
        next_step(idx + 1, obj.stdout)
      else
        vim.schedule(function()
          vim.notify(cmd[1] .. " failed:\n" .. extract_error(obj), vim.log.levels.ERROR)
        end)
      end
    end)
  end
  next_step(1, input_text)
end

local function run_sync_pipeline(cmds, input_text, file_dir, bufnr, initial_tick)
  local text = input_text
  for _, cmd in ipairs(cmds) do
    local opts = { text = true, stdin = text, cwd = file_dir }
    local sys_obj = vim.system(cmd, opts)

    local ok, result = pcall(function()
      return sys_obj:wait(timeout_ms)
    end)
    if not ok or not result then
      sys_obj:kill(9)
      vim.notify(cmd[1] .. " timed out.", vim.log.levels.ERROR)
      return
    elseif result.code ~= 0 then
      vim.notify(cmd[1] .. " failed:\n" .. extract_error(result), vim.log.levels.ERROR)
      return
    end

    text = result.stdout
  end
  apply_text(bufnr, initial_tick, text)
end

function Formatter.format(opts)
  opts = opts or {}
  local bufnr = vim.api.nvim_get_current_buf()

  if not vim.bo[bufnr].modifiable or vim.bo[bufnr].buftype ~= "" then
    return
  end

  local line_count = vim.api.nvim_buf_line_count(bufnr)
  if line_count > max_file_size then
    vim.notify("Buffer too large. Formatting skipped.", vim.log.levels.WARN)
    return
  end

  local ft = vim.bo[bufnr].filetype
  if ft == "vim" then
    local view = vim.fn.winsaveview()
    vim.cmd("silent! normal! gg=G")
    vim.fn.winrestview(view)
    return
  end

  local get_cmds = Formatter.formatters_by_ft[ft]
  local cmds = get_cmds and get_cmds(bufnr) or nil

  if not cmds or are_executables_missing(cmds) then
    vim.lsp.buf.format({ async = opts.async, bufnr = bufnr, timeout_ms = timeout_ms })
    return
  end

  local initial_tick = vim.b[bufnr].changedtick
  local filename = vim.api.nvim_buf_get_name(bufnr)
  local file_dir = filename ~= "" and vim.fn.fnamemodify(filename, ":h") or nil
  if file_dir and vim.fn.isdirectory(file_dir) == 0 then
    file_dir = nil
  end

  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local input_text = table.concat(lines, "\n") .. "\n"

  if opts.async then
    run_async_pipeline(cmds, input_text, file_dir, bufnr, initial_tick)
  else
    run_sync_pipeline(cmds, input_text, file_dir, bufnr, initial_tick)
  end
end

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  group = vim.api.nvim_create_augroup("custom-format-on-save", { clear = true }),
  callback = function()
    if vim.g.disable_autoformat then
      return
    end
    Formatter.format({ async = false })
  end,
})

Snacks.toggle({
  name = "Format on Save",
  get = function()
    return not (vim.g.disable_autoformat or false)
  end,
  set = function(state)
    vim.g.disable_autoformat = not state
    if state then
      Formatter.format({ async = true })
    end
  end,
}):map("|f")

vim.api.nvim_create_user_command("Format", function()
  Formatter.format({ async = true })
end, { desc = "Format current buffer asynchronously" })

vim.keymap.set("n", "==", "<cmd>Format<cr>", { desc = "custom format" })
