local telescope = require("telescope")
local builtin = require("telescope.builtin")
local telescopeConfig = require("telescope.config")
local vimgrep_arguments = { unpack(telescopeConfig.values.vimgrep_arguments) }
local actions = require("telescope.actions")

vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "find_file" })
vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "live_grep" })
vim.keymap.set("n", "<leader><leader>", builtin.buffers, { desc = "find_buffers" })
vim.keymap.set("n", "<leader>fk", builtin.keymaps, { desc = "find_keymaps" })
-- vim.keymap.set("n", "<leader>fg", builtin.git_commits, { desc = "git_commits" })
-- vim.keymap.set("n", "<leader>ss", builtin.spell_suggest, { desc = "spell_suggest" })
-- vim.keymap.set('n', '<leader>cc', builtin.commands, {})
vim.keymap.set("n", '<leader>"', builtin.registers, {})
vim.keymap.set("n", "<leader>`", builtin.marks, {})
vim.keymap.set("n", "<leader>fo", builtin.oldfiles, { desc = "old_files" })
vim.keymap.set("n", "<leader>fw", builtin.grep_string, { desc = "grep_string" })
vim.keymap.set("n", "<leader>fd", builtin.diagnostics, { desc = "lsp_diagnostics" })
vim.keymap.set("n", "<leader>fu", "<cmd>Telescope undo<cr>", { desc = "lsp_diagnostics" })

-- You dont need to set any of these options. These are the default ones. Only
-- the loading is important
-- Clone the default Telescope configuration

telescope.setup({
  defaults = {
    -- `hidden = true` is not supported in text grep commands.
    vimgrep_arguments = vimgrep_arguments,
    path_display = { "truncate" },
    mappings = {
      n = {
        ["/"] = "which_key",
        ["w"] = actions.send_selected_to_qflist + actions.open_qflist,
        ["d"] = actions.delete_buffer + actions.move_to_top,
      },
      i = {
        ["<C-j>"] = actions.cycle_history_next,
        ["<C-k>"] = actions.cycle_history_prev,
        ["<CR>"] = select_one_or_multi,
        ["<C-w>"] = actions.send_selected_to_qflist + actions.open_qflist,
        ["<del>"] = actions.delete_buffer + actions.move_to_top,
      },
    },
  },
  pickers = {
    find_files = {
      -- `hidden = true` will still show the inside of `.git/` as it's not `.gitignore`d.
      find_command = {
        "rg",
        "--files",
        "--hidden",
        "--glob",
        "!**/.git/*",
      },
    },
  },
  extensions = {
    fzf = {
      fuzzy = true, -- false will only do exact matching
      override_generic_sorter = true, -- override the generic sorter
      override_file_sorter = true, -- override the file sorter
      case_mode = "smart_case", -- or "ignore_case" or "respect_case"
      -- the default case_mode is "smart_case"
    },
    undo = {
      use_delta = false,
      side_by_side = false,
      layout_strategy = "vertical",
      layout_config = {
        preview_height = 0.7,
      },
    },
  },
})
-- -- To get fzf loaded and working with telescope, you need to call
-- -- load_extension, somewhere after setup function:
telescope.load_extension("fzf")
telescope.load_extension("undo")

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

local gio_open = function()
  local fs_entry = require("mini.files").get_fs_entry()
  vim.notify(vim.inspect(fs_entry))
  vim.fn.system(string.format("gio open '%s'", fs_entry.path))
end

local toggle_dotfiles = function()
  show_dotfiles = not show_dotfiles
  local new_filter = show_dotfiles and filter_show or filter_hide
  require("mini.files").refresh({ content = { filter = new_filter } })
end

local open_totalcmd = function(path)
  local cur_entry_path = MiniFiles.get_fs_entry().path
  -- local cur_directory = vim.fs.dirname(cur_entry_path)
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
  callback = function(args)
    local buf_id = args.data.buf_id
    -- Tweak left-hand side of mapping to your liking
    vim.keymap.set("n", "g.", toggle_dotfiles, { buffer = buf_id, desc = "Toggle dot file" })
    vim.keymap.set("n", "gt", open_totalcmd, { buffer = buf_id, desc = "Open in TotalCmd" })
    vim.keymap.set("n", "gx", open_file, { buffer = buf_id, desc = "Open Externally" })
    vim.keymap.set("n", "g`", files_set_cwd, { buffer = args.data.buf_id, desc = "Set dir" })
    vim.keymap.set(
      "n",
      "<esc>",
      require("mini.files").close,
      { buffer = buf_id, desc = "Close (alt.)" }
    )
    map_split(buf_id, "gs", "belowright horizontal")
    map_split(buf_id, "gv", "belowright vertical")
  end,
})

require("marks").setup({
  -- which builtin marks to show. default {}
  builtin_marks = {},
  default_mappings = false,
  mappings = {
    set = "m",
    toggle = "mm",
    next = "mj",
    prev = "mk",
    delete_buf = "dmm",
  },
})

-- delete jk binding in vim mode
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

local Path = require("plenary.path")
local config = require("session_manager.config")
require("session_manager").setup({
  autoload_mode = {
    config.AutoloadMode.CurrentDir,
    config.AutoloadMode.GitSession,
    config.AutoloadMode.Disabled,
    -- config.AutoloadMode.LastSession,
  }, -- Define what to do when Neovim is started without arguments.
  autosave_ignore_filetypes = { -- All buffers of these file types will be closed before the session is saved.
    "gitcommit",
    "gitrebase",
    "toggleterm",
    "minifiles",
  },
  autosave_ignore_buftypes = {
    "terminal",
  }, -- All buffers of these bufer types will be closed before the session is saved.
  autosave_only_in_session = false, -- Always autosaves session. If true, only autosaves after a session is active.
  max_path_length = 60, -- Shorten the display path if length exceeds this threshold. Use 0 if don't want to shorten the path at all.
})
vim.keymap.set("n", "<leader>fs", "<cmd>SessionManager<cr>", { desc = "find_session" })
-- Auto save session
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  callback = function()
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      -- Don't save while there's any 'nofile' buffer open.
      if vim.api.nvim_get_option_value("buftype", { buf = buf }) == "nofile" then
        return
      end
    end
    session_manager.save_current_session()
  end,
})

require("mini.bufremove").setup()

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "vimwiki" },
  callback = function(args)
    require("render-markdown").setup({
      file_types = { "markdown", "vimwiki" },
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
    vim.keymap.set(
      "n",
      "<F5>",
      "<cmd>RenderMarkdown toggle<cr>",
      { buffer = args.buf, desc = "Render Markdown" }
    )
  end,
})
