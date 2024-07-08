
local iron = require("iron.core")

iron.setup {
  config = {
    -- Whether a repl should be discarded or not
    scratch_repl = true,
    -- Your repl definitions come here
    repl_definition = {
        python = require("iron.fts.python").ipython,
      sh = {
        -- Can be a table or a function that
        -- returns a table (see below)
        command = {"zsh"}
      }
    },
    -- How the repl window will be displayed
    -- See below for more information
    repl_open_cmd = require('iron.view').split.vertical.botright("40%")
  },
  -- Iron doesn't set keymaps by default anymore.
  -- You can set them here or manually add keymaps to the functions in iron.core
  keymaps = {
    send_motion = "<Leader>sm",
    visual_send = "<S-Cr>",
    send_file = "<Leader>sf",
    send_line = "<Leader>sl",
    send_until_cursor = "<Leader>su",
    send_mark = "<Leader>sm",
    mark_motion = "<Leader>mc",
    mark_visual = "<Leader>mc",
    remove_mark = "<Leader>md",
    cr = "<Leader>s<cr>",
    interrupt = "<Leader>s<Leader>",
    exit = "<Leader>sq",
    clear = "<Leader>cl",
  },
  -- If the highlight is on, you can change how it looks
  -- For the available options, check nvim_set_hl
  highlight = {
    italic = true
  },
  ignore_blank_lines = true, -- ignore blank lines when sending visual select lines
}

-- iron also has a list of commands, see :h iron-commands for all available commands
vim.keymap.set('n', '<Leader>rs', '<cmd>IronRepl<cr>')
vim.keymap.set('n', '<Leader>rr', '<cmd>IronRestart<cr>')
vim.keymap.set('n', '<Leader>rf', '<cmd>IronFocus<cr>')
vim.keymap.set('n', '<Leader>rh', '<cmd>IronHide<cr>')

