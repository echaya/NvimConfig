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
if LoadVimPlugin == nil then
  LoadVimPlugin = false
end

local add_vim_plugin = function(value)
  if type(value) == "table" then
    add({ source = value[1], name = value[2] })
  else
    add({ source = value })
  end
end

local vim_now_index = 3
-- deps now: UI & early utilities
now(function()
  if LoadVimPlugin then
    for _, value in ipairs(vim.g.vim_plugin) do
      add_vim_plugin(value)
    end
  end
  -- vim plugins, StartupTime
  for index, value in ipairs(vim.g.share_plugin) do
    if index <= vim_now_index then
      add_vim_plugin(value)
    end
  end
  add({ source = "folke/snacks.nvim" })
  add({ source = "thesimonho/kanagawa-paper.nvim" })
  add({ source = "folke/tokyonight.nvim" })
  require("lua.nvim_now_config")
end)

-- deps later: utilities
later(function()
  -- vim plugins
  for index, value in ipairs(vim.g.share_plugin) do
    if index > vim_now_index then
      add_vim_plugin(value)
    end
  end
  -- nvim plugins
  add({ source = "https://codeberg.org/andyg/leap.nvim" })
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
      checkout = "v1.8.0", -- check releases for latest tag
    })
    add({
      source = "nvim-treesitter/nvim-treesitter",
      checkout = "master",
      hooks = {
        post_checkout = function()
          vim.cmd("TSUpdate")
        end,
      },
    })
    add({ source = "nvim-treesitter/nvim-treesitter-context" })
    require("lua.lsp_config")
  end)
end

-- deps later: programming tools
later(function()
  if vim.g.vscode == nil then
    add({ source = "milanglacier/yarepl.nvim" })
    add({ source = "stevearc/conform.nvim" })
    add({ source = "echaya/neowiki.nvim", checkout = "dev" })
    -- add({ source = "NStefan002/screenkey.nvim" })
    add({ source = "esmuellert/vscode-diff.nvim", checkout = "next" })
    add({ source = "MeanderingProgrammer/render-markdown.nvim" })
    require("lua.code_config")
    require("lua.repl_config")
  else
    require("lua.vscode_config")
  end
end)
