-- Setup treesitter
require("nvim-treesitter.configs").setup({
  -- A list of parser names, or "all" (the listed parsers MUST always be installed)
  ensure_installed = {
    "bash",
    "diff",
    "gitcommit",
    "lua",
    "markdown",
    "markdown_inline",
    "powershell",
    "python",
    "query",
    "regex",
    "vim",
    "vimdoc",
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
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldlevelstart = 99
vim.opt.foldlevel = 3
vim.opt.foldnestmax = 3
vim.opt.foldtext = ""

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
      ["<Down>"] = false, -- disable a mapping
      ["<Up>"] = false, -- disable a mapping
      ["<c-h>"] = actions.enter_win("preview"), -- Focus preview window
      ["<C-q>"] = actions.quickfix,
    },
    preview = {
      ["<c-l>"] = actions.enter_win("list"), -- Focus list window
    },
  },
})

-- Setup LSP
vim.diagnostic.config({
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "󰅚 ",
      [vim.diagnostic.severity.WARN] = "󰀪 ",
      [vim.diagnostic.severity.INFO] = "󰋽 ",
      [vim.diagnostic.severity.HINT] = "󰌶 ",
    },
  },
  update_in_insert = false,
  underline = { enabled = true, severity = vim.diagnostic.severity.WARN }, -- Underline warnings and errors by default
  severity_sort = true,
  virtual_text = false, -- Keep false if you prefer
  float = {
    focusable = false,
    style = "minimal",
    border = "rounded",
    popup_origin = "window",
    wrap = true,
    header = "",
    prefix = "",
    suffix = "",
    format = function(diagnostic)
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
})

-- Autocommand for opening diagnostic float on CursorHold (User's preference)
vim.api.nvim_create_autocmd("CursorHold", {
  group = vim.api.nvim_create_augroup("DiagnosticFloatGroup", { clear = true }), -- Renamed group for clarity
  pattern = "*",
  callback = function()
    vim.defer_fn(function()
      vim.diagnostic.open_float({
        scope = "line",
        focusable = false,
        close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost", "WinLeave" },
      })
    end, 250)
  end,
})

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.foldingRange = {
  dynamicRegistration = false,
  lineFoldingOnly = true,
}
capabilities.textDocument.completion.completionItem.snippetSupport = true
local ok_cmp_blink, blink_cmp = pcall(require, "blink.cmp")
if ok_cmp_blink and blink_cmp.get_lsp_capabilities then
  capabilities = blink_cmp.get_lsp_capabilities(capabilities)
else
  vim.notify(
    "blink.cmp not found or get_lsp_capabilities missing. Using default LSP capabilities.",
    vim.log.levels.WARN
  )
end

-- The on_attach function will be handled by the LspAttach autocmd callback
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

    if client.name == "ruff_lsp" or client.name == "ruff" then -- Check both common names
      client.server_capabilities.documentFormattingProvider = true
      client.server_capabilities.hoverProvider = false
    end

    if client.name == "pyrefly" then
      -- Disable features provided by other LSPs (like Pylsp or Ruff)
      client.server_capabilities.documentFormattingProvider = false
      client.server_capabilities.hoverProvider = true
      client.server_capabilities.renameProvider = false
      client.server_capabilities.definitionProvider = false
      client.server_capabilities.referencesProvider = false
      -- Note: completionProvider and diagnosticProvider are kept enabled
    end
    -- if client.name == "ty" then
    --   -- Disable features provided by other LSPs (like Pylsp or Ruff)
    --   client.server_capabilities.documentFormattingProvider = false
    --   client.server_capabilities.hoverProvider = false
    --   client.server_capabilities.renameProvider = true
    --   client.server_capabilities.definitionProvider = true
    --   client.server_capabilities.referencesProvider = true
    --   client.server_capabilities.completionProvider = false
    --   client.server_capabilities.diagnosticProvider = false
    -- end
    if client.name == "pylsp" then
      -- Disable features provided by other LSPs (like Pylsp or Ruff)
      client.server_capabilities.documentFormattingProvider = false
      client.server_capabilities.hoverProvider = false
      client.server_capabilities.renameProvider = true
      client.server_capabilities.definitionProvider = true
      client.server_capabilities.referencesProvider = true
    end
    -- User's Keymaps
    vim.keymap.set("n", "gl", function()
      vim.lsp.buf.hover()
    end, { silent = true, desc = "LSP Hover", buffer = bufnr })
    vim.keymap.set("n", "gD", function()
      vim.lsp.buf.definition()
    end, { silent = true, desc = "LSP Definition", buffer = bufnr })
    vim.keymap.set(
      "n",
      "gd",
      "<CMD>Glance definitions<CR>",
      { silent = true, desc = "Glance Definitions", buffer = bufnr }
    )
    vim.keymap.set("n", "gR", function()
      vim.lsp.buf.references()
    end, { silent = true, desc = "LSP References", buffer = bufnr })
    vim.keymap.set(
      "n",
      "gr",
      "<CMD>Glance references<CR>",
      { silent = true, desc = "Glance References", buffer = bufnr }
    )
    vim.keymap.set("n", "<F2>", function()
      vim.lsp.buf.rename()
    end, { silent = true, desc = "LSP Rename", buffer = bufnr })
    vim.keymap.set(
      { "n", "v" },
      "ga",
      vim.lsp.buf.code_action,
      { silent = true, desc = "[G]oto Code [A]ction", buffer = bufnr }
    )
    vim.keymap.set("n", "]D", function()
      vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.ERROR, float = true })
    end, { silent = true, desc = "Next Error", buffer = bufnr })
    vim.keymap.set("n", "[D", function()
      vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.ERROR, float = true })
    end, { silent = true, desc = "Previous Error", buffer = bufnr })
  end,
})

local function get_python_sys_path()
  local cmd = 'python -c "import sys, os; print(os.pathsep.join(sys.path))"'
  local path_str = vim.trim(vim.fn.system(cmd))
  return path_str
end

vim.lsp.config.ty = {
  cmd = { "ty", "server" },
  cmd_env = {
    PYTHONPATH = get_python_sys_path(),
  },
  filetypes = { "python" },
  settings = {
    ty = {
      experimental = {
        rename = true,
      },
    },
  },
  root_dir = vim.fs.root(0, { ".git/", "pyproject.toml" }),
}

vim.lsp.config.pylsp = {
  cmd = { "pylsp" }, -- Ensure 'pylsp' is in your PATH
  filetypes = { "python" },
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
        jedi_completion = { enabled = false },
        jedi_definition = { enabled = true },
        jedi_hover = { enabled = false },
        jedi_references = { enabled = true },
        jedi_signature_help = { enabled = true },
        jedi_symbols = { enabled = true },
        jedi = {
          auto_import_modules = { "numpy", "pandas" },
        },
      },
    },
  },
  capabilities = capabilities,
}

vim.lsp.config.pyrefly = {
  cmd = { "pyrefly", "lsp" },
  filetypes = { "python" },
  root_markers = {
    "pyproject.toml",
    "setup.py",
    "setup.cfg",
    "requirements.txt",
    "Pipfile",
    ".git",
  },
  settings = {},
  capabilities = capabilities,
}

vim.lsp.config.ruff = {
  cmd = { "ruff", "server" },
  filetypes = { "python" },
  root_markers = {
    "pyproject.toml",
    "ruff.toml",
    "ruff.toml.beta",
    ".ruff.toml",
    ".ruff.toml.beta",
    ".git",
  },
  capabilities = capabilities,
}

vim.lsp.config.lua_ls = {
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  root_markers = { ".luarc.json", "lua/", "init.lua", ".git" }, -- Enhanced root markers
  settings = {
    Lua = {
      runtime = {
        version = "LuaJIT",
        path = vim.split(package.path, ";"),
      },
      diagnostics = {
        globals = { "vim" },
        disable = { "missing-fields" },
      },
      workspace = {
        -- library = vim.api.nvim_get_runtime_file("", true), -- More robust way to get runtime files
        library = { vim.env.VIMRUNTIME },
        checkThirdParty = false, -- Or true if you want diagnostics from third-party libs in workspace
      },
      telemetry = {
        enable = false,
      },
    },
  },
  capabilities = capabilities,
}

vim.lsp.enable({ "ty", "ruff", "lua_ls" })
-- vim.lsp.enable({ "ruff", "lua_ls", "pyrefly", "pylsp" })

vim.api.nvim_create_user_command("LspStart", function(_)
  local bufnr = vim.api.nvim_get_current_buf()
  if vim.tbl_isempty(vim.lsp.get_clients({ bufnr = bufnr })) then
    vim.notify("Attempting to start LSP clients for buffer: " .. bufnr, vim.log.levels.INFO)
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
end, {
  desc = "Show information about active LSP clients for the current buffer.",
})

vim.keymap.set("n", "<leader>lr", function()
  vim.cmd("LspRestart")
end, { silent = true, desc = "LSP Restart" })

vim.keymap.set("n", "<leader>ls", function()
  vim.cmd("LspStart")
end, { silent = true, desc = "LSP Start" })

vim.keymap.set("n", "<leader>lS", function()
  vim.cmd("LspStop")
end, { silent = true, desc = "LSP Stop" })
