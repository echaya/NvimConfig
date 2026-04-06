local yarepl = require("yarepl")
local repl = require("lua.repl_utils")

local ip_formatter = function(str)
  local first_non_blank_line
  for line in str:gmatch("[^\r\n]+") do
    if line:match("%S") then
      first_non_blank_line = line
      break
    end
  end

  if first_non_blank_line then
    first_non_blank_line = "# " .. first_non_blank_line
  end

  return (first_non_blank_line or "") .. "\n" .. yarepl.source_syntaxes.ipython(str)
end

yarepl.setup({
  scratch = false,
  metas = {
    ipython = {
      cmd = { "ipython", "--no-autoindent" },
      formatter = "bracketed_pasting",
      source_syntax = ip_formatter,
      wincmd = function(bufnr, _)
        local width = math.floor(math.max(vim.o.columns * 0.35, 80))
        local old_splitright = vim.o.splitright
        vim.o.splitright = true
        vim.cmd(string.format("vertical botright %d split", width))
        vim.o.splitright = old_splitright

        local new_win_id = vim.api.nvim_get_current_win()
        vim.api.nvim_win_set_buf(new_win_id, bufnr)
      end,
    },
  },
  highlight_on_send_operator = { enabled = true },
})

local python_repl_group = vim.api.nvim_create_augroup("python-repl-config", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  group = python_repl_group,
  callback = function(args)
    vim.b.CodeFence = "###"

    local is_ipython_repl_active_by_id = function(target_id)
      if not yarepl or not yarepl._repls then
        return false
      end
      local repl_obj = yarepl._repls[target_id]
      return repl_obj
        and repl_obj.name == "ipython"
        and repl_obj.bufnr
        and vim.api.nvim_buf_is_loaded(repl_obj.bufnr)
    end

    local smart_toggle_ipython_repl = function(id)
      -- Accept an explicit ID (e.g., from the restart function) or calculate it
      local target_id = type(id) == "number" and id
        or ((vim.v.count == 0) and vim.fn.tabpagenr() or vim.v.count)

      vim.notify(
        string.format("YAREPL: Toggling/Starting ipython REPL #%d...", target_id),
        vim.log.levels.INFO,
        { title = "REPL Control" }
      )

      vim.cmd(string.format("%dYarepl start_or_focus_or_hide ipython", target_id))
      vim.cmd("wincmd p")

      vim.defer_fn(function()
        vim.cmd("wincmd =")
      end, 50)
    end
    local restart_ipython_repl_entrypoint = function()
      local target_id = (vim.v.count == 0) and vim.fn.tabpagenr() or vim.v.count
      vim.notify(
        string.format("YAREPL: Restarting ipython REPL #%d...", target_id),
        vim.log.levels.INFO,
        { title = "REPL Control" }
      )

      vim.cmd(string.format("%dYarepl exec $ipython exit()", target_id))
      vim.cmd(string.format("%dYarepl close ipython", target_id))
      vim.defer_fn(function()
        smart_toggle_ipython_repl(target_id)
      end, 2500)
    end

    vim.keymap.set(
      "n",
      [[<a-\>]],
      smart_toggle_ipython_repl,
      { buffer = args.buf, desc = "yarepl start attach ipython" }
    )
    vim.keymap.set(
      "n",
      "<localleader>r",
      restart_ipython_repl_entrypoint,
      { buffer = args.buf, desc = "yarepl restart ipython" }
    )
    vim.keymap.set("t", [[<a-\>]], "<cmd>q<cr>", { desc = "yarepl terminal quit window" })

    vim.keymap.set("n", "<localleader><cr>", function()
      local target_id = (vim.v.count == 0) and vim.fn.tabpagenr() or vim.v.count
      vim.cmd(string.format("%dYarepl exec $ipython " .. vim.fn.nr2char(13), target_id))
    end, { buffer = args.buf, desc = "yarepl <cr> ipython" })

    vim.keymap.set("n", "<C-CR>", function()
      local target_id = (vim.v.count == 0) and vim.fn.tabpagenr() or vim.v.count
      if repl.select_visual() then
        vim.cmd(string.format("%dYarepl send_visual ipython", target_id))
        vim.api.nvim_input("<esc>")
        vim.cmd("norm! j")
      end
    end, { buffer = args.buf, desc = "yarepl send cell visual ipython" })

    vim.keymap.set("n", "<S-CR>", function()
      local target_id = (vim.v.count == 0) and vim.fn.tabpagenr() or vim.v.count
      if repl.select_visual() then
        vim.cmd(string.format("%dYarepl source_visual ipython", target_id))
        vim.api.nvim_input("<esc>")
        vim.cmd("norm! j")
      end
    end, { buffer = args.buf, desc = "yarepl source cell visual ipython" })

    vim.keymap.set("n", "<localleader><localleader>", function()
      local target_id = (vim.v.count == 0) and vim.fn.tabpagenr() or vim.v.count
      vim.cmd(string.format("%dYarepl send_operator ipython", target_id))
    end, {
      buffer = args.buf,
      desc = "yarepl send operator",
    })

    vim.keymap.set("n", "<localleader>]", function()
      local count = (vim.v.count == 0) and "" or tostring(vim.v.count)
      return count .. "<localleader><localleader>_"
    end, {
      expr = true,
      remap = true,
      buffer = args.buf,
      desc = "yarepl send current line",
    })

    vim.keymap.set("n", "<localleader>[", function()
      local count = (vim.v.count == 0) and "" or tostring(vim.v.count)
      return count .. "<localleader><localleader>R"
    end, {
      expr = true,
      remap = true,
      buffer = args.buf,
      desc = "yarepl send treesitter object",
    })

    local function create_repl_sender_yarepl(key, desc, command_format_string)
      vim.keymap.set("n", key, function()
        local target_id = (vim.v.count == 0) and vim.fn.tabpagenr() or vim.v.count
        local var_name = vim.fn.expand("<cword>")

        if not var_name or var_name == "" then
          vim.notify("No word under cursor", vim.log.levels.WARN)
          return
        end

        local command_to_send = string.format(command_format_string, var_name)

        -- Use the native `Yarepl exec` command to send strings directly
        vim.cmd(string.format("%dYarepl exec $ipython %s", target_id, command_to_send))
        vim.notify(string.format("Sent: %s", command_to_send), vim.log.levels.INFO)
      end, { buffer = args.buf, desc = desc .. "_ipython" })
    end

    vim.keymap.set(
      "o",
      "p",
      "<nop>",
      { buffer = args.buf, desc = "Disable paragraph motion to favor custom p mappings" }
    )

    create_repl_sender_yarepl("<localleader>pp", "yarepl word", "%s")
    create_repl_sender_yarepl("<localleader>pf", "yarepl first", "%s.iloc[0].T")
    create_repl_sender_yarepl("<localleader>pl", "yarepl last", "%s.iloc[-1].T")
    create_repl_sender_yarepl("<localleader>pi", "yarepl info", "%s.info()")
    create_repl_sender_yarepl("<localleader>pd", "yarepl describe", "%s.describe().T")
    create_repl_sender_yarepl("<localleader>pL", "yarepl length", "len(%s)")
    create_repl_sender_yarepl("<localleader>pt", "yarepl type", "type(%s)")

    vim.keymap.set("n", "<localleader>y", function()
      local target_id = (vim.v.count == 0) and vim.fn.tabpagenr() or vim.v.count

      local var_name = vim.fn.expand("<cword>")
      if not var_name or var_name == "" then
        vim.notify("No variable found under cursor.", vim.log.levels.WARN)
        return
      end

      local command_to_send
      if vim.fn.has("unix") == 1 then
        command_to_send =
          string.format("import linutils.cb_helper; linutils.cb_helper.to_clipboard(%s)", var_name)
      else
        command_to_send = string.format("%s.to_clipboard()", var_name)
      end

      vim.cmd(string.format("%dYarepl exec $ipython %s", target_id, command_to_send))
      vim.notify("Sent to REPL: " .. command_to_send, vim.log.levels.INFO)
    end, { buffer = args.buf, desc = "yarepl df to clipboard os aware ipython" })

    vim.keymap.set("v", "<CR>", function()
      local target_id = (vim.v.count == 0) and vim.fn.tabpagenr() or vim.v.count
      vim.cmd(string.format("%dYarepl send_visual ipython", target_id))
      vim.api.nvim_input("<esc>")
      vim.cmd("norm! j")
    end, { buffer = args.buf, desc = "yarepl v send ipython" })

    vim.keymap.set({ "n", "v" }, "<localleader>u", function()
      local target_id = (vim.v.count == 0) and vim.fn.tabpagenr() or vim.v.count
      local original_cursor_pos = vim.api.nvim_win_get_cursor(0)
      vim.cmd("normal! ggV" .. original_cursor_pos[1] .. "G")
      vim.cmd(string.format("%dYarepl source_visual ipython", target_id))
      vim.api.nvim_input("<esc>")
      vim.api.nvim_win_set_cursor(0, original_cursor_pos)
    end, { buffer = args.buf, desc = "yarepl send until cursor ipython" })

    vim.keymap.set({ "n", "v" }, "<localleader>qq", function()
      local target_id = (vim.v.count == 0) and vim.fn.tabpagenr() or vim.v.count
      vim.cmd(string.format("%dYarepl exec $ipython exit()", target_id))
      vim.cmd(string.format("%dYarepl close ipython", target_id))
    end, { buffer = args.buf, desc = "yarepl exit ipython" })

    vim.keymap.set({ "n", "v" }, "<localleader>c", function()
      local target_id = (vim.v.count == 0) and vim.fn.tabpagenr() or vim.v.count
      vim.cmd(string.format("%dYarepl exec $ipython " .. vim.fn.nr2char(3), target_id))
    end, { buffer = args.buf, desc = "yarepl interrupt ipython" })

    vim.keymap.set({ "n", "v" }, "<a-del>", function()
      local target_id = (vim.v.count == 0) and vim.fn.tabpagenr() or vim.v.count
      vim.cmd(string.format("%dYarepl exec $ipython " .. vim.fn.nr2char(12), target_id))
    end, { buffer = args.buf, desc = "yarepl clear ipython" })

    vim.keymap.set("n", "<localleader>f", function()
      local target_id = (vim.v.count == 0) and vim.fn.tabpagenr() or vim.v.count
      vim.cmd(string.format("%dYarepl focus ipython", target_id))
      vim.cmd("norm! i")
    end, { buffer = args.buf, desc = "yarepl focus insert ipython" })

    vim.keymap.set("n", "]]", function()
      repl.jump_cell()
      vim.cmd("norm! zvzz")
    end, { buffer = args.buf, desc = "yarepl jump cell fwd" })

    vim.keymap.set("n", "[[", function()
      repl.jump_cell_back()
      vim.cmd("norm! zvzz")
    end, { buffer = args.buf, desc = "yarepl jump cell back" })

    vim.keymap.set(
      "n",
      "<localleader>==",
      ":!ruff format %<cr>",
      { buffer = args.buf, desc = "format ruff sync" }
    )
    vim.keymap.set("n", "<Leader>fy", function()
      require("yarepl.extensions.snacks").repl_show()
    end, { buffer = args.buf, desc = "yarepl list repls" })

    local function smart_close_window_with_repl_cleanup()
      local tab_id = vim.fn.tabpagenr()
      local target_tab = vim.g.last_active_tab
      local current_tab = vim.api.nvim_get_current_tabpage()

      local function finalize_close()
        vim.schedule(function()
          pcall(vim.api.nvim_command, "tabc")
          if
            target_tab
            and target_tab ~= current_tab
            and vim.api.nvim_tabpage_is_valid(target_tab)
          then
            pcall(vim.api.nvim_set_current_tabpage, target_tab)
          end
        end)
      end

      if is_ipython_repl_active_by_id(tab_id) then
        local choice = vim.fn.confirm(
          string.format("REPL #%d is active. Close it with the tab?", tab_id),
          "&Yes\n&No",
          2,
          "Question"
        )
        if choice == 1 then
          vim.cmd(string.format("%dYarepl exec $ipython exit()", tab_id))
          vim.defer_fn(function()
            if is_ipython_repl_active_by_id(tab_id) then
              vim.cmd(string.format("%dYarepl close ipython", tab_id))
            end
            finalize_close()
          end, 100)
          return
        end
      end
      finalize_close()
    end
    vim.keymap.set(
      "n",
      "<del>",
      smart_close_window_with_repl_cleanup,
      { buffer = args.buf, desc = "yarepl smart close with cleanup" }
    )
    vim.keymap.set(
      "i",
      ";cb",
      ".to_clipboard()",
      { buffer = true, desc = "insert: .to_clipboard()" }
    )
    vim.keymap.set("i", ";ct", ".copy(True)", { buffer = true, desc = "insert: .copy(True)" })
    vim.keymap.set("i", ";f", "###<CR><Esc>", { buffer = true, desc = "insert: new cell fence" })
    vim.keymap.set("i", ";po", ".iloc[0].T", { buffer = true, desc = "insert:.iloc[0].T" })
    vim.keymap.set("i", ";it", "inplace=True", { buffer = true, desc = "insert: inplace=True" })
    vim.keymap.set("i", ";pl", ".iloc[-1].T", { buffer = true, desc = "insert: .iloc[-1].T" })
    vim.keymap.set("n", "<localleader>db", function()
      repl.debug_cell()
    end, { buffer = true, desc = "create debug cell" })
    vim.keymap.set("n", "<localleader>dd", function()
      repl.debug_delete()
    end, { buffer = true, desc = "delete debug cell and traces" })
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "lua",
  group = vim.api.nvim_create_augroup("lua-repl", { clear = true }),
  callback = function(args)
    vim.b.CodeFence = "--#"
    vim.keymap.set(
      "n",
      "<localleader>f",
      "<cmd>source %<CR>",
      { buffer = args.buf, desc = "execute lua file" }
    )
    vim.keymap.set(
      "n",
      "<localleader>l",
      ":.lua<cr>",
      { buffer = args.buf, desc = "execute lua line" }
    )
    vim.keymap.set("v", "<CR>", ":lua<cr>", { buffer = args.buf, desc = "execute lua line" })
  end,
})

-- Global Keymaps
vim.keymap.set("n", "<localleader>v", function()
  repl.select_visual()
end, { desc = "select visual" })

-- Global Terminal mappings
vim.keymap.set("t", ";cb", ".to_clipboard()", { desc = "terminal: insert .to_clipboard()" })
vim.keymap.set("t", ";po", ".iloc[0].T", { desc = "terminal: insert .iloc[0].T" })
vim.keymap.set("t", ";pl", ".iloc[-1].T", { desc = "terminal: insert .iloc[-1].T" })
