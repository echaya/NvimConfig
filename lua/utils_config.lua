local mini_files = require("mini.files")

local WIN_WIDTH_FOCUS = 50
local WIN_WIDTH_NOFOCUS = 15
local WIN_WIDTH_NOFOCUS_DETAILED = 30
local WIN_WIDTH_PREVIEW = 100
local SORT_LIMIT = 100

local format_size = function(size)
  if not size then
    return ""
  end
  if size < 1024 then
    return string.format("%3dB", size)
  elseif size < 1048576 then
    return string.format("%3.0fK", size / 1024)
  else
    return string.format("%3.0fM", size / 1048576)
  end
end
local format_time = function(time)
  if not time then
    return ""
  end
  return vim.fn.strftime("%y-%m-%d %H:%M", time.sec)
end

local my_pre_prefix = function(fs_stat)
  if not fs_stat then
    return ""
  end
  local parts = {}
  local mtime = format_time(fs_stat.mtime)
  if mtime ~= "" then
    table.insert(parts, mtime)
  end
  if fs_stat.type == "file" then
    local size = format_size(fs_stat.size)
    if size ~= "" then
      table.insert(parts, size)
    end
  end
  if #parts == 0 then
    return ""
  end
  return table.concat(parts, " ")
end

local my_prefix = function(fs_entry)
  local prefix, hl = mini_files.default_prefix(fs_entry)
  local fs_stat = vim.uv.fs_stat(fs_entry.path)
  local pre_prefix = my_pre_prefix(fs_stat)

  if pre_prefix == "" then
    return prefix, hl
  end
  return pre_prefix .. " " .. prefix, hl
end

local show_details = true
local toggle_details = function()
  show_details = not show_details
  if show_details then
    mini_files.refresh({
      windows = {
        width_nofocus = WIN_WIDTH_NOFOCUS_DETAILED,
      },
      content = { prefix = my_prefix },
    })
  else
    mini_files.refresh({
      windows = {
        width_nofocus = WIN_WIDTH_NOFOCUS,
      },
      content = { prefix = mini_files.default_prefix },
    })
  end
end

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
  mini_files.refresh({ content = { filter = new_filter } })
end

local show_preview = true
local toggle_preview = function()
  show_preview = not show_preview
  mini_files.refresh({
    windows = {
      preview = show_preview,
    },
  })
end

local open_totalcmd = function(_)
  local entry = mini_files.get_fs_entry()
  if not entry then
    return
  end

  if not vim.g.total_cmd_exe then
    vim.notify("Global variable 'total_cmd_exe' is not set.", vim.log.levels.ERROR)
    return
  end

  vim.api.nvim_command(string.format("!%s /O /T /L='%s'", vim.g.total_cmd_exe, entry.path))
  mini_files.close()
end

local open_file = function(_)
  local entry = mini_files.get_fs_entry()
  if entry then
    vim.ui.open(entry.path)
    mini_files.close()
  end
end

local map_split = function(buf_id, lhs, direction, close)
  local rhs = function()
    -- Make new window and set it as target
    local cur_target = mini_files.get_explorer_state().target_window
    local new_target = vim.api.nvim_win_call(cur_target, function()
      vim.cmd(direction .. " split")
      return vim.api.nvim_get_current_win()
    end)

    mini_files.set_target_window(new_target)
    mini_files.go_in()
    if close then
      mini_files.close()
    end
  end

  local desc = "Split " .. direction
  vim.keymap.set("n", lhs, rhs, { buffer = buf_id, desc = desc })
end

local files_set_cwd = function(_)
  local entry = mini_files.get_fs_entry()
  if not entry then
    return
  end
  local cur_entry_path = entry.path
  local cur_directory = vim.fs.dirname(cur_entry_path)
  if entry.fs_type == "directory" then
    cur_directory = cur_entry_path
  end
  vim.fn.chdir(cur_directory)
  vim.notify("CWD set to: " .. cur_directory)
end

local yank_scp_command = function()
  local entry = mini_files.get_fs_entry()
  if not entry then
    return
  end
  local path = entry.path
  local hostname = vim.uv.os_gethostname() -- e.g., "dev_web-01.example.com"
  local short_host = hostname:match("_(.*)") or hostname
  short_host = short_host:match("^([^%.]+)") or short_host
  local scp_cmd = string.format("scp -P 8080 %s.spaces:%s .", short_host, path)
  local b64 = vim.fn.system(string.format("echo -n '%s' | base64 | tr -d '\n'", scp_cmd))
  local osc52 = string.format("\27]52;c;%s\7", b64)
  vim.uv.fs_write(1, osc52, -1)
  vim.notify("📋 Copied to Clipboard:\n" .. scp_cmd, vim.log.levels.INFO)
  mini_files.close()
end

local sort_mode = "name" -- "name" | "size" | "date"
local prepare_stats = function(fs_entries)
  for _, entry in ipairs(fs_entries) do
    if not entry.stat then
      entry.stat = vim.uv.fs_stat(entry.path) or {}
    end
  end
end

local sort_by_size = function(fs_entries)
  prepare_stats(fs_entries)
  table.sort(fs_entries, function(a, b)
    if a.fs_type ~= b.fs_type then
      return a.fs_type == "directory"
    end
    if a.fs_type == "directory" then
      return a.name:lower() < b.name:lower()
    end
    local size_a = a.stat.size or 0
    local size_b = b.stat.size or 0
    return size_a > size_b
  end)
  return fs_entries
end

local sort_by_date = function(fs_entries)
  prepare_stats(fs_entries)
  table.sort(fs_entries, function(a, b)
    if a.fs_type ~= b.fs_type then
      return a.fs_type == "directory"
    end
    if a.fs_type == "directory" then
      return a.name:lower() < b.name:lower()
    end
    local time_a = a.stat.mtime and a.stat.mtime.sec or 0
    local time_b = b.stat.mtime and b.stat.mtime.sec or 0
    return time_a > time_b
  end)
  return fs_entries
end

local sort_mode = "name" -- "name" | "size" | "date"
local last_warn_time = 0
local custom_sort = function(fs_entries)
  if sort_mode == "name" then
    return mini_files.default_sort(fs_entries)
  end

  if #fs_entries > SORT_LIMIT then
    local now = vim.uv.now()
    if (now - last_warn_time) > 2000 then
      vim.notify(
        string.format("Directory too large (>%d). Falling back to name sort.", SORT_LIMIT),
        vim.log.levels.WARN,
        { title = "MiniFiles Sort" }
      )
      last_warn_time = now
    end

    return mini_files.default_sort(fs_entries)
  end

  if sort_mode == "size" then
    return sort_by_size(fs_entries)
  elseif sort_mode == "date" then
    return sort_by_date(fs_entries)
  end
end

local toggle_sort = function()
  if sort_mode == "name" then
    sort_mode = "size"
    vim.notify("Sort: Size (Descending)", vim.log.levels.INFO)
  elseif sort_mode == "size" then
    sort_mode = "date"
    vim.notify("Sort: Date (Newest)", vim.log.levels.INFO)
  else
    sort_mode = "name"
    vim.notify("Sort: Name (A-Z)", vim.log.levels.INFO)
  end

  mini_files.refresh({ content = { sort = custom_sort } })
end

mini_files.setup({
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
    width_focus = WIN_WIDTH_FOCUS,
    width_nofocus = WIN_WIDTH_NOFOCUS_DETAILED, -- Default to detailed view
    width_preview = WIN_WIDTH_PREVIEW,
  },
  content = { prefix = my_prefix, sort = custom_sort },
})

vim.api.nvim_create_autocmd("User", {
  pattern = "MiniFilesBufferCreate",
  group = vim.api.nvim_create_augroup("mini-file-buffer", { clear = true }),
  callback = function(args)
    local buf_id = args.data.buf_id

    local map = function(lhs, rhs, desc)
      vim.keymap.set("n", lhs, rhs, { buffer = buf_id, desc = desc })
    end

    map("g.", toggle_dotfiles, "Toggle dot files")
    map("g,", toggle_details, "Toggle file details")
    map("gs", toggle_sort, "Toggle sort")
    map("gt", open_totalcmd, "Open in TotalCmd")
    map("gx", open_file, "Open Externally")
    map("gy", yank_scp_command, "Create scp comand")
    map("gp", toggle_preview, "Toggle preview")
    map("g`", files_set_cwd, "Set dir")
    map("<esc>", mini_files.close, "Close")
    map("<a-h>", toggle_dotfiles, "Toggle dot files")

    map_split(buf_id, "gv", "belowright vertical", false)
    map_split(buf_id, "<C-s>", "belowright horizontal", true)
    map_split(buf_id, "<C-v>", "belowright vertical", true)
  end,
})

vim.keymap.set("n", "<leader>e", function()
  if not mini_files.close() then
    mini_files.open()
  end
end, { desc = "Toggle Mini Files" })

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

local mini_trail = require("mini.trailspace")
mini_trail.setup()
vim.api.nvim_create_user_command("RemoveTrailingSpace", function()
  mini_trail.trim()
  mini_trail.trim_last_lines()
end, { desc = "mini trailspace remove space and trail empty line" })

if vim.fn.has("linux") == 1 then
  local last_copy = { { "" }, "v" }

  local function paste()
    return last_copy
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

  vim.api.nvim_create_autocmd("TextYankPost", {
    callback = function()
      last_copy = { vim.v.event.regcontents, vim.v.event.regtype }
    end,
  })
end
vim.opt.clipboard:append("unnamedplus")

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
    vim.notify(string.format("Register: %s", vim.fn.reg_recording()), vim.log.levels.INFO, {
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

    -- 1. Fast Fail: Basic Validity Checks
    if
      not vim.api.nvim_buf_is_valid(buf)
      or not vim.api.nvim_buf_is_loaded(buf)
      or not vim.api.nvim_get_option_value("modifiable", { buf = buf })
    then
      return
    end
    -- 2. Check Blocklists (Using your original variable names)
    local buftype = vim.api.nvim_get_option_value("buftype", { buf = buf })
    if buftype ~= "" and vim.tbl_contains(disabled_buftypes_for_auto_save, buftype) then
      return
    end
    local filetype = vim.api.nvim_get_option_value("filetype", { buf = buf })
    if filetype ~= "" and vim.tbl_contains(disabled_filetypes_for_auto_save, filetype) then
      return
    end

    local buf_name = vim.api.nvim_buf_get_name(buf)
    if not buf_name or buf_name == "" then
      return
    end
    -- 3. Check modification status
    if not vim.api.nvim_get_option_value("modified", { buf = buf }) then
      return
    end
    -- 4. Define the Save Logic
    local function perform_save()
      -- Re-verify validity in case context changed during schedule delay
      if
        not vim.api.nvim_buf_is_valid(buf)
        or not vim.api.nvim_buf_is_loaded(buf)
        or not vim.api.nvim_get_option_value("modified", { buf = buf })
      then
        return
      end

      vim.api.nvim_buf_call(buf, function()
        -- Use pcall to prevent errors from breaking the editor
        local success, err_msg = pcall(vim.cmd, "silent! write")
        if not success then
          vim.notify("Auto-save failed: " .. err_msg, vim.log.levels.ERROR, { title = "AutoSave" })
        end
      end)
    end
    -- 5. Execution Strategy: Sync on Exit, Async on Navigation
    if event.event == "VimLeavePre" then
      perform_save()
    else
      vim.schedule(perform_save)
    end
  end,
})
