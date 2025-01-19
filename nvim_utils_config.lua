Snacks = require("snacks")
vim.keymap.set("n", "<leader><leader>", function()
  Snacks.picker.smart()
end, { desc = "smart_open" })
vim.keymap.set("n", "<leader>ff", function()
  Snacks.picker.files()
end, { desc = "find_file" })
vim.keymap.set("n", "<leader>fb", function()
  Snacks.picker.buffers()
end, { desc = "find_buffers" })
vim.keymap.set("n", "<leader>fr", function()
  Snacks.picker.recent()
end, { desc = "find_recent" })
vim.keymap.set("n", "<leader>fh", function()
  Snacks.picker.help()
end, { desc = "find_help" })
vim.keymap.set("n", "<leader>fp", function()
  Snacks.picker.files({ cwd = vim.fs.joinpath(vim.fn.stdpath("data"), "site") })
end, { desc = "find_plugin" })
vim.keymap.set("n", "<leader>pp", function()
  Snacks.picker.pickers()
end, { desc = "find_plugin" })
vim.keymap.set("n", "<leader>fk", function()
  Snacks.picker.keymaps()
end, { desc = "find_keymaps" })
vim.keymap.set("n", "<leader>fz", function()
  Snacks.picker.zoxide()
end, { desc = "find_zoxide" })
vim.keymap.set("n", "<leader>fd", function()
  Snacks.picker.diagnostics()
end, { desc = "lsp_diagnostics" })
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

Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>ts")
Snacks.toggle
  .option("background", { off = "light", on = "dark", name = "Dark Background" })
  :map("<leader>tb")
Snacks.toggle.inlay_hints():map("<leader>th")

vim.keymap.set("n", "<leader>un", function()
  Snacks.notifier.hide()
end, { desc = "Dismiss All Notifications" })

vim.keymap.set("n", "<leader>bd", function()
  Snacks.bufdelete()
end, { desc = "Delete Buffer" })

vim.keymap.set("n", "<leader>fn", function()
  Snacks.notifier.show_history()
end, { desc = "find_notification" })

vim.keymap.set("n", "<leader>fm", "<cmd>messages<cr>", { desc = "find_messages" })

vim.keymap.set("n", "<leader>gB", function()
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

vim.keymap.set({ "n" }, "<leader>fS", function()
  Snacks.scratch.select()
end, { desc = "Find Scratch" })
vim.keymap.set("n", "<leader>z", function()
  Snacks.zen()
end, { desc = "Toggle Zen Mode" })
vim.keymap.set("n", "<leader>Z", function()
  Snacks.zen.zoom()
end, { desc = "Toggle Zoom" })

local format_size = function(size)
  if size == nil then
    return
  elseif size < 1024 then
    return string.format("%3dB", size)
  elseif size < 1048576 then
    return string.format("%3.0fK", size / 1024)
  else
    return string.format("%3.0fM", size / 1048576)
  end
end
local format_time = function(time)
  if time == nil then
    return
  else
    local ret = vim.fn.strftime("%y-%m-%d %H:%M", time.sec)
    return ret
  end
end

local my_pre_prefix = function(fs_stat)
  local _, mtime = pcall(format_time, fs_stat.mtime)
  local pre_prefix = ""
  if mtime ~= nil then
    pre_prefix = pre_prefix .. " " .. mtime
  end
  if fs_stat.type == "file" then
    local _, size = pcall(format_size, fs_stat.size)
    if size ~= nil then
      pre_prefix = pre_prefix .. " " .. size
    end
  end
  return pre_prefix
end

local MiniFiles = require("mini.files")
local my_prefix = function(fs_entry)
  local prefix, hl = MiniFiles.default_prefix(fs_entry)
  local fs_stat = vim.loop.fs_stat(fs_entry.path) or {}
  local pre_prefix = my_pre_prefix(fs_stat)
  return pre_prefix .. " " .. prefix, hl
end

local show_details = true
local toggle_details = function()
  show_details = not show_details
  if show_details then
    MiniFiles.refresh({
      windows = {
        width_nofocus = 30,
      },
      content = { prefix = my_prefix },
    })
  else
    MiniFiles.refresh({
      windows = {
        width_nofocus = 15,
      },
      content = { prefix = MiniFiles.default_prefix },
    })
  end
end

MiniFiles.setup({
  mappings = {
    go_in_plus = "<CR>",
    trim_left = ">",
    trim_right = "<",
  },
  options = {
    permanent_delete = false,
    use_as_default_explorer = true,
  },
  windows = {
    max_number = math.huge,
    preview = true,
    width_focus = 50,
    width_nofocus = 30,
    width_preview = 100,
  },
  content = { prefix = my_prefix },
})

vim.keymap.set("n", "<a-e>", function()
  if not MiniFiles.close() then
    MiniFiles.open()
  end
end)

local show_dotfiles = true

local filter_show = function(_)
  return true
end

local filter_hide = function(fs_entry)
  return not vim.startswith(fs_entry.name, ".")
end

local toggle_dotfiles = function()
  show_dotfiles = not show_dotfiles
  local new_filter = show_dotfiles and filter_show or filter_hide
  require("mini.files").refresh({ content = { filter = new_filter } })
end

local open_totalcmd = function(_)
  local cur_entry_path = MiniFiles.get_fs_entry().path
  -- local cur_directory = vim.fs.dirname(cur_entry_path)
  -- vim.fn.system(string.format("gio open '%s'", cur_entry_path))
  vim.api.nvim_command(string.format("!%s /O /T /L='%s'", vim.g.total_cmd_exe, cur_entry_path))
  MiniFiles.close()
end

local open_file = function(_)
  local cur_entry_path = MiniFiles.get_fs_entry().path
  vim.ui.open(cur_entry_path)
  MiniFiles.close()
end

local map_split = function(buf_id, lhs, direction)
  local rhs = function()
    -- Make new window and set it as target
    local new_target_window
    vim.api.nvim_win_call(MiniFiles.get_target_window(), function()
      vim.cmd(direction .. " split")
      new_target_window = vim.api.nvim_get_current_win()
    end)

    MiniFiles.set_target_window(new_target_window)
  end

  -- Adding `desc` will result into `show_help` entries
  local desc = "Split " .. direction
  vim.keymap.set("n", lhs, rhs, { buffer = buf_id, desc = desc })
end

local files_set_cwd = function(_)
  -- Works only if cursor is on the valid file system entry
  -- Does not work with have vim-rooter is on
  local cur_entry_path = MiniFiles.get_fs_entry().path
  local cur_directory = vim.fs.dirname(cur_entry_path)
  vim.fn.chdir(cur_directory)
  vim.notify(vim.inspect(cur_directory))
end

vim.api.nvim_create_autocmd("User", {
  pattern = "MiniFilesBufferCreate",
  group = vim.api.nvim_create_augroup("mini-file-buffer", { clear = true }),
  callback = function(args)
    local buf_id = args.data.buf_id
    -- g? to show keymap table
    vim.keymap.set("n", "g.", toggle_dotfiles, { buffer = buf_id, desc = "Toggle dot files" })
    vim.keymap.set("n", "g,", toggle_details, { buffer = buf_id, desc = "Toggle file details" })
    vim.keymap.set("n", "gt", open_totalcmd, { buffer = buf_id, desc = "Open in TotalCmd" })
    vim.keymap.set("n", "gx", open_file, { buffer = buf_id, desc = "Open Externally" })
    vim.keymap.set("n", "g`", files_set_cwd, { buffer = args.data.buf_id, desc = "Set dir" })
    vim.keymap.set("n", "<esc>", require("mini.files").close, { buffer = buf_id, desc = "Close" })
    map_split(buf_id, "gs", "belowright horizontal")
    map_split(buf_id, "gv", "belowright vertical")
  end,
})

-- for vscode it is handled on vscode level (composite-keys)
require("better_escape").setup({
  timeout = 150,
  default_mappings = false,
  mappings = {
    i = { j = { k = "<Esc>" } },
    c = { j = { k = "<Esc>" } },
    t = { j = { k = "<C-\\><C-n>" } },
    v = { j = { k = "<Esc>" } },
    s = { j = { k = "<Esc>" } },
  },
})

require("mini.trailspace").setup()

if vim.fn.has("linux") == 1 then
  local function paste()
    return {
      vim.fn.split(vim.fn.getreg(""), "\n"),
      vim.fn.getregtype(""),
    }
  end

  vim.g.clipboard = {
    name = "OSC 52",
    copy = {
      ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
      ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
    },
    paste = {
      ["+"] = paste,
      ["*"] = paste,
    },
  }
end
vim.opt.clipboard:append("unnamedplus")

-- prevent the swap alert
vim.opt.swapfile = false
require("mini.git").setup()

-- require("mini.indentscope").setup({
--   draw = {
--     delay = 200,
--   },
-- })
-- local disable_indentscope = function(data)
--   vim.b[data.buf].miniindentscope_disable = true
-- end
-- vim.api.nvim_create_autocmd(
--   "TermOpen",
--   { desc = "Disable 'mini.indentscope' in terminal buffer", callback = disable_indentscope }
-- )
-- vim.api.nvim_create_autocmd("FileType", {
--   pattern = { "markdown", "vimwiki" },
--   callback = disable_indentscope,
--   desc = "Disable 'mini.indentscope' in markdown buffer",
-- })

local wk = require("which-key")
wk.setup({
  present = "modern",
  triggers = {
    { "<auto>", mode = "nixsoc" },
    -- { "<leader>", mode = {"n","v","t"}},
  },
  delay = function(ctx)
    return ctx.plugin and 0 or 150
  end,
  defer = function(ctx)
    return ctx.mode == "V" or ctx.mode == "<C-V>" or ctx.mode == "v"
  end,
  debug = false,
  win = {
    padding = { 0, 2 },
    wo = {
      winblend = 20, -- value between 0-100 0 for fully opaque and 100 for fully transparent
    },
  },
  layout = {
    spacing = 2, -- spacing between columns
  },
  disable = {
    ft = { "toggleterm", "NvimTree", "oil", "minifiles" },
    bt = {},
  },
})

vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("yank-highlight", { clear = true }),
  callback = function()
    vim.highlight.on_yank({ higroup = "Visual", timeout = 500 })
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = {
    "help",
    "startuptime",
    "qf",
    "lspinfo",
    "man",
    "checkhealth",
    "noice",
  },
  group = vim.api.nvim_create_augroup("q-to-close", { clear = true }),
  callback = function()
    vim.keymap.set("n", "<ESC>", "<cmd>close<CR>", { buffer = true, silent = true })
    vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = true, silent = true })
    vim.bo.buflisted = false
  end,
})

vim.api.nvim_create_user_command("PU", function()
  vim.cmd("DepsUpdate")
end, { desc = "DepsUpdate" })

-- turn auto save off on acwrite
local disabled_filetype = { "minideps-confirm", "gitcommit" }
vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged" }, {
  group = vim.api.nvim_create_augroup("disable-auto-save", { clear = true }),
  callback = function()
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      local file_type = vim.api.nvim_get_option_value("filetype", { buf = buf })
      if vim.tbl_contains(disabled_filetype, file_type) and vim.g.auto_save == 1 then
        vim.notify("vim.g.auto_save = 0 (OFF)", 3, { title = "AutoSave" })
        vim.g.auto_save = 0
        return
      elseif vim.tbl_contains(disabled_filetype, file_type) and vim.g.auto_save == 0 then
        return
      end
    end
    if vim.g.auto_save == 0 then
      vim.notify("vim.g.auto_save = 1 (ON)", 2, { title = "AutoSave" })
      vim.g.auto_save = 1
    end
  end,
})

local mini_misc = require("mini.misc")
mini_misc.setup()
mini_misc.setup_auto_root()
mini_misc.setup_restore_cursor()

local animate = require("mini.animate")
animate.setup({
  cursor = {
    timing = animate.gen_timing.linear({ duration = 20, unit = "total" }),
    path = animate.gen_path.line({
      predicate = function()
        return true
      end,
    }),
  },
  scroll = {
    timing = animate.gen_timing.linear({ duration = 40, unit = "total" }),
    subscroll = animate.gen_subscroll.equal({ max_output_steps = 40 }),
  },
  resize = { enable = false },
  open = { enable = false },
  close = { enable = false },
})
vim.keymap.set(
  "n",
  "<C-d>",
  [[<Cmd>lua vim.cmd('normal! <C-d>'); MiniAnimate.execute_after('scroll', 'normal! zvzz')<CR>]]
)
vim.keymap.set(
  "n",
  "<C-u>",
  [[<Cmd>lua vim.cmd('normal! <C-u>'); MiniAnimate.execute_after('scroll', 'normal! zvzz')<CR>]]
)

vim.keymap.set(
  "n",
  "n",
  [[<Cmd>lua vim.cmd('normal! n'); MiniAnimate.execute_after('scroll', 'normal! zvzz')<CR>]]
)
vim.keymap.set(
  "n",
  "N",
  [[<Cmd>lua vim.cmd('normal! N'); MiniAnimate.execute_after('scroll', 'normal! zvzz')<CR>]]
)
