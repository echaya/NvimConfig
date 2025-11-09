vim.keymap.set("n", "<localleader>x", function()
  vim.cmd("!start " .. vim.fn.shellescape(vim.fn.expand("<cfile>"), true))
end, { noremap = true, silent = true, desc = "Open file under cursor in default program" })

-- vim.keymap.set("n", "s", function()
--   require("flash").jump({
--     search = { multi_window = true },
--     jump = { autojump = true },
--   })
-- end, { desc = "Flash" })
-- vim.keymap.set("n", "<localleader><localleader>", function()
--   require("flash").jump({ continue = true })
-- end, { desc = "Flash Continue" })
-- vim.keymap.set({ "x", "o" }, "z", function()
--   require("flash").jump({
--     search = { forward = true, wrap = false, multi_window = false },
--     jump = { pos = "end" },
--   })
-- end, { desc = "Flash Forward (inclusive)" })
-- vim.keymap.set({ "x", "o" }, "Z", function()
--   require("flash").jump({
--     search = { forward = false, wrap = false, multi_window = false },
--     jump = { pos = "start", inclusive = true },
--   })
-- end, { desc = "Flash Backward (inclusive)" })
-- vim.keymap.set({ "n", "x", "o" }, "S", function()
--   require("flash").treesitter()
-- end, { desc = "Flash Treesitter" })
-- vim.keymap.set("o", "r", function()
--   require("flash").remote()
-- end, { desc = "Remote Flash" })
-- vim.keymap.set({ "o", "x" }, "R", function()
--   require("flash").treesitter_search()
-- end, { desc = "Remote Flash Treesitter" })
-- require("flash").setup({
--   modes = { char = { enabled = false } },
-- })

local leap = require("leap")
leap.opts.case_sensitive = true
require("leap").opts.preview = function(ch0, ch1, ch2)
  return not (ch1:match("%s") or (ch0:match("%a") and ch1:match("%a") and ch2:match("%a")))
end
-- Define equivalence classes for brackets and quotes, in addition to <space>
leap.opts.equivalence_classes = { " \t\r\n", "([{", ")]}", "'\"`" }
vim.api.nvim_set_hl(0, "LeapBackdrop", { link = "Comment" })
vim.keymap.set("n", "s", "<Plug>(leap)")
vim.keymap.set("n", "gs", "<Plug>(leap-from-window)")
vim.keymap.set({ "x", "o" }, "z", "<Plug>(leap-forward)", { desc = "leap forward textobj" })
vim.keymap.set({ "x", "o" }, "Z", "<Plug>(leap-backward-till)", { desc = "leap back textobj" })
-- Trigger visual selection right away and visual line mode
vim.keymap.set({ "o" }, "gs", function()
  require("leap.remote").action()
end)
vim.keymap.set({ "o" }, "gS", function()
  require("leap.remote").action({ input = "V" })
end)
require("leap").opts.preview_filter = false
-- <CR> to traverse forward, <BS> to traverse backward
require("leap.user").set_repeat_keys("<enter>", "<backspace>")
vim.keymap.set({ "n" }, "S", function()
  require("leap.treesitter").select()
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
    add = "ys", -- Add surrounding in Normal and Visual modes
    delete = "ds", -- Delete surrounding
    find = "", -- Find surrounding (to the right)
    find_left = "", -- Find surrounding (to the left)
    highlight = "", -- Highlight surrounding
    replace = "cs", -- Replace surrounding
  },
  n_lines = 50,
  search_method = "cover_or_next",
})
vim.keymap.del("x", "ys")
vim.keymap.set("n", "yss", "ys_", { remap = true, desc = "surround add line" })

require("mini.operators").setup({
  replace = {
    -- go paste
    prefix = "gp",
    reindent_linewise = true,
  },
  sort = {
    -- go sort
    prefix = "ga",
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
