local yarepl = require("yarepl")
local repl = require("lua.repl_utils")

local ip_formatter = function(str)
  local first_non_blank_line

  for line in str:gmatch("[^\r\n]+") do
    -- str_pre_formating.match with '%S' checks if the line contains any non-whitespace character
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
  -- buflisted = true, -- Default, REPL buffer will appear in buffer list
  scratch = false, -- Default true, REPL buffer is a scratch buffer
  -- ft = 'REPL', -- Default filetype for REPL buffer
  close_on_exit = true, -- Default, closes window when REPL process exits
  scroll_to_bottom_after_sending = true, -- Default
  -- format_repl_buffers_names = true, -- Default

  metas = {
    ipython = {
      cmd = { "ipython", "--no-autoindent" },
      formatter = "bracketed_pasting", -- Maps to iron's bracketed_paste
      source_syntax = ip_formatter, -- Useful for REPLSourceVisual/Operator if you use them
      wincmd = function(bufnr, _)
        local width = math.floor(math.max(vim.o.columns * 0.35, 80))
        local old_splitright = vim.o.splitright
        vim.o.splitright = true
        vim.cmd(string.format("vertical botright %d split", width))
        vim.o.splitright = old_splitright

        local new_win_id = vim.api.nvim_get_current_win() -- new split becomes current
        vim.api.nvim_win_set_buf(new_win_id, bufnr)
      end,
    },
  },
})

-- Autocmd to set up Python-specific keybindings
vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  group = vim.api.nvim_create_augroup("python-repl-yarepl", { clear = true }),
  callback = function(args)
    vim.b.CodeFence = "###"
    local function get_yarepl_module()
      local status_ok, yarepl = pcall(require, "yarepl")
      if not status_ok then
        vim.notify(
          "yarepl.nvim plugin is not available or not yet loaded.",
          vim.log.levels.ERROR,
          { title = "REPL Control" }
        )
        return nil
      end
      return yarepl
    end

    local is_ipython_repl_active_by_id = function(target_id)
      local yarepl = get_yarepl_module()
      if not yarepl or not yarepl._repls then
        return false
      end

      local api = vim.api
      local repl_obj = yarepl._repls[target_id]

      if repl_obj and repl_obj.name == "ipython" then
        if repl_obj.bufnr and api.nvim_buf_is_loaded(repl_obj.bufnr) then
          return true
        end
      end
      return false
    end

    local start_ipython_repl_by_id = function(target_id)
      vim.notify(
        string.format("YAREPL: Starting ipython REPL #%d...", target_id),
        vim.log.levels.INFO,
        { title = "REPL Control" }
      )
      vim.cmd(string.format("%dREPLStart! ipython", target_id))
      vim.cmd("wincmd p")
      vim.defer_fn(function()
        vim.cmd("wincmd =")
      end, 50)
    end

    local toggle_ipython_repl_visibility_by_id = function(target_id)
      vim.notify(
        string.format("YAREPL: Toggling ipython REPL #%d visibility/focus...", target_id),
        vim.log.levels.INFO,
        { title = "REPL Control" }
      )
      vim.cmd(string.format("%dREPLHideOrFocus ipython", target_id))
      vim.cmd("wincmd p")
      vim.defer_fn(function()
        vim.cmd("wincmd =")
      end, 50)
    end

    local smart_toggle_ipython_repl_entrypoint = function()
      local target_id = (vim.v.count == 0) and vim.fn.tabpagenr() or vim.v.count

      if is_ipython_repl_active_by_id(target_id) then
        toggle_ipython_repl_visibility_by_id(target_id)
      else
        start_ipython_repl_by_id(target_id)
      end
    end

    local restart_ipython_repl_entrypoint = function()
      local target_id = (vim.v.count == 0) and vim.fn.tabpagenr() or vim.v.count

      vim.notify(
        string.format("YAREPL: Restarting ipython REPL #%d...", target_id),
        vim.log.levels.INFO,
        { title = "REPL Control" }
      )

      vim.cmd(string.format("%dREPLExec $ipython exit()", target_id))
      vim.cmd(string.format("%dREPLClose ipython", target_id))
      vim.defer_fn(function()
        start_ipython_repl_by_id(target_id)
      end, 2500)
    end

    vim.keymap.set(
      "n",
      [[<a-\>]],
      smart_toggle_ipython_repl_entrypoint,
      { buffer = args.buf, desc = "yarepl_start_attach_ipython" }
    )

    vim.keymap.set(
      "n",
      "<localleader>r",
      restart_ipython_repl_entrypoint,
      { buffer = args.buf, desc = "yarepl_restart_ipython" }
    )

    vim.keymap.set("t", [[<a-\>]], "<cmd>q<cr>", { desc = "yarepl_terminal_quit_window" }) -- This is for the terminal window itself

    vim.keymap.set("n", "<localleader><cr>", function()
      local target_id = (vim.v.count == 0) and vim.fn.tabpagenr() or vim.v.count
      vim.cmd(string.format("%dREPLExec $ipython " .. vim.fn.nr2char(13), target_id))
    end, { buffer = args.buf, desc = "yarepl_cr_ipython" })

    vim.keymap.set("n", "<C-CR>", function()
      local target_id = (vim.v.count == 0) and vim.fn.tabpagenr() or vim.v.count
      repl.select_visual()
      vim.cmd(string.format("%dREPLSendVisual ipython", target_id))
      vim.api.nvim_input("<esc>")
      vim.cmd("norm! j")
    end, { buffer = args.buf, desc = "yarepl_send_cell_visual_ipython" })

    vim.keymap.set("n", "<S-CR>", function()
      local target_id = (vim.v.count == 0) and vim.fn.tabpagenr() or vim.v.count
      repl.select_visual()
      vim.cmd(string.format("%dREPLSourceVisual ipython", target_id))
      vim.api.nvim_input("<esc>")
      vim.cmd("norm! j") -- Original behavior: move cursor down one line
    end, { buffer = args.buf, desc = "yarepl_source_cell_visual_ipython" })

    vim.keymap.set("n", "<localleader>y", function()
      local target_id = (vim.v.count == 0) and vim.fn.tabpagenr() or vim.v.count
      local original_cursor_pos = vim.api.nvim_win_get_cursor(0)
      local current_line_1_indexed = original_cursor_pos[1]
      local var_name = vim.fn.expand("<cword>")
      if not var_name or var_name == "" then
        vim.notify("No word under cursor.", vim.log.levels.WARN)
        return
      end

      local command_to_send
      if vim.fn.has("unix") == 1 then
        command_to_send =
          string.format("import linutils.cb_helper; linutils.cb_helper.to_clipboard(%s)", var_name)
        vim.notify("Using linutils.cb_helper.to_clipboard()", vim.log.levels.INFO)
      else
        command_to_send = string.format("%s.to_clipboard()", var_name)
        vim.notify("Using default .to_clipboard()", vim.log.levels.INFO)
      end

      -- This complex buffer manipulation logic remains the same
      vim.api.nvim_buf_set_lines(
        args.buf,
        current_line_1_indexed,
        current_line_1_indexed,
        false,
        { command_to_send }
      )
      vim.api.nvim_win_set_cursor(0, { current_line_1_indexed + 1, 0 })
      vim.cmd("normal! V")
      vim.cmd(string.format("%dREPLSendVisual ipython", target_id))
      vim.api.nvim_input("<esc>")
      vim.notify(string.format("Sent to REPL: %s", command_to_send), vim.log.levels.INFO)
      vim.api.nvim_buf_set_lines(
        args.buf,
        current_line_1_indexed,
        current_line_1_indexed + 1,
        false,
        {}
      )
      vim.api.nvim_win_set_cursor(0, original_cursor_pos)
    end, { buffer = args.buf, desc = "yarepl_df_to_clipboard_os_aware_ipython" })

    local function create_repl_sender_yarepl(key, desc, command_format_string)
      vim.keymap.set("n", key, function()
        local target_id = (vim.v.count == 0) and vim.fn.tabpagenr() or vim.v.count
        local original_cursor_pos = vim.api.nvim_win_get_cursor(0)
        local current_line_1_indexed = original_cursor_pos[1]
        local var_name = vim.fn.expand("<cword>")
        if not var_name or var_name == "" then
          vim.notify("No word under cursor", vim.log.levels.WARN)
          return
        end
        local command_to_send = string.format(command_format_string, var_name)
        -- Buffer manipulation logic remains the same
        vim.api.nvim_buf_set_lines(
          args.buf,
          current_line_1_indexed,
          current_line_1_indexed,
          false,
          { command_to_send }
        )
        vim.api.nvim_win_set_cursor(0, { current_line_1_indexed + 1, 0 })
        vim.cmd("normal! V")
        vim.cmd(string.format("%dREPLSendVisual ipython", target_id))
        vim.api.nvim_input("<esc>")
        vim.notify(string.format("Sent: %s", command_to_send), vim.log.levels.INFO)
        vim.api.nvim_buf_set_lines(
          args.buf,
          current_line_1_indexed,
          current_line_1_indexed + 1,
          false,
          {}
        )
        vim.api.nvim_win_set_cursor(0, original_cursor_pos)
      end, { buffer = args.buf, desc = desc .. "_ipython" })
    end

    create_repl_sender_yarepl("<localleader>pp", "yarepl_print", "print(%s)")
    create_repl_sender_yarepl("<localleader>pl", "yarepl_print_last", "print(%s.iloc[-1].T)")
    create_repl_sender_yarepl("<localleader>pf", "yarepl_print_first", "print(%s.iloc[0].T)")
    create_repl_sender_yarepl("<localleader>pi", "yarepl_print_info", "print(%s.info())")

    vim.keymap.set("v", "<CR>", function()
      local target_id = (vim.v.count == 0) and vim.fn.tabpagenr() or vim.v.count
      vim.cmd(string.format("%dREPLSendVisual ipython", target_id))
      vim.api.nvim_input("<esc>")
      vim.cmd("norm! j")
    end, { buffer = args.buf, desc = "yarepl_v_send_ipython" })

    vim.keymap.set({ "n", "v" }, "<localleader>u", function()
      local target_id = (vim.v.count == 0) and vim.fn.tabpagenr() or vim.v.count
      local original_cursor_pos = vim.api.nvim_win_get_cursor(0) -- [line, col], line is 1-indexed
      local select_cmd = "normal! ggV" .. original_cursor_pos[1] .. "G"
      vim.cmd(select_cmd) -- Execute the selection command
      vim.cmd(string.format("%dREPLSourceVisual ipython", target_id))
      vim.api.nvim_input("<esc>")
      vim.api.nvim_input("<ESC>") -- Exit visual mode
      vim.api.nvim_win_set_cursor(0, original_cursor_pos) -- Restore cursor to its original position
    end, { buffer = args.buf, desc = "yarepl_send_until_cursor_ipython" })

    vim.keymap.set({ "n", "v" }, "<localleader>qq", function()
      -- To make ipython exit, send 'exit()' or 'quit()'
      local target_id = (vim.v.count == 0) and vim.fn.tabpagenr() or vim.v.count
      vim.cmd(string.format("%dREPLExec $ipython exit()", target_id))
      vim.cmd(string.format("%dREPLClose ipython", target_id))
    end, { buffer = args.buf, desc = "yarepl_exit_ipython" })

    vim.keymap.set({ "n", "v" }, "<localleader>c", function()
      -- Send Ctrl-C (ASCII 03)
      local target_id = (vim.v.count == 0) and vim.fn.tabpagenr() or vim.v.count
      vim.cmd(string.format("%dREPLExec $ipython " .. vim.fn.nr2char(3), target_id))
    end, { buffer = args.buf, desc = "yarepl_interrupt_ipython" })

    vim.keymap.set({ "n", "v" }, "<a-del>", function()
      local target_id = (vim.v.count == 0) and vim.fn.tabpagenr() or vim.v.count
      vim.cmd(string.format("%dREPLExec $ipython " .. vim.fn.nr2char(12), target_id))
    end, { buffer = args.buf, desc = "yarepl_clear_ipython" })

    vim.keymap.set("n", "<localleader>]", function()
      local target_id = (vim.v.count == 0) and vim.fn.tabpagenr() or vim.v.count
      vim.cmd(string.format("%dREPLFocus ipython", target_id))
      vim.cmd("norm! i")
    end, { buffer = args.buf, desc = "yarepl_focus_insert_ipython" })

    vim.keymap.set("n", "]]", function()
      repl.jump_cell()
      vim.cmd("norm! zvzz")
    end, { buffer = args.buf, desc = "yarepl_jump_cell_fwd" })

    vim.keymap.set("n", "[[", function()
      repl.jump_cell_back()
      vim.cmd("norm! zvzz")
    end, { buffer = args.buf, desc = "yarepl_jump_cell_back" })

    vim.keymap.set(
      "n",
      "<localleader>==",
      ":!ruff format %<cr>",
      { buffer = args.buf, desc = "format_ruff_sync" }
    )
    vim.keymap.set("n", "<Leader>fy", function()
      require("yarepl.extensions.snacks").repl_show()
    end, { buffer = args.buf, desc = "yarepl_list_repls" })

    local function smart_close_window_with_repl_cleanup()
      local tab_id = vim.fn.tabpagenr()

      if is_ipython_repl_active_by_id(tab_id) then
        -- REPL is active, ask for confirmation
        local message = string.format("REPL #%d is active. Close it with the tab?", tab_id)

        local choice = vim.fn.confirm(message, "&Yes\n&No", 2, "Question")
        if choice == 1 then -- 1 == Yes
          vim.cmd(string.format("%dREPLExec $ipython exit()", tab_id))
          vim.defer_fn(function()
            if is_ipython_repl_active_by_id(tab_id) then
              vim.cmd(string.format("%dREPLClose ipython", tab_id))
            end
          end, 100)
        end
        -- No REPL is active, just quit the window/tab as normal.
      end
      vim.cmd("tabc")
    end

    vim.keymap.set(
      "n",
      "<del>",
      smart_close_window_with_repl_cleanup,
      { buffer = args.buf, desc = "yarepl_smart_close_with_cleanup" }
    )
  end,
})

--#
-- in cmdline use :lua =XYZ to shorthand :lua print(XYZ)
vim.api.nvim_create_autocmd("FileType", {
  pattern = "lua",
  group = vim.api.nvim_create_augroup("lua-repl", { clear = true }),
  callback = function(args)
    vim.b.CodeFence = "--#"
    vim.keymap.set(
      "n",
      "<localleader><localleader>f",
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

--#

vim.keymap.set("n", "<localleader>v", function()
  repl.select_visual()
end, { desc = "Select visual" })

-- Define the autocmd group, ensuring it's cleared on each reload
local python_repl_group = vim.api.nvim_create_augroup("PythonRepl", { clear = true })

-- Create an autocmd that triggers for Python files
vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  group = python_repl_group,
  desc = "Set up Python-specific settings and REPL keymaps",
  callback = function()
    -- Set a buffer-local variable, equivalent to `let b:CodeFence = "###"`

    -- Buffer-local insert mode mappings (snippets)
    vim.keymap.set(
      "i",
      ";cb",
      ".to_clipboard()",
      { buffer = true, desc = "Insert: .to_clipboard()" }
    )
    vim.keymap.set("i", ";ct", ".copy(True)", { buffer = true, desc = "Insert: .copy(True)" })
    vim.keymap.set("i", ";f", "###<CR><Esc>", { buffer = true, desc = "Insert: New cell fence" })
    vim.keymap.set("i", ";pf", ".iloc[0].T", { buffer = true, desc = "Insert:.iloc[0].T" })
    vim.keymap.set("i", ";it", "inplace=True", { buffer = true, desc = "Insert: inplace=True" })
    vim.keymap.set("i", ";pl", ".iloc[-1].T", { buffer = true, desc = "Insert: .iloc[-1].T" })
    vim.keymap.set("n", "<localleader>db", function()
      repl.debug_cell()
    end, { buffer = true, desc = "Create debug cell" })
    vim.keymap.set("n", "<localleader>dd", function()
      repl.debug_delete()
    end, { buffer = true, desc = "Delete debug cell and traces" })
  end,
})

-- Global terminal mode mappings (not tied to any filetype)
vim.keymap.set("t", ";cb", ".to_clipboard()", { desc = "Terminal: Insert .to_clipboard()" })
vim.keymap.set("t", ";pf", ".iloc[0].T", { desc = "Terminal: Insert .iloc[0].T" })
vim.keymap.set("t", ";pl", ".iloc[-1].T", { desc = "Terminal: Insert .iloc[-1].T" })
