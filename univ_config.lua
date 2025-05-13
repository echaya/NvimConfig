vim.keymap.set({ "n", "x", "o" }, "m", function()
  require("flash").jump()
end, { desc = "Flash" })
vim.keymap.set({ "n", "x", "o" }, "M", function()
  require("flash").treesitter()
end, { desc = "Flash Treesitter" })
vim.keymap.set("o", "r", function()
  require("flash").remote()
end, { desc = "Remote Flash" })
vim.keymap.set({ "o", "x" }, "R", function()
  require("flash").treesitter_search()
end, { desc = "Treesitter Search" })
vim.keymap.set({ "c" }, "<c-s>", function()
  require("flash").toggle()
end, { desc = "Toggle Flash Search" })

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

require("mini.surround").setup({ n_lines = 50, search_method = "cover_or_next" })
vim.keymap.set("n", "S", "sa_", { remap = true, desc = "surround add line" })

require("mini.operators").setup({
  replace = {
    prefix = "gp",
    reindent_linewise = true,
  },
  sort = {
    prefix = "ga",
  },
  multiply = {
    prefix = "",
  },
})
-- g= for evaluation,
-- gp for paste from (registery),
-- ga for alphabetical,
-- gx for exchange
