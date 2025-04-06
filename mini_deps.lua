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
MiniDeps = require("mini.deps")
MiniDeps.setup({ path = { package = path_package } })
local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later

-- control how many vim plugins to be loaded now
local vim_now_index = 3
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
  add({ source = "SmiteshP/nvim-navic" })
  add({ source = "sindrets/diffview.nvim" })
  dofile(vim.g.WorkDir .. "config/nvim_now_config.lua")
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
      source = "folke/noice.nvim",
      depends = {
        "MunifTanjim/nui.nvim",
      },
    })
    dofile(vim.g.WorkDir .. "config/nvim_utils_config.lua")
  end
end)

if vim.g.vscode == nil then
  -- deps later: lsp, iron and treesitter
  later(function()
    add({ source = "neovim/nvim-lspconfig" })
    add({ source = "dnlhc/glance.nvim" })
    add({ source = "Vigemus/iron.nvim" })
    add({
      source = "nvim-treesitter/nvim-treesitter",
      hooks = {
        post_checkout = function()
          vim.cmd("TSUpdate")
        end,
      },
    })
    dofile(vim.g.WorkDir .. "config/lsp_repl_config.lua")
  end)
end

-- deps later: programming tools
later(function()
  if vim.g.vscode == nil then
    vim.g.update_blink = true
    add({
      source = "saghen/blink.cmp",
      depends = {
        "echaya/friendly-snippets",
      },
      checkout = "v1.1.1", -- check releases for latest tag
    })
    add({ source = "stevearc/conform.nvim" })
    add({ source = "stevearc/quicker.nvim" })
    add({ source = "lewis6991/gitsigns.nvim" })
    add({ source = "MeanderingProgrammer/render-markdown.nvim" })
    dofile(vim.g.WorkDir .. "config/code_config.lua")
  else
    dofile(vim.g.WorkDir .. "config/vscode_config.lua")
  end
end)
