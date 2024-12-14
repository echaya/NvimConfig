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

-- Set up 'mini.deps' (customize to your liking)
require("mini.deps").setup({ path = { package = path_package } })

local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later

local build = function(args)
  -- local obj = vim.system({ "make", "-C", args.path, "install_jsregexp" }, { text = true }):wait()
  local obj = vim.system({ "make", "-C", args.path }, { text = true }):wait()
  vim.print(vim.inspect(obj))
end

-- deps now: UI & early utilities
now(function()
  -- vim plugins
  add({ source = "dstein64/vim-startuptime" })
  add({ source = "nvim-lua/plenary.nvim" })
  -- nvim plugins
  add({ source = "Shatur/neovim-session-manager" })
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
  add({ source = "unblevable/quick-scope" })
  add({ source = "tpope/vim-repeat" })
  add({ source = "svermeulen/vim-cutlass" })
  add({ source = "907th/vim-auto-save" })
  add({ source = "airblade/vim-rooter" })
  add({ source = "ggandor/leap.nvim" })
  add({ source = "max397574/better-escape.nvim" })
  add({ source = "monaqa/dial.nvim" })
  dofile(vim.g.WorkDir .. "config/univ_config.lua")
  if not vim.g.vscode then
    add({ source = "folke/which-key.nvim" })
    add({ source = "nvim-telescope/telescope.nvim" })
    add({ source = "debugloop/telescope-undo.nvim" })
    add({
      source = "nvim-telescope/telescope-fzf-native.nvim",
      hooks = {
        post_install = build,
      },
    })
    add({ source = "chentoast/marks.nvim" })
    add({ source = "stevearc/dressing.nvim" })
    dofile(vim.g.WorkDir .. "config/nvim_utils_config.lua")
  end
end)

later(function()
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
  add({ source = "dnlhc/glance.nvim" })
  add({ source = "saadparwaiz1/cmp_luasnip" })
  add({ source = "neovim/nvim-lspconfig" })
  dofile(vim.g.WorkDir .. "config/lsp_config.lua")
end)

later(function()
  if vim.g.vscode == nil then
    add({ source = "vimwiki/vimwiki" })
    add({ source = "dhruvasagar/vim-table-mode" })
    add({ source = "ferrine/md-img-paste.vim" })
    add({ source = "MTDL9/vim-log-highlighting" })
    add({ source = "nvim-treesitter/nvim-treesitter" })
    add({ source = "Vigemus/iron.nvim" })
    add({ source = "stevearc/conform.nvim" })
    add({ source = "lewis6991/gitsigns.nvim" })
    add({ source = "sindrets/diffview.nvim" })
    add({ source = "MeanderingProgrammer/render-markdown.nvim" })
    dofile(vim.g.WorkDir .. "config/repl_config.lua")
  else
    dofile(vim.g.WorkDir .. "config/vscode_config.lua")
  end
end)
