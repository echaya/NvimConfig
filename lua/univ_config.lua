vim.keymap.set("n", "m", function()
  require("flash").jump({
    search = { multi_window = true },
    jump = { autojump = true },
  })
end, { desc = "Flash" })
vim.keymap.set("n", "<localleader><localleader>", function()
  require("flash").jump({ continue = true })
end, { desc = "Flash Continue" })
vim.keymap.set({ "x", "o" }, "m", function()
  require("flash").jump({
    search = { forward = true, wrap = false, multi_window = false },
    jump = { pos = "end" },
  })
end, { desc = "Flash Forward (inclusive)" })
vim.keymap.set({ "x", "o" }, "M", function()
  require("flash").jump({
    search = { forward = false, wrap = false, multi_window = false },
    jump = { pos = "start", inclusive = true },
  })
end, { desc = "Flash Backward (inclusive)" })
vim.keymap.set({ "n", "x", "o" }, "M", function()
  require("flash").treesitter()
end, { desc = "Flash Treesitter" })
vim.keymap.set("o", "r", function()
  require("flash").remote()
end, { desc = "Remote Flash" })
vim.keymap.set({ "o", "x" }, "R", function()
  require("flash").treesitter_search()
end, { desc = "Remote Flash Treesitter" })
require("flash").setup({
  modes = { char = { enabled = false } },
})

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

local gen_ai_spec = require("mini.extra").gen_ai_spec
require("mini.ai").setup({
  custom_textobjects = {
    B = gen_ai_spec.buffer(),
    N = gen_ai_spec.number(),
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
vim.keymap.set("n", "S", "sa$", { remap = true, desc = "surround add til end" })
vim.keymap.set("n", "ss", "sa_", { remap = true, desc = "surround add line" })

require("mini.operators").setup({
  replace = {
    -- go paste
    prefix = "gp",
    reindent_linewise = true,
  },
  sort = {
    -- go sort
    prefix = "gs",
  },
  multiply = {
    prefix = "",
  },
  evaluate = {
    -- go =
    prefix = "g=",
  },
  exchange = {
    -- go exchange
    prefix = "gx",
    reindent_linewise = true,
  },
})
