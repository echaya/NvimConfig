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
  add({
  })
end)
