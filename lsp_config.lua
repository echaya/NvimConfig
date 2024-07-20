-- Set up nvim-cmp.
local cmp = require("cmp")
local luasnip = require("luasnip")

cmp.setup({
    snippet = {
        -- REQUIRED - you must specify a snippet engine
        expand = function(args)
            -- vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
            require("luasnip").lsp_expand(args.body) -- For `luasnip` users.
            -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
            -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
            -- vim.snippet.expand(args.body) -- For native neovim snippets (Neovim v0.10+)
        end,
    },
    window = {
        -- completion = cmp.config.window.bordered(),
        -- documentation = cmp.config.window.bordered(),
    },
    mapping = cmp.mapping.preset.insert({
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping.abort(),
        -- ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
        ["<CR>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                if luasnip.expandable() then
                    luasnip.expand()
                else
                    cmp.confirm({
                        select = true,
                    })
                end
            else
                fallback()
            end
        end),

        ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            elseif luasnip.locally_jumpable(1) then
                luasnip.jump(1)
            else
                fallback()
            end
        end, { "i", "s" }),

        ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            elseif luasnip.locally_jumpable(-1) then
                luasnip.jump(-1)
            else
                fallback()
            end
        end, { "i", "s" }),
    }),

    sources = cmp.config.sources({
        { name = "nvim_lsp" },
        -- { name = 'vsnip' }, -- For vsnip users.
        { name = "luasnip" }, -- For luasnip users.
        -- { name = 'ultisnips' }, -- For ultisnips users.
        -- { name = 'snippy' }, -- For snippy users.
    }, {
        { name = "buffer" },
    }, {
        { name = "path" },
    }),
})

-- To use git you need to install the plugin petertriho/cmp-git and uncomment lines below
-- Set configuration for specific filetype.
--[[ cmp.setup.filetype('gitcommit', {
    sources = cmp.config.sources({
        { name = 'git' },
    }, {
        { name = 'buffer' },
    })
})
require("cmp_git").setup() ]]
--

-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline({ "/", "?" }, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
        { name = "buffer" },
    },
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(":", {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
        { name = "path" },
    }, {
        { name = "cmdline" },
    }),
    matching = { disallow_symbol_nonprefix_matching = false },
})

-- Set up lspconfig.
-- local capabilities = require('cmp_nvim_lsp').default_capabilities()
-- -- Replace <YOUR_LSP_SERVER> with each lsp server you've enabled.
-- require('lspconfig')['<YOUR_LSP_SERVER>'].setup {
    -- capabilities = capabilities
    -- }

    -- Setup luasnip
    require("luasnip.loaders.from_vscode").lazy_load()
    require("luasnip").filetype_extend("vimwiki", { "markdown" })
    -- require("luasnip.loaders.from_vscode").load({ include = {"markdown","md"} })
    -- vim.keymap.set({"i"}, "<CR>", function() ls.expand() end, {silent = true})
    luasnip.config.set_config({
        region_check_events = "InsertEnter",
        delete_check_events = "InsertLeave",
    })

    -- Setup Autocomplete

    require("nvim-autopairs").setup({
        map_cr = true,
        map_complete = true,
        auto_select = true,
    })
    local cmp_autopairs = require("nvim-autopairs.completion.cmp")
    cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())

    local custom_attach = function(client)
        -- vim.keymap.set('n','gD','<cmd>lua vim.lsp.buf.declaration()<CR>')
        vim.keymap.set("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>")
        vim.keymap.set("n", "gD", ":vsplit | lua vim.lsp.buf.definition()<CR>")
        vim.keymap.set("n", "gh", "<cmd>lua vim.lsp.buf.hover()<CR>")
        -- vim.keymap.set('n','gr','<cmd>lua vim.lsp.buf.references()<CR>')
        vim.keymap.set("n", "gr", require("telescope.builtin").lsp_references, {})
        -- vim.keymap.set('n','gs','<cmd>lua vim.lsp.buf.signature_help()<CR>')
        -- vim.keymap.set('n','gi','<cmd>lua vim.lsp.buf.implementation()<CR>')
        -- vim.keymap.set('n','gt','<cmd>lua vim.lsp.buf.type_definition()<CR>')
        -- vim.keymap.set('n','<leader>gw','<cmd>lua vim.lsp.buf.document_symbol()<CR>')
        -- vim.keymap.set('n','<leader>gW','<cmd>lua vim.lsp.buf.workspace_symbol()<CR>')
        -- vim.keymap.set('n','<leader>af','<cmd>lua vim.lsp.buf.code_action()<CR>')
        vim.keymap.set("n", "<F2>", "<cmd>lua vim.lsp.buf.rename()<CR>")
        vim.keymap.set("n", "<F3>", "<cmd>lua vim.diagnostic.open_float()<CR>")
        -- vim.keymap.set('n','<leader>=', '<cmd>lua vim.lsp.buf.formatting()<CR>')
        -- vim.keymap.set('n','<leader>ai','<cmd>lua vim.lsp.buf.incoming_calls()<CR>')
    end

    local lsp = require("lspconfig")
    lsp.basedpyright.setup({
        on_attach = custom_attach,
        capabilities = capabilities,
        settings = {
            basedpyright = {
                analysis = {
                    useLibraryCodeForTypes = true,
                    diagnosticMode = "openFilesOnly",
                    typeCheckingMode = "basic",
                    diagnosticSeverityOverrides = {
                        reportUnusedVariable = "information", -- or anything
                        reportUnusedFunction = "information",
                        reportDuplicateImport = "warning",
                        reportAttributeAccessIssue = "none",
                        reportOptionalSubscript = "none",
                        reportOptionalMemberAccess = "none",
                        reportArgumentType = "none",
                        reportAssignmentType = "information",
                        reportPossiblyUnboundVariable = "information",
                        reportIndexIssue = "none",
                        reportCallIssue = "information",
                        reportRedeclaration = "information",
                        reportOperatorIssue = "information",
                        reportOptionalOperand = "information",
                        reportGeneralTypeIssues = "none",
                    },
                },
            },
        },
    })

    vim.diagnostic.config({
        virtual_text = false,
        signs = true,
        float = {
            border = "single",
            format = function(diagnostic)
                return string.format(
                "%s (%s) [%s]",
                diagnostic.message,
                diagnostic.source,
                diagnostic.code or diagnostic.user_data.lsp.code
                )
            end,
        },
    })

    -- NOTE mason files in nvim-data folder
    require("mason").setup()
    require("mason-lspconfig").setup()

    -- After setting up mason-lspconfig you may set up servers via lspconfig
    local lspconfig = require('lspconfig')
    lspconfig.lua_ls.setup {
        settings = {
            Lua = {
                runtime = {
                    -- Tell the language server which version of Lua you're using
                    -- (most likely LuaJIT in the case of Neovim)
                    version = 'LuaJIT',
                },
                diagnostics = {
                    -- Get the language server to recognize the `vim` global
                    globals = {
                        'vim',
                        'require'
                    },
                },
                workspace = {
                    -- Make the server aware of Neovim runtime files
                    library = vim.api.nvim_get_runtime_file("", true),
                },
                -- Do not send telemetry data containing a randomized but unique identifier
                telemetry = {
                    enable = false,
                },
            },
        },
    }
