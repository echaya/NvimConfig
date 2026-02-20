local mini_files = require("mini.files")

local CONFIG = {
  width_focus = 50,
  width_nofocus = 15,
  width_nofocus_detailed = 30,
  width_preview = 100,
  sort_limit = 100, -- Max files before disabling details/sort
  sort_warning_cd = 2000, -- Cooldown for warnings (ms)
  cache_limit = 1000, -- Max No. of dir to be cached
}

local STATE = {
  show_details = true,
  show_dotfiles = true,
  show_preview = true,
  sort_mode = "name", -- "name" | "date" | "size"
  last_warn_time = 0,
}

local STAT_CACHE = {} -- Map: path -> fs_stat
local CACHED_DIRS = {} -- Set: dir_path -> boolean
local CACHE_DIR_COUNT = 0 -- Counter for cached directories
local LARGE_DIRS = {} -- Set: dir_path -> boolean (Too large for details)

-- Clear cache (used on close, overflow, or synchronize)
local clear_cache = function()
  STAT_CACHE = {}
  CACHED_DIRS = {}
  LARGE_DIRS = {}
  CACHE_DIR_COUNT = 0
end

local ensure_stats = function(fs_entries)
  if #fs_entries == 0 then
    return
  end

  local dir_path = vim.fs.dirname(fs_entries[1].path)

  if not CACHED_DIRS[dir_path] then
    if CACHE_DIR_COUNT >= CONFIG.cache_limit then
      clear_cache()
    end
    CACHED_DIRS[dir_path] = true
    CACHE_DIR_COUNT = CACHE_DIR_COUNT + 1
  end

  for _, entry in ipairs(fs_entries) do
    if not STAT_CACHE[entry.path] then
      STAT_CACHE[entry.path] = vim.uv.fs_stat(entry.path)
    end
  end
end

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
  return os.date("%y-%m-%d %H:%M", time.sec)
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
  if not STATE.show_details then
    return mini_files.default_prefix(fs_entry)
  end

  local fs_stat = STAT_CACHE[fs_entry.path]
  -- Fallback: In case fs_stat is missing (due to cache clearance), fetch now
  local parent_dir = vim.fs.dirname(fs_entry.path)
  if not fs_stat and not LARGE_DIRS[parent_dir] then
    fs_stat = vim.uv.fs_stat(fs_entry.path)
    STAT_CACHE[fs_entry.path] = fs_stat
  end

  local prefix, hl = mini_files.default_prefix(fs_entry)

  local pre_prefix = "..."
  if not LARGE_DIRS[parent_dir] then
    pre_prefix = my_pre_prefix(fs_stat)
  end

  if pre_prefix == "" then
    return prefix, hl
  end
  return pre_prefix .. " " .. prefix, hl
end

local sorter = function(fs_entries, fs_accessor)
  table.sort(fs_entries, function(a, b)
    -- 1. Directories always come first and sorted by name
    if a.fs_type ~= b.fs_type then
      return a.fs_type == "directory"
    end
    if a.fs_type == "directory" then
      return a.name:lower() < b.name:lower()
    end
    -- 2. Files are sorted using the provided accessor
    local stat_a = STAT_CACHE[a.path]
    local stat_b = STAT_CACHE[b.path]

    local val_a = stat_a and fs_accessor(stat_a) or 0
    local val_b = stat_b and fs_accessor(stat_b) or 0
    return val_a > val_b
  end)
  return fs_entries
end

local custom_sort = function(fs_entries)
  if #fs_entries == 0 then
    return fs_entries
  end

  local dir_path = vim.fs.dirname(fs_entries[1].path)

  -- 1. Check if Active Directory
  local explorer = mini_files.get_explorer_state()
  local is_active = false
  if explorer then
    local focused_dir = explorer.branch[explorer.depth_focus]
    if dir_path == focused_dir then
      is_active = true
    end
  end

  -- 2. check if the dir too big
  if #fs_entries > CONFIG.sort_limit then
    -- if file_count > CONFIG.sort_limit then
    LARGE_DIRS[dir_path] = true

    if is_active and STATE.sort_mode ~= "name" then
      local now = vim.uv.now()
      if (now - STATE.last_warn_time) > CONFIG.sort_warning_cd then
        vim.notify(
          "Directory too large ("
            .. #fs_entries
            .. " > "
            .. CONFIG.sort_limit
            .. "). Sorting aborted.",
          vim.log.levels.WARN
        )
        STATE.last_warn_time = now
      end
    end

    return mini_files.default_sort(fs_entries)
  else
    LARGE_DIRS[dir_path] = nil
  end

  local mode_to_use = is_active and STATE.sort_mode or "name"

  if STATE.show_details or mode_to_use ~= "name" then
    ensure_stats(fs_entries)
  end

  -- 3. perform sorting
  if mode_to_use == "size" then
    return sorter(fs_entries, function(s)
      return s.size
    end)
  elseif mode_to_use == "date" then
    return sorter(fs_entries, function(s)
      return s.mtime.sec
    end)
  else
    return mini_files.default_sort(fs_entries)
  end
end

local toggle_details = function()
  STATE.show_details = not STATE.show_details
  local new_width = STATE.show_details and CONFIG.width_nofocus_detailed or CONFIG.width_nofocus
  mini_files.refresh({
    windows = { width_nofocus = new_width },
    content = { prefix = my_prefix },
  })
end

local toggle_dotfiles = function()
  STATE.show_dotfiles = not STATE.show_dotfiles
  local new_filter = function(fs_entry)
    return STATE.show_dotfiles or not vim.startswith(fs_entry.name, ".")
  end
  mini_files.refresh({ content = { filter = new_filter } })
end

local toggle_preview = function()
  STATE.show_preview = not STATE.show_preview
  mini_files.refresh({ windows = { preview = STATE.show_preview } })
end

local set_sort = function(mode)
  if STATE.sort_mode == mode then
    return
  end
  STATE.sort_mode = mode

  local msg = "Sort: Name (A-Z)"
  if mode == "size" then
    msg = "Sort: Size (Descending)"
  end
  if mode == "date" then
    msg = "Sort: Date (Newest)"
  end

  vim.notify(msg, vim.log.levels.INFO)
  mini_files.refresh({ content = { sort = custom_sort } })
end

local safe_synchronize = function()
  mini_files.synchronize()
  clear_cache()
  vim.notify("Synchronized & Cache Cleared", vim.log.levels.INFO)
end

local open_totalcmd = function()
  local entry = mini_files.get_fs_entry()
  if not entry then
    return
  end
  if not vim.g.total_cmd_exe then
    return vim.notify("Global 'total_cmd_exe' not set.", vim.log.levels.ERROR)
  end
  vim.cmd(string.format("!%s /O /T /L='%s'", vim.g.total_cmd_exe, entry.path))
  mini_files.close()
end

local open_file_externally = function()
  local entry = mini_files.get_fs_entry()
  if entry then
    vim.ui.open(entry.path)
    mini_files.close()
  end
end

local set_cwd = function()
  local entry = mini_files.get_fs_entry()
  if not entry then
    return
  end
  local cur_dir = entry.fs_type == "directory" and entry.path or vim.fs.dirname(entry.path)
  vim.fn.chdir(cur_dir)
  vim.notify("CWD set to: " .. cur_dir)
end

local yank_scp_command = function()
  local entry = mini_files.get_fs_entry()
  if not entry then
    return
  end
  local path = entry.path
  local hostname = vim.uv.os_gethostname()
  local short_host = hostname:match("_(.*)") or hostname
  short_host = short_host:match("^[^%.]+") or short_host
  local scp_cmd = string.format('scp -P 8080 %s.spaces:"%s" .', short_host, path)
  local b64 = vim.base64.encode(scp_cmd)
  local osc52 = string.format("\27]52;c;%s\7", b64)
  vim.uv.fs_write(1, osc52, -1)
  vim.notify("📋 Copied SCP command:\n" .. scp_cmd, vim.log.levels.INFO)
  mini_files.close()
end

local yank_latest_scp = function()
  clear_cache()
  if STATE.sort_mode ~= "date" then
    set_sort("date")
  else
    mini_files.refresh({ content = { sort = custom_sort } })
  end

  local n_lines = vim.api.nvim_buf_line_count(0)
  for i = 1, n_lines do
    local entry = mini_files.get_fs_entry(0, i)
    if entry and entry.fs_type == "file" then
      vim.api.nvim_win_set_cursor(0, { i, 0 })
      yank_scp_command()
      return
    end
  end

  vim.notify("No files found.", vim.log.levels.WARN)
end

local map_split = function(buf_id, lhs, direction, close)
  local rhs = function()
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
  vim.keymap.set("n", lhs, rhs, { buffer = buf_id, desc = "Split " .. direction })
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
    width_focus = CONFIG.width_focus,
    width_nofocus = CONFIG.width_nofocus_detailed,
    width_preview = CONFIG.width_preview,
  },
  content = { prefix = my_prefix, sort = custom_sort },
})

-- Navigation Wrappers
local go_in_reset = function()
  STATE.sort_mode = "name"
  mini_files.go_in()
end

local go_out_reset = function()
  STATE.sort_mode = "name"
  mini_files.go_out()
end

local go_in_plus_reset = function()
  STATE.sort_mode = "name"
  mini_files.go_in({ close_on_file = true })
end

vim.api.nvim_create_autocmd("User", {
  pattern = "MiniFilesWindowClose",
  callback = function()
    clear_cache()
  end,
})

vim.api.nvim_create_autocmd("User", {
  pattern = "MiniFilesBufferCreate",
  group = vim.api.nvim_create_augroup("mini-file-buffer", { clear = true }),
  callback = function(args)
    local b = args.data.buf_id
    local map = function(lhs, rhs, desc)
      vim.keymap.set("n", lhs, rhs, { buffer = b, desc = desc })
    end

    map("l", go_in_reset, "Go in (Reset Sort)")
    map("h", go_out_reset, "Go out (Reset Sort)")
    map("<CR>", go_in_plus_reset, "Go in plus (Reset Sort)")

    map("g.", toggle_dotfiles, "Toggle dot files")
    map("<a-h>", toggle_dotfiles, "Toggle dot files")
    map("gp", toggle_preview, "Toggle preview")

    map("g,", toggle_details, "Toggle file details")
    map("gz", function()
      set_sort("size")
    end, "Sort by Size")
    map("gm", function()
      set_sort("date")
    end, "Sort by Modified")
    map("ga", function()
      set_sort("name")
    end, "Sort by Name")

    map("=", safe_synchronize, "Synchronize & Clear Cache")
    map("gt", open_totalcmd, "Open in TotalCmd")
    map("gx", open_file_externally, "Open Externally")
    map("gy", yank_scp_command, "Copy SCP command")
    map("gY", yank_latest_scp, "Copy SCP command on latest file")
    map("g`", set_cwd, "Set CWD")
    map("<esc>", mini_files.close, "Close")

    map_split(b, "gs", "belowright horizontal", false)
    map_split(b, "gv", "belowright vertical", false)
    map_split(b, "<C-s>", "belowright horizontal", true)
    map_split(b, "<C-v>", "belowright vertical", true)
  end,
})

vim.keymap.set("n", "<leader>e", function()
  if not mini_files.close() then
    STATE.sort_mode = "name"
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
    ft = { "minifiles" },
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
