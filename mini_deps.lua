local path_package = vim.fn.stdpath("data") .. "/site/"
local mini_path = path_package .. "pack/deps/start/mini.nvim"
if not vim.loop.fs_stat(mini_path) then
  vim.cmd('echo "Installing `mini.nvim`" | redraw')
  local clone_cmd = {
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/echasnovski/mini.nvim",
    mini_path,
  }
  vim.fn.system(clone_cmd)
  vim.cmd("packadd mini.nvim | helptags ALL")
  vim.cmd('echo "Installed `mini.nvim`" | redraw')
end

if vim.loader then
  vim.loader.enable()
end

-- Set up 'mini.deps' (customize to your liking)
require("mini.deps").setup({ path = { package = path_package } })

vim.api.nvim_create_user_command("PU", function()
  vim.cmd("DepsUpdate")
end, { desc = "DepsUpdate" })

-- turn auto save off on acwrite
local disabled_buftype = { "acwrite", "oil" }
vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged" }, {
  callback = function()
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      buf_type = vim.api.nvim_get_option_value("buftype", { buf = buf })
      if vim.tbl_contains(disabled_buftype, buf_type) and vim.g.auto_save == 1 then
        vim.notify("vim.g.auto_save = 0 (OFF)", "warn", { title = "AutoSave" })
        vim.g.auto_save = 0
        return
      end
    end
    if vim.g.auto_save == 0 then
      vim.notify("vim.g.auto_save = 1 (ON)", "info", { title = "AutoSave" })
      vim.g.auto_save = 1
    end
  end,
})

local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later

local build = function(args)
  -- local obj = vim.system({ "make", "-C", args.path, "install_jsregexp" }, { text = true }):wait()
  local obj = vim.system({ "make", "-C", args.path }, { text = true }):wait()
  vim.print(vim.inspect(obj))
end

-- control how many vim plugins to be loaded now
local vim_now_index = 2
-- deps now: UI & early utilities
now(function()
  -- vim plugins, StartupTime
  for index, value in ipairs(vim.g.lst_plugin) do
    if index <= vim_now_index then
      add({ source = value })
    end
  end
  add({ source = "folke/snacks.nvim" })
  add({ source = "rebelot/kanagawa.nvim" })
  add({ source = "nvim-lualine/lualine.nvim" })
  add({ source = "SmiteshP/nvim-navic" })
  add({ source = "lewis6991/satellite.nvim" })
  add({
    source = "folke/noice.nvim",
    depends = {
      "MunifTanjim/nui.nvim",
    },
  })
  dofile(vim.g.WorkDir .. "config/nvim_gui_config.lua")
end)

-- deps later: utilities
later(function()
  -- vim plugins
  for index, value in ipairs(vim.g.lst_plugin) do
    if index > vim_now_index then
      add({ source = value })
    end
  end
  -- nvim plugins
  add({ source = "ggandor/leap.nvim" })
  add({ source = "max397574/better-escape.nvim" })
  add({ source = "monaqa/dial.nvim" })
  dofile(vim.g.WorkDir .. "config/univ_config.lua")
  if vim.g.vscode == nil then
    add({ source = "folke/which-key.nvim" })
    add({
      source = "nvim-telescope/telescope.nvim",
      depends = {
        "nvim-lua/plenary.nvim",
      },
    })
    add({ source = "debugloop/telescope-undo.nvim" })
    add({
      source = "nvim-telescope/telescope-fzf-native.nvim",
      hooks = {
        post_install = build,
      },
    })
    add({ source = "stevearc/dressing.nvim" })
    dofile(vim.g.WorkDir .. "config/nvim_utils_config.lua")
  end
end)

-- deps later: lsp and iron
later(function()
  add({ source = "neovim/nvim-lspconfig" })
  add({ source = "dnlhc/glance.nvim" })
  add({ source = "Vigemus/iron.nvim" })
  dofile(vim.g.WorkDir .. "config/lsp_repl_config.lua")
end)

-- deps later: programming tools
later(function()
  if vim.g.vscode == nil then
    add({ source = "nvim-treesitter/nvim-treesitter" })
    add({
      source = "iguanacucumber/magazine.nvim",
      name = "nvim-cmp",
    })
    add({
      source = "iguanacucumber/mag-nvim-lsp",
      name = "cmp-nvim-lsp",
    })
    add({
      source = "iguanacucumber/mag-nvim-lua",
      name = "cmp-nvim-lua",
    })
    add({
      source = "iguanacucumber/mag-buffer",
      name = "cmp-buffer",
    })
    add({
      source = "iguanacucumber/mag-cmdline",
      name = "cmp-cmdline",
    })
    add({
      source = "https://codeberg.org/FelipeLema/cmp-async-path",
      name = "async_path",
    })
    add({
      source = "nvim-treesitter/nvim-treesitter",
      hooks = {
        post_checkout = function()
          vim.cmd("TSUpdate")
        end,
      },
    })
    add({ source = "L3MON4D3/LuaSnip" })
    add({ source = "echaya/friendly-snippets" })
    add({ source = "saadparwaiz1/cmp_luasnip" })
    add({ source = "stevearc/conform.nvim" })
    add({ source = "lewis6991/gitsigns.nvim" })
    add({ source = "sindrets/diffview.nvim" })
    add({ source = "MeanderingProgrammer/render-markdown.nvim" })
    dofile(vim.g.WorkDir .. "config/code_utils_config.lua")
  else
    dofile(vim.g.WorkDir .. "config/vscode_config.lua")
  end
end)
