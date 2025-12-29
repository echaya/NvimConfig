-- git related
require("mini.diff").setup({
  view = {
    style = "sign",
  },
  mappings = {
    goto_first = "[C",
    goto_prev = "[c",
    goto_next = "]c",
    goto_last = "]C",
  },
  options = {
    algorithm = "patience",
  },
})

local function walk_in_codediff(picker, item)
  picker:close()
  if item.commit then
    local current_commit = item.commit

    vim.fn.setreg("+", current_commit)
    vim.notify("Copied: " .. current_commit)

    -- get parent / previous commit
    local parent_commit = vim.trim(vim.fn.system("git rev-parse --short " .. current_commit .. "^"))
    parent_commit = parent_commit:match("[a-f0-9]+")

    -- Check if command failed (e.g., Initial commit has no parent)
    if vim.v.shell_error ~= 0 then
      vim.notify("Cannot find parent (Root commit?)", vim.log.levels.WARN)
      parent_commit = ""
    end

    local cmd = string.format("CodeDiff %s %s", parent_commit, current_commit)
    vim.notify("Diffing: " .. parent_commit .. " -> " .. current_commit)
    vim.cmd(cmd)
  end
end

local function git_pickaxe(opts)
  opts = opts or {}
  local is_global = opts.global or false
  local current_file = vim.api.nvim_buf_get_name(0)

  -- Force global if current buffer is invalid
  if not is_global and (current_file == "" or current_file == nil) then
    vim.notify("Buffer is not a file, switching to global search", vim.log.levels.WARN)
    is_global = true
  end

  local title_scope = is_global and "Global" or vim.fn.fnamemodify(current_file, ":t")
  vim.ui.input({ prompt = "Git Search (-G) in " .. title_scope .. ": " }, function(query)
    if not query or query == "" then
      return
    end

    vim.fn.setreg("/", query)
    local old_hl = vim.opt.hlsearch
    vim.opt.hlsearch = true

    local args = {
      "log",
      "-G" .. query,
      "-i",
      "--pretty=format:%C(yellow)%h%Creset %s %C(green)(%cr)%Creset %C(blue)<%an>%Creset",
      "--abbrev-commit",
      "--date=short",
    }

    if not is_global then
      table.insert(args, "--")
      table.insert(args, current_file)
    end

    Snacks.picker({
      title = 'Git Log: "' .. query .. '" (' .. title_scope .. ")",
      finder = "proc",
      cmd = "git",
      args = args,

      transform = function(item)
        local clean_text = item.text:gsub("\27%[[0-9;]*m", "")
        local hash = clean_text:match("^%S+")
        if hash then
          item.commit = hash
          if not is_global then
            item.file = current_file
          end
        end
        return item
      end,

      preview = "git_show",
      confirm = walk_in_codediff,
      format = "text",

      on_close = function()
        vim.opt.hlsearch = old_hl
        vim.cmd("noh")
      end,
    })
  end)
end

-- Keymaps
vim.keymap.set({ "n", "t" }, "<leader>hl", function()
  Snacks.picker.git_log_file({
    confirm = walk_in_codediff,
  })
end, { desc = "find_git_log_file" })
vim.keymap.set({ "n", "t" }, "<leader>hL", function()
  Snacks.picker.git_log({
    confirm = walk_in_codediff,
  })
end, { desc = "find_git_log" })
vim.keymap.set("n", "<leader>hs", function()
  git_pickaxe({ global = false })
end, { desc = "Git Search (Buffer)" })
vim.keymap.set("n", "<leader>hS", function()
  git_pickaxe({ global = true })
end, { desc = "Git Search (Global)" })

require("codediff").setup({
  keymaps = {
    view = {
      quit = false,
      toggle_explorer = "<leader>e", -- Toggle explorer visibility (explorer mode only)
      next_hunk = "]v",
      prev_hunk = "[v",
    },
  },
})

vim.keymap.set("n", "<leader>v", function()
  local count = vim.v.count
  vim.g.prev_tab_nr = vim.api.nvim_get_current_tabpage()
  local cmd
  if count > 0 then
    cmd = "CodeDiff HEAD~" .. (count - 1)
  else
    cmd = "CodeDiff"
  end
  vim.notify(cmd, vim.log.levels.INFO)
  vim.cmd(cmd)
end, {
  noremap = true,
  silent = true,
  desc = "CodeDiff [HEAD~(count-1)]",
})

local function get_default_branch_name()
  local res = vim
    .system({ "git", "rev-parse", "--verify", "main" }, { capture_output = true })
    :wait()
  return res.code == 0 and "main" or "master"
end

vim.keymap.set("n", "<leader>hm", function()
  local cmd = "CodeDiff " .. get_default_branch_name()
  vim.notify(cmd, vim.log.levels.INFO)
  vim.cmd(cmd)
end, { desc = "Diff against local master" })

vim.keymap.set("n", "<leader>hy", function()
  return require("mini.diff").operator("yank") .. "gh"
end, { expr = true, remap = true, desc = "Yank hunk Reference" })

vim.keymap.set(
  "n",
  "<leader>hh",
  "<cmd>lua MiniDiff.toggle_overlay()<CR>",
  { desc = "toggle hunk overlay" }
)

local function silent_async_push(git_root)
  if not git_root or git_root == "" then
    local ok, result = pcall(vim.fn.FugitiveWorkTree)
    if ok and result and result ~= "" then
      git_root = result
    end
  end
  if not git_root then
    vim.notify("Git Push: Aborted. No git root found.", vim.log.levels.ERROR)
    return
  end

  local output_lines = {}

  vim.fn.jobstart({ "git", "push" }, {
    cwd = git_root,
    on_stderr = function(_, data)
      if data then
        vim.list_extend(output_lines, data)
      end
    end,
    on_exit = function(_, code)
      local clean_output = {}
      for _, line in ipairs(output_lines) do
        if line:match("%S") then
          table.insert(clean_output, line)
        end
      end
      local msg = table.concat(clean_output, "\n")

      if code == 0 then
        -- Success
        vim.notify("Git Push Success" .. (msg ~= "" and (":\n" .. msg) or ""), vim.log.levels.INFO)
      else
        -- Failure
        vim.notify(
          "Git Push Failed:\n" .. (msg ~= "" and msg or "Exit Code " .. code),
          vim.log.levels.ERROR
        )
      end
      pcall(vim.cmd, "GFetch")
    end,
  })
end

-- TODO to add when upgrade to nvim 0.12
-- vim.opt.diffopt:append("inline:char")
vim.api.nvim_create_user_command("GH", function()
  if vim.bo.filetype ~= "gitcommit" then
    vim.notify("GH: Not a gitcommit buffer.", vim.log.levels.WARN)
    return
  end

  local ok, current_repo_root = pcall(vim.fn.FugitiveWorkTree)
  if not ok then
    vim.notify("GH: Could not detect git root in commit buffer.", vim.log.levels.ERROR)
    return
  end

  vim.cmd("write")
  local target_tab = vim.g.last_active_tab
  local current_tab = vim.api.nvim_get_current_tabpage()
  vim.cmd("tabclose")
  if target_tab and target_tab ~= current_tab and vim.api.nvim_tabpage_is_valid(target_tab) then
    pcall(vim.api.nvim_set_current_tabpage, target_tab)
  end

  vim.defer_fn(function()
    silent_async_push(current_repo_root)
  end, 100)
end, {
  desc = "Git Hack: Save commit, close tab, and push",
})
