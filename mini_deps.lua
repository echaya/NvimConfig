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
        post_checkout = build,
      },
    })
    add({
      source = "danielfalk/smart-open.nvim",
      checkout = "0.3.x",
      monitor = "main",
      depends = {
        "kkharji/sqlite.lua",
        "nvim-telescope/telescope-fzf-native.nvim",
      },
    })
    add({ source = "stevearc/dressing.nvim" })
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
    add({ source = "L3MON4D3/LuaSnip" })
    add({ source = "echaya/friendly-snippets" })
    add({ source = "saadparwaiz1/cmp_luasnip" })
    add({ source = "stevearc/conform.nvim" })
    add({ source = "lewis6991/gitsigns.nvim" })
    add({ source = "sindrets/diffview.nvim" })
    add({ source = "MeanderingProgrammer/render-markdown.nvim" })
    dofile(vim.g.WorkDir .. "config/code_config.lua")
  else
    dofile(vim.g.WorkDir .. "config/vscode_config.lua")
  end
end)
