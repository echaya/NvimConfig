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
    permanent_delete = true,
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

local map_split = function(buf_id, lhs, direction, close)
  local rhs = function()
    -- Make new window and set it as target
    local cur_target = MiniFiles.get_explorer_state().target_window
    local new_target = vim.api.nvim_win_call(cur_target, function()
      vim.cmd(direction .. " split")
      return vim.api.nvim_get_current_win()
    end)

    MiniFiles.set_target_window(new_target)
    MiniFiles.go_in()
    if close then
      MiniFiles.close()
    end
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
    map_split(buf_id, "gs", "belowright horizontal", false)
    map_split(buf_id, "gv", "belowright vertical", false)
    map_split(buf_id, "<C-s>", "belowright horizontal", true)
    map_split(buf_id, "<C-v>", "belowright vertical", true)
    vim.keymap.set("n", "<a-h>", toggle_dotfiles, { buffer = buf_id, desc = "Toggle dot files" })
  end,
})

local map_combo = require("mini.keymap").map_combo
map_combo({ "i", "t" }, "jk", "<BS><BS><Cmd>stopinsert<CR>", { delay = 150 })
map_combo({ "c", "s", "x" }, "jk", "<BS><BS><Esc>", { delay = 150 })
map_combo("n", "jk", "<cmd>wincmd =<cr>k", { delay = 150 })

local notify_many_keys = function(key)
  local lhs = string.rep(key, 5)
  local action = function()
    vim.notify("**Too many** repeated " .. key)
  end
  map_combo({ "n", "x" }, lhs, action)
end
notify_many_keys("h")
notify_many_keys("j")
notify_many_keys("k")
notify_many_keys("l")

local map_multistep = require("mini.keymap").map_multistep
-- NOTE: this will never insert tab, press <C-v><Tab> for that
local tab_steps = { "blink_next", "increase_indent", "jump_after_close" }
map_multistep("i", "<Tab>", tab_steps)
local shifttab_steps = { "blink_prev", "decrease_indent", "jump_before_open" }
map_multistep("i", "<S-Tab>", shifttab_steps)

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

vim.api.nvim_create_user_command("GH", function()
  local current_filetype = vim.api.nvim_get_option_value("filetype", { buf = 0 })
  if current_filetype ~= "gitcommit" then
    vim.notify("GH command: Not a gitcommit buffer. Aborting.", vim.log.levels.INFO)
    return
  end
  local initial_bufnr = vim.api.nvim_get_current_buf()
  local initial_buftype = vim.api.nvim_get_option_value("buftype", { buf = initial_bufnr })
  local initial_modifiable = vim.api.nvim_get_option_value("modifiable", { buf = initial_bufnr })
  local can_write_initial = (
    initial_modifiable and (initial_buftype == nil or initial_buftype == "")
  )
  local cmd_to_run = "q" -- Default to quit only
  if can_write_initial then
    cmd_to_run = "wq"
  end
  pcall(vim.api.nvim_command, cmd_to_run)
  pcall(vim.api.nvim_command, "tabc")

  vim.schedule(function()
    local post_tabc_bufnr = vim.api.nvim_get_current_buf()
    if not vim.api.nvim_buf_is_valid(post_tabc_bufnr) then
      return
    end
    local post_tabc_bufname = vim.api.nvim_buf_get_name(post_tabc_bufnr)
    local is_new_buf_diffview = false
    if
      post_tabc_bufname
      and type(post_tabc_bufname) == "string"
      and string.lower(post_tabc_bufname):find("^diffview") == 1
    then
      is_new_buf_diffview = true
    end
    if is_new_buf_diffview then
      pcall(vim.api.nvim_command, "tabc")
    end
  end)

  vim.defer_fn(function()
    local ok_push, err_push = pcall(vim.api.nvim_command, "Git! push")
    if not ok_push then
      vim.notify("GH command: Error executing 'Git! push': " .. err_push, vim.log.levels.ERROR)
    end
  end, 1000)
end, {
  desc = "Write/Quit, close tab, check new tab & close if diffview, then Git push",
  nargs = 0,
})

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

local mini_misc = require("mini.misc")
mini_misc.setup()
mini_misc.setup_auto_root()
mini_misc.setup_restore_cursor()

require("noice").setup({
  lsp = {
    override = {
      ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
      ["vim.lsp.util.stylize_markdown"] = true,
      ["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
    },
  },
  routes = {
    {
      filter = {
        event = "msg_show",
        any = {
          { find = "%d+L, %d+B" },
          { find = "; after #%d+" },
          { find = "; before #%d+" },
        },
      },
      view = "mini",
    },
  },
  signature = { auto_open = { throttle = 10 } },
  presets = {
    bottom_search = true, -- use a classic bottom cmdline for search
    command_palette = true, -- position the cmdline and popupmenu together
    long_message_to_split = true, -- long messages will be sent to a split
    inc_rename = false, -- enables an input dialog for inc-rename.nvim
    lsp_doc_border = true, -- add a border to hover docs and signature help
  },
})

vim.api.nvim_create_autocmd("RecordingEnter", {
  callback = function()
    local msg = string.format("Register:  %s", vim.fn.reg_recording())
    _MACRO_RECORDING_STATUS = true
    vim.notify(msg, vim.log.levels.INFO, {
      title = "Macro Recording",
      keep = function()
        return _MACRO_RECORDING_STATUS
      end,
    })
  end,
  group = vim.api.nvim_create_augroup("NoiceMacroNotfication", { clear = true }),
})

vim.api.nvim_create_autocmd("RecordingLeave", {
  callback = function()
    _MACRO_RECORDING_STATUS = false
    vim.notify("Success!", vim.log.levels.INFO, {
      title = "Macro Recording End",
      timeout = 2000,
    })
  end,
  group = vim.api.nvim_create_augroup("NoiceMacroNotficationDismiss", { clear = true }),
})

local auto_save_augroup_name = "UserAutoSaveOnEvents"
vim.api.nvim_create_augroup(auto_save_augroup_name, { clear = true })
local disabled_filetypes_for_auto_save = { "minideps-confirm", "gitcommit", "gitrebase" }
local disabled_buftypes_for_auto_save =
  { "nofile", "nowrite", "terminal", "prompt", "quickfix", "help" }

vim.api.nvim_create_autocmd({ "BufLeave", "FocusLost", "VimLeavePre" }, {
  group = auto_save_augroup_name,
  pattern = "*",
  callback = function(event)
    local buf = event.buf

    if not vim.api.nvim_buf_is_valid(buf) then
      return
    end
    if not vim.api.nvim_buf_is_loaded(buf) then
      return
    end
    if not vim.api.nvim_get_option_value("modifiable", { buf = buf }) then
      return
    end
    local buf_name = vim.api.nvim_buf_get_name(buf)
    if not buf_name or buf_name == "" then
      -- vim.notify( "Auto-save skipped: Buffer is unnamed", vim.log.levels.DEBUG, { title = "AutoSave" })
      return
    end
    local buftype = vim.api.nvim_get_option_value("buftype", { buf = buf })
    if buftype ~= "" and vim.tbl_contains(disabled_buftypes_for_auto_save, buftype) then
      -- vim.notify( "Auto-save skipped for buftype: " .. buftype .. " (" .. vim.fn.fnamemodify(buf_name, ":.") .. ")", vim.log.levels.DEBUG, { title = "AutoSave" })
      return
    end
    local filetype = vim.api.nvim_get_option_value("filetype", { buf = buf })
    if filetype ~= "" and vim.tbl_contains(disabled_filetypes_for_auto_save, filetype) then
      -- vim.notify( "Auto-save OFF for filetype: " .. filetype .. " (" .. vim.fn.fnamemodify(buf_name, ":.") .. ")", vim.log.levels.INFO, { title = "AutoSave" })
      return
    end
    if vim.api.nvim_get_option_value("modified", { buf = buf }) then
      vim.schedule(function()
        if not vim.api.nvim_buf_is_valid(buf) then
          return
        end
        if not vim.api.nvim_buf_is_loaded(buf) then
          return
        end
        if not vim.api.nvim_get_option_value("modifiable", { buf = buf }) then
          return
        end
        if not vim.api.nvim_get_option_value("modified", { buf = buf }) then
          return
        end

        local current_buf_name_scheduled = vim.api.nvim_buf_get_name(buf) -- Re-fetch name, in case it changed (e.g. :saveas)
        if not current_buf_name_scheduled or current_buf_name_scheduled == "" then
          return
        end

        -- vim.notify( "Auto-saving: " .. vim.fn.fnamemodify(current_buf_name_scheduled, ":."), vim.log.levels.INFO, { title = "AutoSave" })

        vim.api.nvim_buf_call(buf, function()
          local success, err_msg = pcall(vim.cmd, "silent! write")
          if not success then
            vim.notify(
              "Auto-save failed for "
                .. vim.fn.fnamemodify(current_buf_name_scheduled, ":.")
                .. ": "
                .. err_msg,
              vim.log.levels.ERROR,
              { title = "AutoSave" }
            )
          end
        end)
      end)
    end
  end,
})
