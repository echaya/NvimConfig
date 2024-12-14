path_package = vim.g.WorkDir .. "plugged/"
require("mini.deps").setup({ path = { package = path_package } })

local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later

local build = function(args)
    local obj = vim.system({ "make", "-C", args.path }, { text = true }):wait()
    vim.print(vim.inspect(obj))
  end

-- deps now: UI & early utilities
now(function()
  add({ source = "nvim-lua/plenary.nvim" })
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
      "rcarriga/nvim-notify",
    },
  })
  dofile(vim.g.WorkDir .. "config.mini/nvim_gui_config.lua")
end)

-- deps later: utilities
later(function()
  add({ source = "ggandor/leap.nvim" })
  add({ source = "max397574/better-escape.nvim" })
  add({ source = "monaqa/dial.nvim" })
  dofile(vim.g.WorkDir .. "config.mini/univ_config.lua")
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
    dofile(vim.g.WorkDir .. "config.mini/nvim_utils_config.lua")
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
end)
