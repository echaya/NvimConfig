local leap = require("leap")
leap.opts.case_sensitive = true
-- leap.set_default_keymaps()
-- Define equivalence classes for brackets and quotes, in addition to <space>
leap.opts.equivalence_classes = { " \t\r\n", "([{", ")]}", "'\"`" }
vim.keymap.set({ "n" }, "s", "<Plug>(leap-forward-to)")
vim.keymap.set({ "n" }, "S", "<Plug>(leap-backward-to)")
vim.keymap.set({ "x", "o" }, "z", "<Plug>(leap-forward-to)", { desc = "leap forward textobj" })
vim.keymap.set({ "x", "o" }, "Z", "<Plug>(leap-backward-to)", { desc = "leap back textobj" })
vim.keymap.set({ "n" }, "<leader>s", "<Plug>(leap-from-window)", { desc = "leap from window" })
leap.opts.preview_filter = function()
  return false
end
-- s<CR> to traverse forward, s<BS> to traverse backward
vim.keymap.set(
  { "n", "x", "o" },
  "gt",
  'V<cmd>lua require("leap.treesitter").select()<cr>',
  { desc = "select treesitter textobj" }
)

local augend = require("dial.augend")
require("dial.config").augends:register_group({
  default = {
    augend.integer.alias.decimal,
    augend.integer.alias.hex,
    augend.date.alias["%Y-%m-%d"],
    augend.date.alias["%Y/%m/%d"],
    augend.date.alias["%m/%d"],
    augend.date.alias["%H:%M"],
    augend.date.alias["%H:%M:%S"],
    augend.constant.alias.bool,
    augend.constant.new({ elements = { "True", "False" } }),
  },
  visual = {
    augend.integer.alias.decimal,
    augend.integer.alias.hex,
    augend.date.alias["%Y-%m-%d"],
    augend.date.alias["%Y/%m/%d"],
    augend.date.alias["%m/%d"],
    augend.date.alias["%H:%M"],
    augend.date.alias["%H:%M:%S"],
    augend.constant.alias.bool,
    augend.constant.new({ elements = { "True", "False" } }),
  },
})

vim.keymap.set("n", "<C-a>", function()
  require("dial.map").manipulate("increment", "normal")
end)
vim.keymap.set("n", "<C-x>", function()
  require("dial.map").manipulate("decrement", "normal")
end)
vim.keymap.set("v", "<C-a>", function()
  require("dial.map").manipulate("increment", "visual")
end)
vim.keymap.set("v", "<C-x>", function()
  require("dial.map").manipulate("decrement", "visual")
end)

require("mini.ai").setup({
  custom_textobjects = {
    V = {
      {
        "%u[%l%d]+%f[^%l%d]",
        "%f[%S][%l%d]+%f[^%l%d]",
        "%f[%P][%l%d]+%f[^%l%d]",
        "^[%l%d]+%f[^%l%d]",
      },
      "^().*()$",
    },
    v = {
      {
        -- a*aa_bbb "[test_abc_def
        { "[^%w]()()[%w]+()_()" },
        -- a*aa_bb at the start of the line
        { "^()()[%w]+()_()" },
        -- aaa_bbb*_ccc
        { "_()()[%w]+()_()" },
        -- bbb_cc*cc p/dmmp/df_mom_v2.pickle"
        { "()_()[%w]+()()%f[%W]" },
        -- bbb_cc*c at the end of the line
        -- df_univ = pd.read_pickle("./data/df_mom.pickle")
        { "()_()[%w]+()()$" },
      },
    },
  },
})

require("mini.surround").setup({
  mappings = {
    add = "ys",
    delete = "ds",
    find = "",
    find_left = "",
    highlight = '<localleader>s',
    replace = "cs",
    update_n_lines = "",

    -- Add this only if you don't want to use extended mappings
    suffix_last = "",
    suffix_next = "",
  },
  search_method = "cover_or_next",
})

-- Remap adding surrounding to Visual mode selection
vim.keymap.del("x", "ys")
vim.keymap.set("x", "S", [[:<C-u>lua MiniSurround.add('visual')<CR>]], { silent = true })

-- Make special mapping for "add surrounding for line"
vim.keymap.set("n", "yss", "ys_", { remap = true })
