path_package = vim.g.WorkDir .. "plugged/"
require("mini.deps").setup({ path = { package = path_package } })

local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later

-- deps now: UI
now(function()
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

later(function()
  add({ source = "folke/which-key.nvim" })
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
