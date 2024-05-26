local leap = require('leap')
leap.opts.case_sensitive = true
leap.set_default_keymaps()
-- vim.keymap.set('o', 's', '<Plug>(leap-forward)')
-- vim.keymap.set('o', 'S', '<Plug>(leap-backward)')
if vim.g.vscode then
    vim.keymap.del('x', 'ma')
    vim.keymap.del('x', 'mi')
    vim.keymap.del('x', 'mA')
    vim.keymap.del('x', 'mI')
end

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
vim.keymap.set('n', '<leader>fm', builtin.marks, {})
vim.keymap.set("n", "<leader>fo", builtin.oldfiles, {})
vim.keymap.set("n", "<leader>fw", builtin.grep_string, {})
 vim.keymap.set("n", "<leader>/", function()
      -- You can pass additional configuration to telescope to change theme, layout, etc.
      require("telescope.builtin").current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
        winblend = 10,
        previewer = false,
        layout_config = { width = 0.7 },
      }))
    end, { desc = "[/] Fuzzily search in current buffer" })

-- You dont need to set any of these options. These are the default ones. Only
-- the loading is important
local telescope = require("telescope")
local telescopeConfig = require("telescope.config")
-- Clone the default Telescope configuration
local vimgrep_arguments = { unpack(telescopeConfig.values.vimgrep_arguments) }
local actions = require("telescope.actions")

telescope.setup {
 defaults = {
        -- `hidden = true` is not supported in text grep commands.
        vimgrep_arguments = vimgrep_arguments,
        path_display = { "truncate" },
        mappings = {
          n = {
            ["<C-w>"] = actions.send_selected_to_qflist + actions.open_qflist,
          },
          i = {
            ["<C-j>"] = actions.cycle_history_next,
            ["<C-k>"] = actions.cycle_history_prev,
            ["<CR>"] = select_one_or_multi,
            ["<C-w>"] = actions.send_selected_to_qflist + actions.open_qflist,
            ["<C-S-d>"] = actions.delete_buffer,
            ["<C-s>"] = actions.cycle_previewers_next,
            ["<C-a>"] = actions.cycle_previewers_prev,
          },
        },
      },
      pickers = {
        find_files = {
          -- `hidden = true` will still show the inside of `.git/` as it's not `.gitignore`d.
          find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*" },
        },
      },
  extensions = {
    fzf = {
      fuzzy = true,                    -- false will only do exact matching
      override_generic_sorter = true,  -- override the generic sorter
      override_file_sorter = true,     -- override the file sorter
      case_mode = "smart_case",        -- or "ignore_case" or "respect_case"
                                       -- the default case_mode is "smart_case"
    }
  }
}
-- -- To get fzf loaded and working with telescope, you need to call
-- -- load_extension, somewhere after setup function:
require('telescope').load_extension('fzf')
