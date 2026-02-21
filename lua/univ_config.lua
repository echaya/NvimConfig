-- setup leap
local leap = require("leap")
leap.opts.case_sensitive = true
leap.opts.on_beacons = function(targets, _, _)
  for _, t in ipairs(targets) do
    if t.label and t.beacon then
      t.beacon[1] = 0
    end
  end
end
require("leap").opts.preview = function(ch0, ch1, ch2)
  return not (ch1:match("%s") or (ch0:match("%a") and ch1:match("%a") and ch2:match("%a")))
end
leap.opts.equivalence_classes = { " \t\r\n", "([{", ")]}", "'\"`" }
vim.api.nvim_set_hl(0, "LeapBackdrop", { link = "Comment" })
leap.opts.preview_filter = false
require("leap.user").set_repeat_keys("<enter>", "<backspace>")
-- leap core
vim.keymap.set({ "n", "x" }, "s", "<Plug>(leap)")
vim.keymap.set("n", "S", "<Plug>(leap-from-window)")
vim.keymap.set({ "o" }, "s", function()
  leap.leap({ inclusive = true, offset = 1 })
end, { desc = "leap forward" })
vim.keymap.set({ "o" }, "S", function()
  leap.leap({ inclusive = true, offset = 0, backward = true })
end, { desc = "leap backward" })
-- leap treesitter
vim.keymap.set({ "n", "x", "o" }, "R", function()
  require("leap.treesitter").select({ opts = require("leap.user").with_traversal_keys("R", "r") })
end, { desc = "leap tree sitter" })
-- leap remote
vim.keymap.set({ "o" }, "r", function()
  require("leap.remote").action()
end)

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
})
vim.keymap.set("n", "<C-a>", function()
  require("dial.map").manipulate("increment", "normal")
end)
vim.keymap.set("n", "<C-x>", function()
  require("dial.map").manipulate("decrement", "normal")
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
        -- Use [%a%d] to only match letters and numbers, not the underscore
        -- 1. Middle word (most common case)
        "()_()[%a%d]+()_()",
        -- 2. Last word (at end of line)
        "()_()[%a%d]+()()$",
        -- 3. Last word (followed by non-word/non-underscore char)
        "()_()[%a%d]+()()%f[%W]",
        -- 4. First word (at start of line)
        "^()()[%a%d]+()_()",
        -- 5. First word (after non-word/non-underscore char, like '(')
        "[^%a%d_]()()[%a%d]+()_()", -- Match boundary that ISN'T letter/number/underscore
      },
    },
  },
})

require("mini.surround").setup({
  mappings = {
    add = "yz",
    delete = "dz",
    replace = "cz",
    find = "",
    find_left = "",
    highlight = "gz",
  },
  n_lines = 50,
  search_method = "cover_or_next",
})
pcall(vim.keymap.del, "x", "yz")
vim.keymap.set(
  "x",
  "z",
  [[:<C-u>lua MiniSurround.add('visual')<CR>]],
  { silent = true, desc = "add surrounding to selection" }
)
vim.keymap.set("n", "yzz", "yz_", { remap = true, desc = "add surround _" })
vim.keymap.set("n", "yZ", "yz$", { remap = true, desc = "add surround $" })

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

vim.api.nvim_create_autocmd({ "VimLeavePre" }, {
  group = vim.api.nvim_create_augroup("dump_shada_temp", { clear = true }),
  pattern = { "*" },
  callback = function()
    local status = 0
    for _, f in ipairs(vim.fn.globpath(vim.fn.stdpath("data") .. "/shada", "*tmp*", false, true)) do
      if vim.tbl_isempty(vim.fn.readfile(f)) then
        status = status + vim.fn.delete(f)
      end
    end
    if status ~= 0 then
      vim.notify("Could not delete empty temporary ShaDa files.", vim.log.levels.ERROR)
      vim.fn.getchar()
    end
  end,
  desc = "Delete empty temp ShaDa files",
})
