local init_lua_full_path = vim.fn.expand("<sfile>:p")
local config_dir = vim.fn.fnamemodify(init_lua_full_path, ":h")
config_dir = config_dir:gsub("\\", "/")
if not config_dir:match("/$") then
  config_dir = config_dir .. "/"
end

local project_root = vim.fn.fnamemodify(config_dir, ":h")
local project_root = vim.fn.fnamemodify(project_root, ":h")
project_root = project_root:gsub("\\", "/")
if not project_root:match("/$") then
  project_root = project_root .. "/"
end

local new_package_paths = {}

local path_package = project_root .. "site/"
table.insert(new_package_paths, path_package .. "?.lua")
table.insert(new_package_paths, path_package .. "?/init.lua")

table.insert(new_package_paths, config_dir .. "?.lua")
table.insert(new_package_paths, config_dir .. "?/init.lua")

local config_modules_subdir = config_dir .. "modules/"
table.insert(new_package_paths, config_modules_subdir .. "?.lua")
table.insert(new_package_paths, config_modules_subdir .. "?/init.lua")

-- Append all new paths to Lua's package.path (semicolon separated)
if #new_package_paths > 0 then
  package.path = package.path .. ";" .. table.concat(new_package_paths, ";")
else
  vim.notify("No new package paths were added.", vim.log.levels.WARN, { title = "Config Loader" })
end

local mini_path = path_package .. "start/mini.nvim"
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
    vim.g.update_blink = true
    add({
      source = "saghen/blink.cmp",
      depends = {
        "echaya/friendly-snippets",
      },
      checkout = "v1.3.1", -- check releases for latest tag
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
    add({ source = "Vigemus/iron.nvim" })
    add({ source = "stevearc/conform.nvim" })
    add({ source = "stevearc/quicker.nvim" })
    add({ source = "MeanderingProgrammer/render-markdown.nvim" })
    require("lua.code_config")
  else
    require("lua.vscode_config")
  end
end)
