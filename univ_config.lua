local leap = require("leap")
leap.opts.case_sensitive = true
-- Define equivalence classes for brackets and quotes, in addition to <space>
leap.opts.equivalence_classes = { " \t\r\n", "([{", ")]}", "'\"`" }
vim.api.nvim_set_hl(0, "LeapBackdrop", { link = "Comment" })
vim.keymap.set("n", "m", "<Plug>(leap)")
vim.keymap.set("n", "M", "<Plug>(leap-from-window)")
vim.keymap.set({ "x", "o" }, "m", "<Plug>(leap-forward-to)", { desc = "leap forward textobj" })
vim.keymap.set({ "x", "o" }, "M", "<Plug>(leap-backward-to)", { desc = "leap back textobj" })
-- Trigger visual selection right away and visual line mode
vim.keymap.set({ "n", "o" }, "gm", function()
  require("leap.remote").action({ input = "v" })
end)
vim.keymap.set({ "n", "o" }, "gM", function()
  require("leap.remote").action({ input = "V" })
end)

require("leap").opts.preview_filter = false
-- <CR> to traverse forward, <BS> to traverse backward
require("leap.user").set_repeat_keys("<enter>", "<backspace>")
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
