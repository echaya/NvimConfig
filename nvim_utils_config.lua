local telescope = require("telescope")
local builtin = require("telescope.builtin")
local telescopeConfig = require("telescope.config")
local vimgrep_arguments = { unpack(telescopeConfig.values.vimgrep_arguments) }
local actions = require("telescope.actions")

my_find_files = function(opts, no_ignore)
  opts = opts or {}
  no_ignore = vim.F.if_nil(no_ignore, false)
  opts.attach_mappings = function(_, map)
    map({ "n", "i" }, "<C-h>", function(prompt_bufnr) -- <C-h> to toggle modes
      local prompt = require("telescope.actions.state").get_current_line()
      require("telescope.actions").close(prompt_bufnr)
      no_ignore = not no_ignore
      my_find_files({ default_text = prompt }, no_ignore)
    end, { desc = "toggle_hidden_n_gitignore" })
    return true
  end

  if no_ignore then
    opts.no_ignore = true
    opts.hidden = true
    opts.prompt_title = "Find Files <ALL>"
    require("telescope.builtin").find_files(opts)
  else
    opts.prompt_title = "Find Files"
    require("telescope.builtin").find_files(opts)
  end
end

local select_one_or_multi = function(prompt_bufnr)
  local picker = require("telescope.actions.state").get_current_picker(prompt_bufnr)
  local multi = picker:get_multi_selection()
  if not vim.tbl_isempty(multi) then
    require("telescope.actions").close(prompt_bufnr)
    for _, j in pairs(multi) do
      if j.path ~= nil then
        vim.cmd(string.format("%s %s", "edit", j.path))
      end
    end
  else
    require("telescope.actions").select_default(prompt_bufnr)
  end
end

vim.keymap.set("n", "<leader>ff", my_find_files, { desc = "find_file" })
vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "find_buffers" })
vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "find_help" })
vim.keymap.set("n", "<leader>fp", function()
  builtin.find_files({ cwd = vim.fs.joinpath(vim.fn.stdpath("data"), "site") })
end, { desc = "find_plugin" })
vim.keymap.set("n", "<leader><leader>", function()
  require("telescope").extensions.smart_open.smart_open()
end, { desc = "smart_open" })
vim.keymap.set("n", "<leader>fk", builtin.keymaps, { desc = "find_keymaps" })
vim.keymap.set("n", "<leader>fo", builtin.oldfiles, { desc = "old_files" })
vim.keymap.set("n", "<leader>fd", builtin.diagnostics, { desc = "lsp_diagnostics" })
vim.keymap.set("n", "<leader>fu", "<cmd>Telescope undo<cr>", { desc = "undo_history" })
vim.keymap.set("n", '<leader>"', builtin.registers, { desc = "registers" })
vim.keymap.set("n", "<leader>`", builtin.marks, { desc = "marks" })
vim.keymap.set("n", "<leader>gg", builtin.live_grep, { desc = "live_grep" })
vim.keymap.set("n", "<leader>gw", builtin.grep_string, { desc = "grep_string" })

telescope.setup({
  defaults = {
    preview = { filesize_limit = 1.0 }, -- MB,
    -- `hidden = true` is not supported in text grep commands.
    vimgrep_arguments = vimgrep_arguments,
    path_display = { "truncate" },
    mappings = {
      i = {
        ["<C-n>"] = actions.cycle_history_next,
        ["<C-p>"] = actions.cycle_history_prev,
        ["<C-k>"] = actions.move_selection_previous,
        ["<C-j>"] = actions.move_selection_next,
        -- C-v to select and split vertically
        ["<C-x>"] = false,
        ["<C-s>"] = actions.select_horizontal,
        ["<CR>"] = select_one_or_multi,
        ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
        ["<del>"] = actions.delete_buffer + actions.move_to_top,
        ["<esc>"] = actions.close,
      },
    },
  },
  pickers = {
    find_files = {
      -- `hidden = true` will still show the inside of `.git/` as it's not `.gitignore`d.
      find_command = {
        "rg",
        "--files",
        "--glob",
        "!**/.git/*",
        -- "--hidden",
      },
    },
  },
  extensions = {
    fzf = {
      fuzzy = true, -- false will only do exact matching
      override_generic_sorter = true, -- override the generic sorter
      override_file_sorter = true, -- override the file sorter
      case_mode = "smart_case", -- or "ignore_case" or "respect_case", default "smart_case"
    },
    undo = {
      use_delta = true,
      side_by_side = false,
      layout_strategy = "vertical",
      layout_config = {
        preview_height = 0.7,
      },
    },
    smart_open = {
      match_algorithm = "fzf",
      result_limit = 40,
    },
  },
})
-- -- To get fzf loaded and working with telescope, you need to call
-- -- load_extension, somewhere after setup function:
telescope.load_extension("fzf")
telescope.load_extension("undo")
telescope.load_extension("smart_open")
local format_size = function(size)
  if size == nil then
    return
  end
  if size < 1024 then
    return string.format("%3dB", size)
  elseif size < 1048576 then
    return string.format("%3.0fK", size / 1024)
  else
    return string.format("%3.0fM", size / 1048576)
  end
end
local format_time_handling = function(time)
  local format_time = function(time)
    ret = vim.fn.strftime("%y-%m-%d %H:%M", time.sec)
    return ret
  end
  success, rtn = pcall(format_time, time)
  if success then
    return rtn
  else
    return " "
  end
end
local my_prefix = function(fs_entry)
  local prefix, hl = MiniFiles.default_prefix(fs_entry)
  local fs_stat = vim.loop.fs_stat(fs_entry.path) or {}
  return format_time_handling(fs_stat.mtime) .. " " .. format_size(fs_stat.size) .. " " .. prefix,
    hl
end
require("mini.files").setup({

  -- Use `''` (empty string) to not create one.
  mappings = {
    go_in_plus = "<CR>",
    trim_left = ">",
    trim_right = "<",
  },

  -- General options
  options = {
    -- Whether to delete permanently or move into module-specific trash
    permanent_delete = false,
    -- Whether to use for editing directories
    use_as_default_explorer = true,
  },

  -- Customization of explorer windows
  windows = {
    -- Maximum number of windows to show side by side
    max_number = math.huge,
    -- Whether to show preview of file/directory under cursor
    preview = true,
    -- Width of focused window
    width_focus = 50,
    -- Width of non-focused window
    width_nofocus = 15,
    -- Width of preview window
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

local filter_show = function(fs_entry)
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

local open_totalcmd = function(path)
  local cur_entry_path = MiniFiles.get_fs_entry().path
  -- local cur_directory = vim.fs.dirname(cur_entry_path)
  -- vim.fn.system(string.format("gio open '%s'", cur_entry_path))
  vim.api.nvim_command(string.format("!%s /O /T /L='%s'", vim.g.total_cmd_exe, cur_entry_path))
  MiniFiles.close()
end

local open_file = function(path)
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

local files_set_cwd = function(path)
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
    vim.keymap.set("n", "g.", toggle_dotfiles, { buffer = buf_id, desc = "Toggle dot file" })
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
    i = {
      j = {
        k = "<Esc>",
      },
    },
    c = {
      j = {
        k = "<Esc>",
      },
    },
    t = {
      j = {
        k = "<C-\\><C-n>",
      },
      ["\\"] = {
        ["\\"] = function()
          vim.schedule(function()
            vim.cmd("q")
          end)
        end,
      },
    },
    v = {
      j = {
        k = "<Esc>",
      },
    },
    s = {
      j = {
        k = "<Esc>",
      },
    },
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
      file_type = vim.api.nvim_buf_get_option(buf, "filetype")
      if vim.tbl_contains(disabled_filetype, file_type) and vim.g.auto_save == 1 then
        vim.notify("vim.g.auto_save = 0 (OFF)", "warn", { title = "AutoSave" })
        vim.g.auto_save = 0
        return
      elseif vim.tbl_contains(disabled_filetype, file_type) and vim.g.auto_save == 0 then
        return
      end
    end
    if vim.g.auto_save == 0 then
      vim.notify("vim.g.auto_save = 1 (ON)", "info", { title = "AutoSave" })
      vim.g.auto_save = 1
    end
  end,
})

local mini_misc = require("mini.misc")
mini_misc.setup()
mini_misc.setup_auto_root()
mini_misc.setup_restore_cursor()
