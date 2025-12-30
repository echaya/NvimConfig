require("mini.basics").setup({
  options = { extra_ui = true },
  mappings = { windows = true, option_toggle_prefix = "|" },
})

local icon = require("mini.icons")
icon.setup()
icon.mock_nvim_web_devicons()
vim.g.nvim_web_devicons = 1

local git_cache = {}
local icons = { branch = "", ahead = "", behind = "", no_upstream = "☁" }
local FETCH_COOLDOWN = 60

-- Helper: Get the actual Root Directory of the git repo
local function get_git_root(buf_id)
  if vim.fn.exists("*FugitiveWorkTree") == 1 then
    local root = vim.fn.FugitiveWorkTree(buf_id)
    if root ~= "" and vim.fn.isdirectory(root) == 1 then
      return root
    end
  end
end

-- 1. Render String Generator
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

-- 2. Async Local Counts
local function fetch_git_counts(buf_id)
  local cwd = get_git_root(buf_id)
  if not cwd then
    return
  end

  if git_cache[buf_id].job_id then
    pcall(vim.fn.jobstop, git_cache[buf_id].job_id)
  end

  local stdout_data = {}
  local job_id = vim.fn.jobstart(
    { "git", "rev-list", "--count", "--left-right", "HEAD...@{upstream}" },
    {
      cwd = cwd,
      stdout_buffered = true,
      on_stdout = function(_, data)
        stdout_data = data
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

        if code ~= 0 then
          git_cache[buf_id].has_upstream = false
        else
          local result = (stdout_data and stdout_data[1]) or ""
          local ahead, behind = result:match("(%d+)%s+(%d+)")
          git_cache[buf_id].has_upstream = true
          git_cache[buf_id].ahead = tonumber(ahead) or 0
          git_cache[buf_id].behind = tonumber(behind) or 0
        end
        update_render_string(git_cache[buf_id])
        vim.cmd("redrawstatus")
      end),
    }
  )
  git_cache[buf_id].job_id = job_id
end

-- 3. Async Remote Fetch
local function fetch_git_remote(buf_id)
  local now = os.time()
  local last = git_cache[buf_id].last_fetch or 0
  if (now - last) < FETCH_COOLDOWN then
    return
  end

  local cwd = get_git_root(buf_id)
  if not cwd then
    return
  end

  vim.fn.jobstart({ "git", "fetch", "--no-tags", "--quiet" }, {
    cwd = cwd,
    on_exit = function(_, code)
      if code == 0 and git_cache[buf_id] then
        git_cache[buf_id].last_fetch = os.time()
        vim.schedule(function()
          if vim.api.nvim_buf_is_valid(buf_id) then
            fetch_git_counts(buf_id)
          end
        end)
      end
    end,
  })
end

-- 4. Trigger Orchestrator
local function update_git_status(buf_id)
  buf_id = buf_id or vim.api.nvim_get_current_buf()
  if not vim.api.nvim_buf_is_valid(buf_id) then
    return
  end

  if vim.api.nvim_buf_get_name(buf_id) == "" then
    return
  end

  if vim.fn.exists("*FugitiveHead") == 0 then
    return
  end

  local head = vim.fn.FugitiveHead(buf_id)
  if head == "" then
    git_cache[buf_id] = nil
    return
  end

  if not git_cache[buf_id] then
    git_cache[buf_id] = { head = head, last_fetch = 0 }
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
        fetch_git_counts(buf_id)
        fetch_git_remote(buf_id)
      end
    end)
  )
end

-- 5. Statusline Component
local function get_git_status_string()
  local buf = vim.api.nvim_get_current_buf()
  return (git_cache[buf] and git_cache[buf].render) or ""
end

local grp_git = vim.api.nvim_create_augroup("LocalGitStatus", { clear = true })

vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "FocusGained" }, {
  group = grp_git,
  pattern = "*",
  callback = function(args)
    update_git_status(args.buf)
  end,
})

vim.api.nvim_create_user_command("GFetch", function()
  local buf = vim.api.nvim_get_current_buf()
  if git_cache[buf] then
    git_cache[buf].last_fetch = 0
  end
  update_git_status(buf)
end, {})

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

      return MiniStatusline.combine_groups({
        { hl = mode_hl, strings = { mode } },
        { hl = "MiniStatuslineDevinfo", strings = { git, diff, diagnostics } },
        "%<", -- Mark general truncate point
        { hl = "MiniStatuslineFilename", strings = { filename } },
        "%=", -- End left alignment
        { hl = "MiniStatuslineFileinfo", strings = { fileinfo, lsp } },
        { hl = mode_hl, strings = { tostring(vim.api.nvim_buf_line_count(0)) } },
      })
    end,
  },
})

vim.api.nvim_create_user_command("GithubSync", function()
  vim.cmd('lua Snacks.terminal("cd d:/Workspace/SiteRepo/; ./UpdateSite.bat; exit")')
end, {
  desc = "Sync Site Repo to Github via snacks.terminal() call",
  nargs = 0,
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
mini_session.setup({ file = "" })

-- save session functions copy from nvim-session-manager
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

SaveMiniSession = function()
  clean_up_buffer()

  local question = "Save session relative to which directory?"
  local choices = "&Project (getcwd)\n&File (current buffer)"
  local ok, choice_index = pcall(vim.fn.confirm, question, choices, 1)
  if not ok or choice_index == 0 then
    vim.notify("Session save cancelled.", vim.log.levels.INFO)
    return -- Abort the function
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
  mini_session.write(session_name)
  vim.notify("Session saved as: " .. session_name, vim.log.levels.INFO)
end

vim.keymap.set(
  "n",
  "<localleader>ss",
  "<cmd>lua MiniSessions.select('read')<cr>",
  { desc = "session_load" }
)
vim.keymap.set(
  "n",
  "<localleader>sd",
  "<cmd>lua MiniSessions.select('delete')<cr>",
  { desc = "session_delete" }
)
vim.keymap.set("n", "<localleader>sS", function()
  SaveMiniSession()
end, { desc = "session_save" })
