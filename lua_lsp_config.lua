local custom_attach = function(client)
    vim.keymap.set('n','gD','<cmd>lua vim.lsp.buf.declaration()<CR>')
    vim.keymap.set('n','gd','<cmd>lua vim.lsp.buf.definition()<CR>')
    vim.keymap.set('n','gh','<cmd>lua vim.lsp.buf.hover()<CR>')
    vim.keymap.set('n','gr','<cmd>lua vim.lsp.buf.references()<CR>')
    vim.keymap.set('n','gs','<cmd>lua vim.lsp.buf.signature_help()<CR>')
    vim.keymap.set('n','gi','<cmd>lua vim.lsp.buf.implementation()<CR>')
    vim.keymap.set('n','gt','<cmd>lua vim.lsp.buf.type_definition()<CR>')
    vim.keymap.set('n','<leader>gw','<cmd>lua vim.lsp.buf.document_symbol()<CR>')
    vim.keymap.set('n','<leader>gW','<cmd>lua vim.lsp.buf.workspace_symbol()<CR>')
    vim.keymap.set('n','<leader>ah','<cmd>lua vim.lsp.buf.hover()<CR>')
    vim.keymap.set('n','<leader>af','<cmd>lua vim.lsp.buf.code_action()<CR>')
    vim.keymap.set('n','<leader>ee','<cmd>lua vim.lsp.util.show_line_diagnostics()<CR>')
    vim.keymap.set('n','<leader>ar','<cmd>lua vim.lsp.buf.rename()<CR>')
    vim.keymap.set('n','<leader>=', '<cmd>lua vim.lsp.buf.formatting()<CR>')
    vim.keymap.set('n','<leader>ai','<cmd>lua vim.lsp.buf.incoming_calls()<CR>')
    vim.keymap.set('n','<leader>ao','<cmd>lua vim.lsp.buf.outgoing_calls(){CR}')
end

local lsp = require('lspconfig')
lsp.pyright.setup{
    on_attach = custom_attach,
    settings = {
        psthon = {
            analysis = {
                useLibraryCodeForTypes = true,
                diagnosticSeverityOverrides = {
                    reportUnusedVariable = "warning", -- or anything
                },
                typeCheckingMode = "off",
            },
        },
    }
}


-- local iron = require("iron.core")

-- iron.setup {
--   config = {
--     -- Whether a repl should be discarded or not
--     scratch_repl = true,
--     -- Your repl definitions come here
--     repl_definition = {
--         python = require("iron.fts.python").ipython,
--       sh = {
--         -- Can be a table or a function that
--         -- returns a table (see below)
--         command = {"zsh"}
--       }
--     },
--     -- How the repl window will be displayed
--     -- See below for more information
--     repl_open_cmd = require('iron.view').split.vertical.botright("40%")
--   },
--   -- Iron doesn't set keymaps by default anymore.
--   -- You can set them here or manually add keymaps to the functions in iron.core
--   keymaps = {
--     send_motion = "<Leader>sc",
--     visual_send = "<Leader>sc",
--     send_file = "<Leader>sf",
--     send_line = "<Leader>sl",
--     send_paragraph = "<Leader>sp",
--     send_until_cursor = "<Leader>su",
--     send_mark = "<Leader>sm",
--     mark_motion = "<Leader>mc",
--     mark_visual = "<Leader>mc",
--     remove_mark = "<Leader>md",
--     cr = "<Leader>s<cr>",
--     interrupt = "<Leader>s<Leader>",
--     exit = "<Leader>sq",
--     clear = "<Leader>cl",
--   },
--   -- If the highlight is on, you can change how it looks
--   -- For the available options, check nvim_set_hl
--   highlight = {
--     italic = true
--   },
--   ignore_blank_lines = true, -- ignore blank lines when sending visual select lines
-- }

-- -- iron also has a list of commands, see :h iron-commands for all available commands
-- vim.keymap.set('n', '<Leader>rs', '<cmd>IronRepl<cr>')
-- vim.keymap.set('n', '<Leader>rr', '<cmd>IronRestart<cr>')
-- vim.keymap.set('n', '<Leader>rf', '<cmd>IronFocus<cr>')
-- vim.keymap.set('n', '<Leader>rh', '<cmd>IronHide<cr>')

