local telescope = require("telescope")
local builtin = require("telescope.builtin")
local telescopeConfig = require("telescope.config")
local vimgrep_arguments = { unpack(telescopeConfig.values.vimgrep_arguments) }
local actions = require("telescope.actions")

vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "find_file" })
vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "live_grep" })
vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "find_buffers" })
vim.keymap.set("n", "<leader>fk", builtin.keymaps, { desc = "find_keymaps" })
-- vim.keymap.set("n", "<leader>fg", builtin.git_commits, { desc = "git_commits" })
-- vim.keymap.set("n", "<leader>ss", builtin.spell_suggest, { desc = "spell_suggest" })
-- vim.keymap.set('n', '<leader>cc', builtin.commands, {})
vim.keymap.set("n", '<leader>"', builtin.registers, {})
vim.keymap.set("n", "<leader>`", builtin.marks, {})
vim.keymap.set("n", "<leader>fo", builtin.oldfiles, { desc = "old_files" })
vim.keymap.set("n", "<leader>fw", builtin.grep_string, { desc = "grep_string" })
vim.keymap.set("n", "<leader>fd", builtin.diagnostics, { desc = "lsp_diagnostics" })

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
  },
})
-- -- To get fzf loaded and working with telescope, you need to call
-- -- load_extension, somewhere after setup function:
telescope.load_extension("fzf")

require("oil").setup({
  -- See :help oil-columns
  columns = {
    "icon",
    -- "permissions",
    "size",
    "mtime",
  },
  -- Skip the confirmation popup for simple operations (:help oil.skip_confirm_for_simple_edits)
  skip_confirm_for_simple_edits = true,
  -- See :help oil-actions for a list of all available actions
  keymaps = {
    ["g?"] = "actions.show_help",
    ["<CR>"] = "actions.select",
    ["<C-v>"] = "actions.select_vsplit",
    ["<C-x>"] = "actions.select_split",
    ["<C-t>"] = "actions.select_tab",
    ["<C-p>"] = "actions.preview",
    ["<C-c>"] = "actions.close",
    ["<C-l>"] = "actions.refresh",
    ["-"] = "actions.parent",
    ["_"] = "actions.open_cwd",
    ["`"] = "actions.cd",
    ["~"] = "actions.tcd",
    ["gs"] = "actions.change_sort",
    ["gx"] = "actions.open_external",
    ["g."] = "actions.toggle_hidden",
    ["g\\"] = "actions.toggle_trash",
  },
  -- Set to false to disable all of the above keymaps
  use_default_keymaps = false,
})
vim.keymap.set("n", "<Leader>-", "<CMD>Oil<CR>", { desc = "Open parent directory" })

require("marks").setup({
  -- which builtin marks to show. default {}
  builtin_marks = {},
  -- builtin_marks = { ".", "<", ">", "^" },
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
vim.keymap.del("i", "jk")
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
  },
  autosave_ignore_buftypes = {
    "terminal",
  }, -- All buffers of these bufer types will be closed before the session is saved.
  autosave_only_in_session = false, -- Always autosaves session. If true, only autosaves after a session is active.
  max_path_length = 60, -- Shorten the display path if length exceeds this threshold. Use 0 if don't want to shorten the path at all.
})
vim.keymap.set("n", "<leader>sm", "<cmd>SessionManager<cr>", { desc = "find_session" })
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
