-- Setup treesitter
require("nvim-treesitter.configs").setup({
  -- A list of parser names, or "all" (the listed parsers MUST always be installed)
  ensure_installed = {
    "lua",
    "markdown",
    "markdown_inline",
    "python",
    "query",
    "vim",
    "vimdoc",
    "bash",
    "regex",
  },
  sync_install = false,
  auto_install = false,
  ignore_install = { "javascript" },
  highlight = {
    enable = true,
    disable = function(_, buf)
      local max_filesize = 1024 * 1024 -- 100 KB
      local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
      if ok and stats and stats.size > max_filesize then
        return true
      end
    end,
    additional_vim_regex_highlighting = false,
  },
})
vim.treesitter.language.register("markdown", "vimwiki")

-- Lua configuration
local glance = require("glance")
local actions = glance.actions

glance.setup({
  height = 25, -- Height of the window
  zindex = 45,

  border = {
    enable = true, -- Show window borders. Only horizontal borders allowed
    top_char = "─",
    bottom_char = "─",
  },

  mappings = {
    list = {
      ["j"] = actions.next, -- Bring the cursor to the next item in the list
      ["k"] = actions.previous, -- Bring the cursor to the previous item in the list
      ["<Tab>"] = actions.next_location, -- Bring the cursor to the next location skipping groups in the list
      ["<S-Tab>"] = actions.previous_location, -- Bring the cursor to the previous location skipping groups in the list
      ["<C-u>"] = actions.preview_scroll_win(5),
      ["<C-d>"] = actions.preview_scroll_win(-5),
      ["v"] = actions.jump_vsplit,
      ["s"] = actions.jump_split,
      ["t"] = actions.jump_tab,
      ["<CR>"] = actions.jump,
      ["o"] = actions.jump,
      ["l"] = actions.open_fold,
      ["h"] = actions.close_fold,
      ["<c-h>"] = actions.enter_win("preview"), -- Focus preview window
      ["q"] = actions.close,
      ["Q"] = actions.close,
      ["<Esc>"] = actions.close,
      ["<C-q>"] = actions.quickfix,
      -- ['<Esc>'] = false -- disable a mapping
    },
    preview = {
      ["q"] = actions.close,
      ["Q"] = actions.close,
      ["<Esc>"] = actions.close,
      ["<Tab>"] = actions.next_location,
      ["<S-Tab>"] = actions.previous_location,
      ["<a-l>"] = actions.enter_win("list"), -- Focus list window
    },
  },
})

-- Setup LSP
-- lua/core/lsp.lua (or your preferred file path)
-- Diagnostics Configuration (Inspired by reference, merged with user's preferences) {{{
local diagnostic_config = {
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "", -- Icon from reference
      [vim.diagnostic.severity.WARN] = "", -- Icon from reference
      [vim.diagnostic.severity.HINT] = "", -- Icon from reference
      [vim.diagnostic.severity.INFO] = "", -- Icon from reference
    },
    -- if you want to use the signs provided by your existing config:
    -- ERROR = "✘", WARN = "▲", HINT = "⚑", INFO = "»"
  },
  update_in_insert = true, -- From reference
  underline = true, -- From reference
  severity_sort = true, -- From reference
  virtual_text = false, -- User preference
  float = {
    focusable = false, -- Good default, also in reference
    style = "minimal", -- From reference, or "single" as per user's original float
    border = "single", -- User preference
    source = "always", -- From reference, shows diagnostic source
    header = "", -- From reference
    prefix = "", -- From reference
    suffix = "", -- From reference
    format = function(diagnostic) -- User's custom format function
      local message = diagnostic.message
      local source = diagnostic.source
      local code = diagnostic.code
        or (diagnostic.user_data and diagnostic.user_data.lsp and diagnostic.user_data.lsp.code)
      if code then
        return string.format("%s (%s) [%s]", message, source, code)
      else
        return string.format("%s (%s)", message, source)
      end
    end,
  },
}
vim.diagnostic.config(diagnostic_config)

-- Autocommand for opening diagnostic float on CursorHold (User's preference)
vim.api.nvim_create_autocmd("CursorHold", {
  group = vim.api.nvim_create_augroup("RjDiagnosticFloatGroup", { clear = true }), -- Renamed group for clarity
  pattern = "*",
  callback = function()
    vim.diagnostic.open_float({ scope = "line", focusable = false })
  end,
})
-- }}}

-- LSP Capabilities {{{
-- Start with Neovim's default capabilities
local capabilities = vim.lsp.protocol.make_client_capabilities()

-- Add foldingRange capabilities (from user's config)
capabilities.textDocument.foldingRange = {
  dynamicRegistration = false, -- User specified false
  lineFoldingOnly = true,
}

-- Add semanticTokens and snippetSupport (from reference config)
capabilities.textDocument.semanticTokens.multilineTokenSupport = true
capabilities.textDocument.completion.completionItem.snippetSupport = true

-- Integrate capabilities from blink.cmp (User's requirement)
local ok_cmp_blink, blink_cmp = pcall(require, "blink.cmp")
if ok_cmp_blink and blink_cmp.get_lsp_capabilities then
  capabilities = blink_cmp.get_lsp_capabilities(capabilities)
  vim.notify("LSP capabilities extended by blink.cmp", vim.log.levels.INFO)
else
  vim.notify(
    "blink.cmp not found or get_lsp_capabilities missing. Using default LSP capabilities.",
    vim.log.levels.WARN
  )
end
-- }}}

-- Global LSP settings and on_attach through LspAttach autocmd {{{
-- The on_attach function will be handled by the LspAttach autocmd callback
-- We can set global capabilities here if not overriding per server,
-- but the LspAttach autocmd is more flexible for client-specific setup.

-- Keymap helper function (inspired by reference)
local function keymap_set(mode, lhs, rhs, desc, buffer)
  local opts = { silent = true, desc = desc }
  if buffer then
    opts.buffer = buffer
  end
  vim.keymap.set(mode, lhs, rhs, opts)
end

-- Create keybindings, commands, and other settings on LSP attach
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("RjLspAttachGroup", { clear = true }), -- Group for LspAttach
  callback = function(ev)
    local bufnr = ev.buf
    local client = vim.lsp.get_client_by_id(ev.data.client_id)

    if not client then
      vim.notify(
        "LspAttach: Client not found for ID: " .. tostring(ev.data.client_id),
        vim.log.levels.WARN
      )
      return
    end

    vim.notify("LSP attached: " .. client.name .. " to buffer " .. bufnr, vim.log.levels.INFO)

    -- Set omnifunc and tagfunc (from reference)
    if client.server_capabilities.completionProvider then
      vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"
    end
    if client.server_capabilities.definitionProvider then
      vim.bo[bufnr].tagfunc = "v:lua.vim.lsp.tagfunc"
    end

    -- Optional: Disable semantic tokens if not desired (from reference)
    -- client.server_capabilities.semanticTokensProvider = nil

    -- Attach nvim-navic (User's requirement)
    local ok_navic, navic = pcall(require, "nvim-navic")
    if ok_navic then
      if client.server_capabilities.documentSymbolProvider then -- Check if server supports document symbols
        navic.attach(client, bufnr)
        vim.notify("nvim-navic attached to " .. client.name, vim.log.levels.INFO)
      else
        vim.notify(
          "nvim-navic: " .. client.name .. " does not support document symbols.",
          vim.log.levels.INFO
        )
      end
    else
      vim.notify("nvim-navic not found. Skipping attachment.", vim.log.levels.WARN)
    end

    -- Conditional settings for specific servers (User's requirement for ruff)
    if client.name == "ruff_lsp" or client.name == "ruff" then -- Check both common names
      vim.notify("Disabling hoverProvider for ruff_lsp/ruff.", vim.log.levels.INFO)
      client.server_capabilities.hoverProvider = false
    end

    -- User's Keymaps
    keymap_set("n", "gl", function()
      vim.lsp.buf.hover()
    end, "LSP Hover", bufnr)
    keymap_set("n", "gD", function()
      vim.lsp.buf.definition()
    end, "LSP Definition", bufnr)
    keymap_set("n", "gd", "<CMD>Glance definitions<CR>", "Glance Definitions", bufnr)
    keymap_set("n", "gR", function()
      vim.lsp.buf.references()
    end, "LSP References", bufnr)
    keymap_set("n", "gi", function()
      vim.lsp.buf.implementation()
    end, "LSP Implementation", bufnr)
    keymap_set("n", "gr", "<CMD>Glance references<CR>", "Glance References", bufnr)
    keymap_set("n", "<F2>", function()
      vim.lsp.buf.rename()
    end, "LSP Rename", bufnr)

    keymap_set("n", "]D", function()
      vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.ERROR, float = true })
    end, "Next Error", bufnr)
    keymap_set("n", "[D", function()
      vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.ERROR, float = true })
    end, "Previous Error", bufnr)

    -- Additional useful keymaps (can be adapted from reference or added - UPDATED)
    keymap_set("n", "K", function()
      vim.lsp.buf.hover({ border = "single" })
    end, "LSP Hover (K)", bufnr) -- Alternative hover
    keymap_set("n", "<Leader>la", function()
      vim.lsp.buf.code_action()
    end, "LSP Code Action", bufnr)
    keymap_set("n", "<Leader>ld", vim.diagnostic.open_float, "Line Diagnostics", bufnr) -- Similar to user's CursorHold but manual
    keymap_set("n", "<Leader>lj", function()
      vim.diagnostic.jump({ count = 1, float = true })
    end, "Next Diagnostic", bufnr)
    keymap_set("n", "<Leader>lk", function()
      vim.diagnostic.jump({ count = -1, float = true })
    end, "Prev Diagnostic", bufnr)
    keymap_set("n", "<Leader>lq", vim.diagnostic.setloclist, "Diagnostics to Loclist", bufnr)

    -- If client supports formatting, you could add a formatting keymap
    if client.server_capabilities.documentFormattingProvider then
      keymap_set("n", "<Leader>lf", function()
        vim.lsp.buf.format({ async = true })
      end, "LSP Format Document", bufnr)
    end
  end,
})

-- Servers Configuration {{{

-- Python: pylsp {{{
vim.lsp.config.pylsp = {
  cmd = { "pylsp" }, -- Ensure 'pylsp' is in your PATH
  filetypes = { "python" },
  -- root_dir = vim.lsp.util.root_pattern("pyproject.toml", "setup.py", "requirements.txt", ".git"), -- Example root pattern
  root_markers = {
    "pyproject.toml",
    "setup.py",
    "setup.cfg",
    "requirements.txt",
    "Pipfile",
    ".git",
  },
  settings = {
    pylsp = {
      plugins = {
        -- User's pylsp plugin settings
        flake8 = { enabled = false },
        mypy = { enabled = false },
        pycodestyle = { enabled = false },
        pyflakes = { enabled = false },
        mccabe = { enabled = false },
        pydocstyle = { enabled = false },
        autopep8 = { enabled = false },
        yapf = { enabled = false },
        pylint = { enabled = false },
        rope_completion = { enabled = false },
        jedi_completion = { enabled = true },
        jedi_definition = { enabled = true },
        jedi_hover = { enabled = true },
        jedi_references = { enabled = true },
        jedi_signature_help = { enabled = true },
        jedi_symbols = { enabled = true },
        jedi = {
          auto_import_modules = { "numpy", "pandas" },
        },
      },
    },
  },
  capabilities = capabilities, -- Pass the global capabilities
  -- on_attach is handled globally by LspAttach autocmd
}
-- }}}

-- Python: ruff (ruff_lsp) {{{
vim.lsp.config.ruff_lsp =
  { -- The server name used by nvim-lspconfig is 'ruff_lsp'. If your executable is just 'ruff', adjust cmd.
    cmd = { "ruff-lsp" }, -- Ensure 'ruff-lsp' or the correct ruff LSP command is in your PATH
    filetypes = { "python" },
    -- root_dir = vim.lsp.util.root_pattern("pyproject.toml", "ruff.toml", ".git"), -- Example root pattern
    root_markers = {
      "pyproject.toml",
      "ruff.toml",
      "ruff.toml.beta",
      ".ruff.toml",
      ".ruff.toml.beta",
      ".git",
    },
    capabilities = capabilities,
    -- on_attach is handled globally by LspAttach autocmd
    -- No specific settings provided in user config for ruff_lsp, add if any.
  }
-- }}}

-- Lua: lua_ls {{{
vim.lsp.config.lua_ls = {
  cmd = { "lua-language-server" }, -- From reference, ensure it's in PATH
  filetypes = { "lua" },
  root_markers = { ".luarc.json", "lua/", "init.lua", ".git" }, -- Enhanced root markers
  settings = {
    Lua = {
      -- User's LuaLS settings
      runtime = {
        version = "LuaJIT",
        path = vim.split(package.path, ";"),
      },
      diagnostics = {
        globals = { "vim" },
      },
      workspace = {
        -- library = vim.api.nvim_get_runtime_file("", true), -- More robust way to get runtime files
        library = { vim.env.VIMRUNTIME },
        checkThirdParty = false, -- Or true if you want diagnostics from third-party libs in workspace
      },
      telemetry = {
        enable = false,
      },
      -- Additional useful settings from reference (optional)
      -- completion = { callSnippet = "Replace" },
      -- hint = { enable = true },
    },
  },
  capabilities = capabilities,
  -- on_attach is handled globally by LspAttach autocmd
}
-- }}}

-- Enable the configured Language Servers
-- You can enable them individually after each config block too.
vim.lsp.enable({ "pylsp", "ruff_lsp", "lua_ls" })

vim.notify(
  "LSP configurations applied. Enabled servers: pylsp, ruff_lsp, lua_ls",
  vim.log.levels.INFO
)
-- }}}

-- LSP Management Commands (from reference, optional but useful) {{{
vim.api.nvim_create_user_command("LspStart", function(opts)
  local bufnr = vim.api.nvim_get_current_buf()
  local clients_started = {}
  if vim.tbl_isempty(vim.lsp.get_clients({ bufnr = bufnr })) then
    vim.notify("Attempting to start LSP clients for buffer: " .. bufnr, vim.log.levels.INFO)
    -- This is a bit tricky without lspconfig's :LspStart behavior which often re-evaluates filetype.
    -- A simple way is to trigger a FileType event or re-sourcing, but that can be heavy.
    -- For now, this command will mostly be useful if a client was manually stopped.
    -- The `vim.lsp.enable` above should auto-start on relevant filetypes.
    -- To truly restart/start, often a re-trigger of LspAttach is needed,
    -- which usually happens on BufEnter or FileType.
    -- A simple vim.cmd.edit() can re-trigger LSP attachment for the current buffer.
    vim.cmd.edit()
    vim.notify(
      "LSP clients re-evaluated for the current buffer. Check LspInfo.",
      vim.log.levels.INFO
    )
  else
    vim.notify("LSP clients already active or starting for this buffer.", vim.log.levels.INFO)
  end
end, { desc = "Starts/Restarts LSP clients in the current buffer" })

vim.api.nvim_create_user_command("LspStop", function(opts)
  local clients_to_stop = vim.lsp.get_clients({ bufnr = vim.api.nvim_get_current_buf() })
  if opts.args ~= "" then
    clients_to_stop = vim.tbl_filter(function(client)
      return client.name == opts.args
    end, clients_to_stop)
  end
  if vim.tbl_isempty(clients_to_stop) then
    vim.notify("No matching LSP clients to stop.", vim.log.levels.INFO)
    return
  end
  for _, client in ipairs(clients_to_stop) do
    client:stop()
    vim.notify(client.name .. ": stopped", vim.log.levels.INFO)
  end
end, {
  desc = "Stop all LSP clients or a specific client attached to the current buffer.",
  nargs = "?",
  complete = function()
    local clients = vim.lsp.get_clients({ bufnr = vim.api.nvim_get_current_buf() })
    local client_names = {}
    for _, client in ipairs(clients) do
      table.insert(client_names, client.name)
    end
    return client_names
  end,
})

vim.api.nvim_create_user_command("LspRestart", function()
  local current_buf = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients({ bufnr = current_buf })
  if vim.tbl_isempty(clients) then
    vim.notify("No LSP clients attached to the current buffer to restart.", vim.log.levels.INFO)
    vim.cmd.LspStart() -- Try to start them if none are running
    return
  end
  vim.notify("Restarting LSP clients for current buffer...", vim.log.levels.INFO)
  for _, client in ipairs(clients) do
    vim.lsp.stop_client(client.id)
  end
  -- LSP should auto-restart on next event or if forced. A simple edit can trigger this.
  -- For a more direct restart, a timer might be needed to ensure stop completes before start.
  vim.defer_fn(function()
    vim.cmd.edit("%") -- Re-edit current file to trigger LSP attach
    vim.notify("LSP clients restart initiated.", vim.log.levels.INFO)
  end, 100) -- Small delay
end, {
  desc = "Restart all the language client(s) attached to the current buffer",
})

vim.api.nvim_create_user_command("LspLog", function()
  local log_path = vim.lsp.get_log_path()
  if log_path then
    vim.cmd.vsplit(log_path)
  else
    vim.notify("LSP log path not found.", vim.log.levels.WARN)
  end
end, {
  desc = "Open the LSP log file",
})

-- LspInfo from reference (improved version)
vim.api.nvim_create_user_command("LspInfo", function()
  local info = vim.lsp.get_clients({ bufnr = vim.api.nvim_get_current_buf() })
  if #info == 0 then
    vim.notify("No language servers attached to the current buffer.", vim.log.levels.INFO)
    return
  end
  local messages = { "Active LSP clients for current buffer:" }
  for _, client in ipairs(info) do
    local client_info = string.format(
      "- ID: %d, Name: %s, Filetypes: %s, Root: %s",
      client.id,
      client.name,
      table.concat(client.config.filetypes or {}, ", "),
      client.config.root_dir or "N/A"
    )
    table.insert(messages, client_info)
  end
  vim.notify(table.concat(messages, "\n"), vim.log.levels.INFO, { title = "LSP Info" })

  -- Optionally, open the full LspInfo buffer
  -- vim.cmd("LspInfo") -- This would call the built-in :LspInfo if available from lspconfig,
  -- or you can create your own buffer display.
  -- For now, using notifications.
end, {
  desc = "Show information about active LSP clients for the current buffer.",
})
-- }}}

-- vim: fdm=marker:fdl=0
vim.o.updatetime = 300

-- REPL using iron
vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  group = vim.api.nvim_create_augroup("python-repl", { clear = true }),
  callback = function(args)
    local iron = require("iron.core")
    local view = require("iron.view")
    iron.setup({
      config = {
        scope = require("iron.scope").path_based,
        scratch_repl = true,
        repl_definition = {
          python = {
            format = require("iron.fts.common").bracketed_paste,
            command = { "ipython", "--no-autoindent" },
          },
        },
        repl_open_cmd = view.split.vertical.botright(function()
          return math.max(vim.o.columns * 0.35, 80)
        end),
      },
      keymaps = {},
      highlight = {
        italic = true,
      },
      ignore_blank_lines = false, -- ignore blank lines when sending visual select lines
    })
    -- TODO norm! gv after Iron start/restart
    vim.keymap.set({ "n", "v" }, [[<a-\>]], function()
      vim.cmd("IronRepl")
      vim.cmd("wincmd =")
    end, { buffer = args.buf, desc = "repl_toggle" })
    vim.keymap.set({ "n", "v" }, "<localleader>r", function()
      vim.cmd("IronRestart")
      vim.cmd("wincmd =")
    end, { buffer = args.buf, desc = "repl_restart" })

    local send_magic_paste = function()
      vim.cmd("call SelectVisual()")
      vim.cmd("norm! y`>")
      vim.defer_fn(function()
        iron.send(nil, "%paste")
      end, 100)
      vim.cmd("norm! j")
    end
    local send_cr = function()
      iron.send(nil, string.char(13))
    end

    vim.keymap.set("t", [[<a-\>]], "<cmd>q<cr>", { desc = "repl_toggle" })
    vim.keymap.set("n", "<localleader><cr>", send_cr, { buffer = args.buf, desc = "repl_cr" })
    vim.keymap.set("n", "<C-CR>", send_cr, { buffer = args.buf, desc = "repl_cr" })
    if vim.fn.has("linux") == 1 then
      vim.keymap.set("n", "<S-CR>", function()
        vim.cmd("call SelectVisual()")
        iron.visual_send()
        vim.cmd("norm! j")
      end, { buffer = args.buf, desc = "repl_send_cell" })
    else
      vim.keymap.set(
        "n",
        "<S-CR>",
        send_magic_paste,
        { buffer = args.buf, desc = "repl_send_cell" }
      )
    end
    vim.keymap.set("n", "<localleader>y", function()
      local original_cursor_pos = vim.api.nvim_win_get_cursor(0)
      local current_line_1_indexed = original_cursor_pos[1]
      local var_name = vim.fn.expand("<cword>")
      if not var_name or var_name == "" then
        vim.notify("No word under cursor.", vim.log.levels.WARN)
        return
      end

      local command_to_send

      if vim.fn.has("unix") == 1 then
        command_to_send =
          string.format("import linutils.cb_helper; linutils.cb_helper.to_clipboard(%s)", var_name)
        vim.notify("Using linutils.cb_helper.to_clipboard()", vim.log.levels.INFO)
      else
        command_to_send = string.format("%s.to_clipboard()", var_name)
        vim.notify("Using default .to_clipboard()", vim.log.levels.INFO)
      end
      vim.api.nvim_buf_set_lines(
        args.buf,
        current_line_1_indexed,
        current_line_1_indexed,
        false,
        { command_to_send }
      )
      vim.api.nvim_win_set_cursor(0, { current_line_1_indexed + 1, 0 })
      vim.cmd("normal! V")
      iron.visual_send()
      vim.notify(string.format("Sent to REPL: %s", command_to_send), vim.log.levels.INFO)
      vim.api.nvim_buf_set_lines(
        args.buf,
        current_line_1_indexed,
        current_line_1_indexed + 1,
        false,
        {}
      )
      vim.api.nvim_win_set_cursor(0, original_cursor_pos)
    end, {
      buffer = args.buf,
      desc = "repl_df_to_clipboard (OS-aware)",
    })
    local function create_repl_sender(key, desc, command_format_string)
      vim.keymap.set("n", key, function()
        local original_cursor_pos = vim.api.nvim_win_get_cursor(0)
        local current_line_1_indexed = original_cursor_pos[1]
        local var_name = vim.fn.expand("<cword>")
        if not var_name or var_name == "" then
          vim.notify("No word under cursor", vim.log.levels.WARN)
          return
        end
        local command_to_send = string.format(command_format_string, var_name)
        vim.api.nvim_buf_set_lines(
          args.buf,
          current_line_1_indexed,
          current_line_1_indexed,
          false,
          { command_to_send }
        )
        vim.api.nvim_win_set_cursor(0, { current_line_1_indexed + 1, 0 })
        vim.cmd("normal! V")
        iron.visual_send()
        vim.notify(string.format("Sent: %s", command_to_send), vim.log.levels.INFO)
        vim.api.nvim_buf_set_lines(
          args.buf,
          current_line_1_indexed,
          current_line_1_indexed + 1,
          false,
          {}
        )
        vim.api.nvim_win_set_cursor(0, original_cursor_pos)
      end, {
        buffer = args.buf, -- Keymap is buffer-local, requires args.buf
        desc = desc,
      })
    end
    create_repl_sender("<localleader>pp", "repl_print", "print(%s)")
    create_repl_sender("<localleader>pl", "repl_print_last", "print(%s.iloc[-1].T)")
    create_repl_sender("<localleader>pf", "repl_print_first", "print(%s.iloc[0].T)")
    create_repl_sender("<localleader>pi", "repl_print_info", "print(%s.info())")
    vim.keymap.set("v", "<CR>", function()
      iron.visual_send()
      vim.cmd("norm! j")
    end, { buffer = args.buf, desc = "repl_v_send" })
    vim.keymap.set({ "n", "v" }, "<localleader>u", function()
      iron.send_until_cursor()
      vim.api.nvim_input("<ESC>") -- to escape from visual mode
    end, { buffer = args.buf, desc = "repl_send_until" })
    vim.keymap.set(
      "n",
      "<localleader><PageUp>",
      ":wincmd w<CR><C-u>:wincmd p<CR>",
      { buffer = args.buf, noremap = true, silent = true, desc = "repl_prev" }
    )
    vim.keymap.set(
      "n",
      "<localleader><PageDown>",
      ":wincmd w<CR><C-d>:wincmd p<CR>",
      { buffer = args.buf, noremap = true, silent = true, desc = "repl_next" }
    )
    vim.keymap.set({ "n", "v" }, "<localleader>qq", function()
      iron.close_repl()
      iron.send(nil, string.char(13))
    end, { buffer = args.buf, desc = "repl_exit" })
    vim.keymap.set({ "n", "v" }, "<localleader>c", function()
      iron.send(nil, string.char(03))
    end, { buffer = args.buf, desc = "repl_interrupt" })
    vim.keymap.set({ "n", "v" }, "<a-del>", function()
      iron.send(nil, string.char(12))
    end, { buffer = args.buf, desc = "repl_clear" })
    vim.keymap.set(
      "n",
      "<localleader>]",
      "<cmd>IronFocus<cr>i",
      { buffer = args.buf, desc = "repl_focus" }
    )
    vim.keymap.set("n", "]]", function()
      vim.cmd("call JumpCell()")
      vim.cmd("norm! zvzz")
    end, { buffer = args.buf, desc = "repl_jump_cell_fwd" })
    vim.keymap.set("n", "[[", function()
      vim.cmd("call JumpCellBack()")
      vim.cmd("norm! zvzz")
    end, { buffer = args.buf, desc = "repl_jump_cell_back" })
    vim.keymap.set(
      "n",
      "<localleader>==",
      ":!ruff format %<cr>",
      { buffer = args.buf, desc = "repl_sync_format" }
    )
  end,
})

-- in cmdline use :lua =XYZ to shorthand :lua print(XYZ)
vim.api.nvim_create_autocmd("FileType", {
  pattern = "lua",
  group = vim.api.nvim_create_augroup("lua-repl", { clear = true }),
  callback = function(args)
    vim.keymap.set(
      "n",
      "<localleader><localleader>f",
      "<cmd>source %<CR>",
      { buffer = args.buf, desc = "execute lua file" }
    )
    vim.keymap.set(
      "n",
      "<localleader>l",
      ":.lua<cr>",
      { buffer = args.buf, desc = "execute lua line" }
    )
    vim.keymap.set("v", "<CR>", ":lua<cr>", { buffer = args.buf, desc = "execute lua line" })
  end,
})
