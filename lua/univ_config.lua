vim.keymap.set("n", "<localleader>x", function()
  vim.cmd("!start " .. vim.fn.shellescape(vim.fn.expand("<cfile>"), true))
end, { noremap = true, silent = true, desc = "Open file under cursor in default program" })

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
vim.keymap.set("n", "s", "<Plug>(leap)")
vim.keymap.set("n", "S", "<Plug>(leap-from-window)")
vim.keymap.set({ "o" }, "z", function()
  leap.leap({ inclusive = true, offset = 1 })
end, { desc = "leap forward" })
vim.keymap.set({ "o" }, "Z", function()
  leap.leap({ inclusive = true, offset = 0, backward = true })
end, { desc = "leap backward" })
-- leap treesitter
vim.keymap.set({ "x", "o" }, "S", function()
  require("leap.treesitter").select()
end, { desc = "leap tree sitter" })
-- leap remote
vim.keymap.set({ "o" }, "r", function()
  require("leap.remote").action()
end)
vim.keymap.set({ "o" }, "R", function()
  require("leap.remote").action({ input = "V" })
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
    add = "<leader>sa", -- Add surrounding in Normal and Visual modes
    delete = "<leader>sd", -- Delete surrounding
    find = "<leader>sf", -- Find surrounding (to the right)
    find_left = "<leader>sF", -- Find surrounding (to the left)
    highlight = "<leader>sh", -- Highlight surrounding
    replace = "<leader>sr", -- Replace surrounding
    suffix_last = "",
    suffix_next = "",
  },
  n_lines = 50,
  search_method = "cover_or_next",
})
vim.keymap.set("n", "<leader>ss", "<leader>sa_", { remap = true, desc = "Add surround _" })
vim.keymap.set("n", "<leader>S", "<leader>sa$", { remap = true, desc = "Add surround $" })
vim.keymap.set(
  "x",
  "S",
  [[:<C-u>lua MiniSurround.add('visual')<CR>]],
  { silent = true, desc = "Add surrounding to selection" }
)

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
