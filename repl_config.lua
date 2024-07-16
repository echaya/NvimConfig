
local iron = require("iron.core")

iron.setup {
  config = {

    -- Scope of the repl
    -- By default it is one for the same `pwd`
    -- Other options are `tab_based` and `singleton`
    scope = require("iron.scope").path_based,
    -- Whether a repl should be discarded or not
    scratch_repl = true,
    -- Your repl definitions come here
    repl_definition = {
        python = {
            format = require("iron.fts.common").bracketed_paste,
            command = { "ipython", "--no-autoindent" },
},
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
    -- send_line = "<Leader>sl",
    visual_send = "<CR>",
    send_until_cursor = "<Leader>su",
    -- send_file = "<Leader>sf",
    -- send_mark = "<Leader>sm",
    -- mark_motion = "<Leader>mc",
    -- mark_visual = "<Leader>mc",
    -- remove_mark = "<Leader>md",
    cr = "<C-CR>",
    interrupt = "<C-I>",
    exit = "<Leader>rq",
    -- clear = "<Leader>cl",
  },
  -- If the highlight is on, you can change how it looks
  -- For the available options, check nvim_set_hl
  highlight = {
    italic = true
  },
  ignore_blank_lines = true, -- ignore blank lines when sending visual select lines
}

-- iron also has a list of commands, see :h iron-commands for all commands, handled in python.vimrc
-- vim.keymap.set('n', '<Leader>rr', '<cmd>IronRepl<cr>',{silence=True})
-- vim.keymap.set('n', '<Leader>rd', '<cmd>IronRestart<cr>',{silence=True})
-- vim.keymap.set('n', '<Leader>rh', '<cmd>IronHide<cr>')
-- vim.keymap.set('n', '<Leader>rf', '<cmd>IronFocus<cr>')


require("conform").setup({
  formatters_by_ft = {
    lua = { "stylua" },
    -- Conform will run multiple formatters sequentially
    python = { "isort", "black" },
    -- Use a sub-list to run only the first available formatter
    -- javascript = { { "prettierd", "prettier" } },
  },
})

vim.api.nvim_create_user_command("Format", function(args)
  local range = nil
  if args.count ~= -1 then
    local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
    range = {
      start = { args.line1, 0 },
      ["end"] = { args.line2, end_line:len() },
    }
  end
  require("conform").format({ async = true, lsp_format = "fallback", range = range })
end, { range = true })
-- async black call
vim.keymap.set('n', '==', '<cmd>Format<cr>')
-- sync black call
vim.keymap.set('n', '<leader>==', ':!black %<cr>')

