require("mini.basics").setup({
  options = { extra_ui = true },
  mappings = { windows = true, option_toggle_prefix = "|" },
})

local icon = require("mini.icons")
icon.setup()
icon.mock_nvim_web_devicons()
vim.g.nvim_web_devicons = 1

local function resolve_path(path)
  if not path or path == "" then
    return nil
  end
  local expanded = vim.fn.fnamemodify(path, ":p")
  local real = vim.uv.fs_realpath(expanded) or expanded

  if vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1 then
    real = real:lower()
    real = real:gsub("\\", "/")
  end

  if #real > 1 and real:sub(-1) == "/" then
    real = real:sub(1, -2)
  end

  return real
end

local function get_git_root(buf_id)
  local ok, root = pcall(vim.fn.FugitiveWorkTree, buf_id)
  if ok and root and #root > 0 and vim.fn.isdirectory(root) == 1 then
    return resolve_path(root)
  end
  return nil
end

local function close_buffers_outside_context()
  local FORCE_DELETE = false
  local current_buf = vim.api.nvim_get_current_buf()

  local target_dir = get_git_root(current_buf)

  if not target_dir then
    local buf_dir = vim.fn.expand("%:p:h")
    if buf_dir ~= "" then
      target_dir = resolve_path(buf_dir)
    else
      target_dir = resolve_path(vim.fn.getcwd())
    end
  end

  if not target_dir then
    return
  end

  -- Ensure trailing slash for directory matching logic
  local target_matcher = target_dir .. "/"

  -- 2. Efficient Loop & Filter
  local buffers = vim.api.nvim_list_bufs()
  local closed_names = {} -- Store names for notification
  local kept_count = 0

  for _, buf_id in ipairs(buffers) do
    -- A. Skip Current Buffer
    if buf_id == current_buf then
      goto continue
    end

    -- B. Skip Unlisted & Special Buffers
    if not vim.api.nvim_get_option_value("buflisted", { buf = buf_id }) then
      goto continue
    end
    if vim.api.nvim_get_option_value("buftype", { buf = buf_id }) ~= "" then
      goto continue
    end

    -- C. Get Name and Filter Protocols
    local buf_name = vim.api.nvim_buf_get_name(buf_id)
    if buf_name == "" or buf_name:match("^%w+://") then
      goto continue
    end

    -- D. Resolve Path (Expensive step, done last)
    local buf_path = resolve_path(buf_name)

    -- E. Check Scope
    if buf_path and not string.find(buf_path, "^" .. vim.pesc(target_matcher)) then
      local is_modified = vim.api.nvim_get_option_value("modified", { buf = buf_id })

      if is_modified and not FORCE_DELETE then
        kept_count = kept_count + 1
      else
        local success, err = pcall(vim.api.nvim_buf_delete, buf_id, { force = FORCE_DELETE })
        if success then
          table.insert(closed_names, "• " .. buf_name)
        else
          vim.notify("Failed to close " .. buf_name .. ": " .. tostring(err), vim.log.levels.ERROR)
        end
      end
    end
    ::continue::
  end

  -- 3. Notification
  if #closed_names > 0 then
    vim.notify(
      string.format(
        "Scope: %s\nClosed %d buffers:\n%s",
        target_dir,
        #closed_names,
        table.concat(closed_names, "\n")
      ),
      vim.log.levels.INFO
    )
  elseif kept_count > 0 then
    vim.notify(
      string.format("Scope: %s\nKept %d unsaved buffers", target_dir, kept_count),
      vim.log.levels.WARN
    )
  else
    vim.notify("Workspace clean.", vim.log.levels.INFO)
  end
end

vim.keymap.set("n", "<leader>bD", close_buffers_outside_context, {
  desc = "close buffers not in current Git repo",
  silent = true,
})

local git_cache = {}
local repo_fetch_state = {}
local icons = { branch = "", ahead = "", behind = "", no_upstream = "☁" }
local FETCH_COOLDOWN = 180

local function update_render_string(data)
  local parts = {}
  local head_limiter = 15
  local head_name = data.head or ""
  if #head_name > head_limiter then
    head_name = head_name:sub(1, head_limiter) .. "…"
  end
  table.insert(parts, string.format("%s %s", icons.branch, head_name))

  if data.has_upstream then
    if (data.ahead or 0) > 0 then
      table.insert(parts, string.format("%s%d", icons.ahead, data.ahead))
    end
    if (data.behind or 0) > 0 then
      table.insert(parts, string.format("%s%d", icons.behind, data.behind))
    end
  else
    table.insert(parts, icons.no_upstream)
  end

  data.render = table.concat(parts, " ")
end

local function fetch_git_counts(buf_id, from_fetch)
  local data = git_cache[buf_id]
  if not data or not data.root then
    return
  end

  if data.job_id then
    pcall(vim.fn.jobstop, data.job_id)
  end

  local stdout_data = {}
  local job_id = vim.fn.jobstart(
    { "git", "rev-list", "--count", "--left-right", "HEAD...@{upstream}" },
    {
      cwd = data.root,
      stdout_buffered = true,
      on_stdout = function(_, output)
        stdout_data = output
      end,
      on_exit = vim.schedule_wrap(function(this_job_id, code, _)
        if
          not vim.api.nvim_buf_is_valid(buf_id)
          or not git_cache[buf_id]
          or git_cache[buf_id].job_id ~= this_job_id
        then
          return
        end
        git_cache[buf_id].job_id = nil

        local new_ahead = 0
        local new_behind = 0
        local has_upstream = false

        if code == 0 then
          local result = (stdout_data and stdout_data[1]) or ""
          local a, b = result:match("(%d+)%s+(%d+)")
          new_ahead = tonumber(a) or 0
          new_behind = tonumber(b) or 0
          has_upstream = true
        end
        if
          from_fetch
          and buf_id == vim.api.nvim_get_current_buf()
          and git_cache[buf_id].has_upstream ~= nil
        then
          local old_behind = git_cache[buf_id].behind or 0
          local old_ahead = git_cache[buf_id].ahead or 0

          if new_behind ~= old_behind then
            local repo_name = vim.fn.fnamemodify(data.root, ":t")
            local diff_count = new_behind - old_behind
            vim.notify(
              string.format(
                "%s Git Update Detected\nRepo:   %s\nBranch: %s\n%s Incoming: %d (new %d)\n%s Outgoing: %d",
                icons.sync,
                repo_name,
                data.head,
                icons.behind,
                new_behind,
                diff_count,
                icons.ahead,
                new_ahead
              ),
              vim.log.levels.INFO
            )
          elseif new_behind ~= old_behind or new_ahead ~= old_ahead then
            -- vim.notify("Git status updated", vim.log.levels.INFO)
          end
        end

        git_cache[buf_id].has_upstream = has_upstream
        git_cache[buf_id].ahead = new_ahead
        git_cache[buf_id].behind = new_behind

        update_render_string(git_cache[buf_id])
        vim.cmd("redrawstatus")
      end),
    }
  )
  git_cache[buf_id].job_id = job_id
end

-- 3. Async Remote Fetch
local function fetch_git_remote(buf_id)
  local data = git_cache[buf_id]
  if not data or not data.root then
    return
  end

  local cwd = data.root
  local now = os.time()
  local last_fetch = repo_fetch_state[cwd] or 0

  if (now - last_fetch) < FETCH_COOLDOWN then
    return
  end

  repo_fetch_state[cwd] = now

  vim.fn.jobstart({ "git", "fetch", "--no-tags", "--quiet" }, {
    cwd = cwd,
    on_exit = function(_, code)
      if code == 0 then
        vim.schedule(function()
          for b_id, cache in pairs(git_cache) do
            if vim.api.nvim_buf_is_valid(b_id) and cache.root == cwd then
              fetch_git_counts(b_id, true)
            end
          end
        end)
      end
    end,
  })
end

local function update_git_status(buf_id)
  buf_id = buf_id or vim.api.nvim_get_current_buf()
  if not vim.api.nvim_buf_is_valid(buf_id) or vim.api.nvim_buf_get_name(buf_id) == "" then
    return
  end

  local head = vim.fn.FugitiveHead(buf_id)
  if head == "" then
    git_cache[buf_id] = nil
    return
  end

  if not git_cache[buf_id] then
    local root = get_git_root(buf_id)
    if not root then
      return
    end
    git_cache[buf_id] = { head = head, root = root, has_upstream = nil }
  else
    git_cache[buf_id].head = head
  end

  update_render_string(git_cache[buf_id])

  if git_cache[buf_id].timer then
    git_cache[buf_id].timer:stop()
    git_cache[buf_id].timer:close()
  end
  git_cache[buf_id].timer = vim.uv.new_timer()
  git_cache[buf_id].timer:start(
    20,
    0,
    vim.schedule_wrap(function()
      if git_cache[buf_id] and vim.api.nvim_buf_is_valid(buf_id) then
        git_cache[buf_id].timer = nil
        fetch_git_counts(buf_id, false)
        fetch_git_remote(buf_id)
      end
    end)
  )
end

-- Setup Autocommands
local grp_git = vim.api.nvim_create_augroup("LocalGitStatus", { clear = true })

vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "FocusGained" }, {
  group = grp_git,
  pattern = "*",
  callback = function(args)
    update_git_status(args.buf)
  end,
})

vim.api.nvim_create_autocmd("BufWipeout", {
  group = grp_git,
  pattern = "*",
  callback = function(args)
    local data = git_cache[args.buf]
    if data then
      if data.job_id then
        pcall(vim.fn.jobstop, data.job_id)
      end
      if data.timer then
        data.timer:stop()
        data.timer:close()
      end
      git_cache[args.buf] = nil
    end
  end,
})

vim.api.nvim_create_user_command("GFetch", function()
  local buf = vim.api.nvim_get_current_buf()
  if git_cache[buf] and git_cache[buf].root then
    repo_fetch_state[git_cache[buf].root] = 0
  end
  update_git_status(buf)
end, {})

-- Exposed Global
local get_git_status_string = function()
  local buf = vim.api.nvim_get_current_buf()
  return (git_cache[buf] and git_cache[buf].render) or ""
end

local MiniStatusline = require("mini.statusline")
MiniStatusline.setup({
  content = {
    active = function()
      local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 10000 })
      local git = get_git_status_string()
      local diff = MiniStatusline.section_diff({ trunc_width = 75 })
      local diagnostics = MiniStatusline.section_diagnostics({ trunc_width = 75 })
      local lsp = MiniStatusline.section_lsp({ trunc_width = 75 })
      local filename = MiniStatusline.section_filename({ trunc_width = 300 })
      local fileinfo = MiniStatusline.section_fileinfo({ trunc_width = 300 })
      local showcmd = "%S"
      local search = MiniStatusline.section_searchcount({ trunc_width = 75 })
      return MiniStatusline.combine_groups({
        { hl = mode_hl, strings = { mode } },
        { hl = "MiniStatuslineDevinfo", strings = { git, diff, diagnostics } },
        "%<", -- Mark general truncate point
        { hl = "MiniStatuslineFilename", strings = { filename } },
        "%=", -- End left alignment
        { strings = { showcmd } },
        { hl = "MiniStatuslineFileinfo", strings = { search, fileinfo, lsp } },
        { hl = mode_hl, strings = { tostring(vim.api.nvim_buf_line_count(0)) } },
      })
    end,
  },
})

local MiniStarter = require("mini.starter")
MiniStarter.setup({
  evaluate_single = true,
  items = {
    -- starter.sections.sessions(10, true),
    -- starter.sections.recent_files(10, false),
    -- starter.sections.builtin_actions(),
    {
      action = "lua MiniSessions.read(MiniSessions.get_latest())",
      name = "Latest",
      section = "Sessions",
    },
    { action = "lua MiniSessions.select('read')", name = "Saved", section = "Sessions" },
    {
      action = "lua MiniSessions.select('delete')",
      name = "Delete",
      section = "Sessions",
    },
    { action = "lua MiniFiles.open()", name = "Explorer", section = "File Picker" },
    {
      action = "lua require('snacks').picker.files()",
      name = "Find files",
      section = "File Picker",
    },
    {
      action = "lua require('snacks').picker.recent()",
      name = "Recent files",
      section = "File Picker",
    },
    { action = "DepsUpdate", name = "Update", section = "Plugin" },
    { action = "DepsClean", name = "Purge", section = "Plugin" },
    { action = "GithubSync", name = "GithubSync", section = "Plugin" },
    { action = "CopySo", name = "CopySo", section = "Plugin" },
    { action = "enew", name = "New buffer", section = "Builtin actions" },
    { action = "qall!", name = "Quit neovim", section = "Builtin actions" },
  },
  content_hooks = {
    MiniStarter.gen_hook.adding_bullet(),
    MiniStarter.gen_hook.padding(vim.o.columns * 0.4, vim.o.lines * 0.25),
  },
  footer = os.date(),
  header = table.concat({
    [[
███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝]],
  }, "\n"),
  query_updaters = [[abcdefghilmnopqrstuvwxyz0123456789_-,.ABCDEFGHILMNOPQRSTUVWXYZ]],
})
vim.cmd([[
  augroup MiniStarterJK
    au!
    au User MiniStarterOpened nmap <buffer> j <Cmd>lua MiniStarter.update_current_item('next')<CR>
    au User MiniStarterOpened nmap <buffer> k <Cmd>lua MiniStarter.update_current_item('prev')<CR>
  augroup END
]])

vim.o.sessionoptions = "buffers,curdir,folds,globals,help,skiprtp,tabpages"
local mini_session = require("mini.sessions")

local function is_restorable(buffer)
  if #vim.api.nvim_get_option_value("bufhidden", { buf = buffer }) ~= 0 then
    return false
  end
  local buftype = vim.api.nvim_get_option_value("buftype", { buf = buffer })
  if #buftype == 0 then
    -- Normal buffer, check if it listed.
    if not vim.api.nvim_get_option_value("buflisted", { buf = buffer }) then
      return false
    end
    -- Check if it has a filename.
    if #vim.api.nvim_buf_get_name(buffer) == 0 then
      return false
    end
  elseif buftype ~= "terminal" and buftype ~= "help" then
    -- Buffers other then normal, terminal and help are impossible to restore.
    return false
  end
  return true
end

local clean_up_buffer = function()
  -- Remove all non-file and utility buffers because they cannot be saved.
  for _, buffer in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buffer) and not is_restorable(buffer) then
      vim.api.nvim_buf_delete(buffer, { force = true })
    end
  end
  -- Clear all passed arguments to avoid re-executing them.
  if vim.fn.argc() > 0 then
    vim.api.nvim_command("%argdel")
  end
end

mini_session.setup({
  file = "",
  hooks = {
    -- Clean buffers only when a write is actually triggered
    pre = { write = clean_up_buffer },
  },
})

SaveMiniSession = function()
  local question = "Save session relative to which directory?"
  local choices = "&Project (getcwd)\n&File (current buffer)"
  local ok, choice_index = pcall(vim.fn.confirm, question, choices, 1)
  if not ok or choice_index == 0 then
    vim.notify("Session save cancelled.", vim.log.levels.INFO)
    return -- Abort (Buffers remain untouched)
  end

  local base_path
  if choice_index == 1 then
    base_path = vim.fn.getcwd()
  elseif choice_index == 2 then
    base_path = vim.fn.expand("%:p:h")
    if base_path == "" or base_path == nil then
      vim.notify("Error: Current buffer has no file path. Session not saved.", vim.log.levels.ERROR)
      return
    end
  end

  local session_name = base_path:gsub("[:/\\]$", ""):gsub(":", ""):gsub("[/\\]", "_")
  mini_session.write(session_name) -- Hook triggers here
end

vim.keymap.set(
  "n",
  "<leader>ss",
  "<cmd>lua MiniSessions.select('read')<cr>",
  { desc = "session select" }
)

vim.keymap.set("n", "<leader>sS", function()
  SaveMiniSession()
end, { desc = "session save" })

vim.keymap.set("n", "<leader>sd", function()
  local session_path = vim.v.this_session
  if session_path == "" then
    vim.notify("No active session", vim.log.levels.INFO)
    return
  end
  local session_name = vim.fn.fnamemodify(session_path, ":t")
  vim.notify("Current Session: " .. session_name, vim.log.levels.INFO)
end, { desc = "session display" })

vim.keymap.set(
  "n",
  "<leader>sD",
  "<cmd>lua MiniSessions.select('delete')<cr>",
  { desc = "session delete" }
)
