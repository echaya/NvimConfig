local path_package = vim.fn.stdpath("data") .. "/site/"
local mini_path = path_package .. "pack/deps/start/mini.nvim"
if not vim.loop.fs_stat(mini_path) then
  vim.cmd('echo "Installing `mini.nvim`" | redraw')
  local clone_cmd = {
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/nvim-mini/mini.nvim",
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

package.path = package.path
  .. ";"
  .. vim.g.config_dir
  .. "?.lua;"
  .. vim.g.config_dir
  .. "?/init.lua"
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
  add({ source = "sindrets/diffview.nvim" })
  require("lua.nvim_now_config")
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
  add({ source = "folke/flash.nvim" })
  add({ source = "monaqa/dial.nvim" })
  require("lua.univ_config")
  if vim.g.vscode == nil then
    add({ source = "folke/which-key.nvim" })
    add({
      source = "folke/noice.nvim",
      depends = {
        "MunifTanjim/nui.nvim",
      },
    })
    require("lua.nvim_utils_config")
  end
end)

if vim.g.vscode == nil then
  -- deps later: lsp, iron and treesitter
  later(function()
    add({
      source = "saghen/blink.cmp",
      depends = {
        "echaya/friendly-snippets",
      },
      checkout = "v1.7.0", -- check releases for latest tag
    })
    add({ source = "dnlhc/glance.nvim" })
    add({
      source = "nvim-treesitter/nvim-treesitter",
      hooks = {
        post_checkout = function()
          vim.cmd("TSUpdate")
        end,
      },
    })
    require("lua.lsp_config")
  end)
end

-- deps later: programming tools
later(function()
  if vim.g.vscode == nil then
    add({ source = "milanglacier/yarepl.nvim"})
    add({ source = "stevearc/conform.nvim" })
    add({ source = "stevearc/aerial.nvim" })
    add({ source = "echaya/neowiki.nvim", checkout = "dev" })
    -- add({ source = "NStefan002/screenkey.nvim" })
    add({ source = "MeanderingProgrammer/render-markdown.nvim" })
    require("lua.code_config")
    require("lua.repl_config")
  else
    require("lua.vscode_config")
  end
end)
