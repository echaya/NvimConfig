local M = {}

local DEBUG_FUNC_NAME = "repl_debug_cell"

-- Helper: Provides a default value if `b:CodeFence` is not set.
local function get_code_fence()
  return vim.b.CodeFence or "```"
end

-- Helper: Get the current cursor line number (1-based)
local function get_cursor_row()
  return vim.api.nvim_win_get_cursor(0)[1]
end

-- Helper: Set visual selection programmatically
local function set_visual_selection(start_line, end_line)
  start_line = math.max(1, start_line)
  vim.api.nvim_win_set_cursor(0, { start_line, 0 })
  vim.cmd("normal! V")
  vim.api.nvim_win_set_cursor(0, { end_line, 0 })
end

-- Helper: Exit visual mode safely
local function exit_visual_mode()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "x", false)
end

-- Helper: Get dynamic indentation string based on buffer settings
local function get_indent_str()
  if vim.bo.expandtab then
    return string.rep(" ", vim.fn.shiftwidth())
  else
    return "\t"
  end
end

--- Checks if the current line is indented.
function M.is_line_indented()
  return vim.api.nvim_get_current_line():match("^%s") ~= nil
end

--- Checks if the current line is a code fence.
function M.is_fence()
  local line = vim.api.nvim_get_current_line()
  local fence = get_code_fence()
  if line == fence then
    return true
  end
  if vim.startswith(line, fence) then
    return true
  end
end

--- Builds a new code fence at the end of the file.
function M.build_fence()
  local lines = { "", get_code_fence() }
  vim.api.nvim_buf_set_lines(0, -1, -1, false, lines)
  local last_line = vim.api.nvim_buf_line_count(0)
  vim.api.nvim_win_set_cursor(0, { last_line, 0 })
end

--- Checks if a range of lines contains any non-whitespace content.
local function buffer_has_content(start_line, end_line)
  if start_line > end_line then
    return false
  end
  local chunk_size = 1000 -- Check in chunks to avoid massive memory alloc
  local current = start_line
  while current <= end_line do
    local limit = math.min(current + chunk_size, end_line)
    local lines = vim.api.nvim_buf_get_lines(0, current - 1, limit, false)
    for _, line in ipairs(lines) do
      if line:match("%S") then
        return true
      end
    end
    current = limit + 1
  end

  return false
end

--- Handles the logic for an unclosed cell at the bottom of the file.
local function process_last_cell(start_line)
  local file_last_line = vim.api.nvim_buf_line_count(0)

  if not buffer_has_content(start_line, file_last_line) then
    vim.notify("Last cell is empty.", vim.log.levels.INFO)
    exit_visual_mode()
    return false
  end

  M.build_fence()
  local new_fence_line = vim.api.nvim_buf_line_count(0)
  set_visual_selection(start_line, new_fence_line - 1)
  return true
end

--- Logic when cursor is ON a fence line (Search Downwards).
local function select_from_fence_down(cursor_line, fence_pattern)
  local next_fence_line = vim.fn.search(fence_pattern, "nW")

  if next_fence_line == cursor_line then
    local current_pos = vim.api.nvim_win_get_cursor(0)
    local last_line = vim.api.nvim_buf_line_count(0)

    if current_pos[1] < last_line then
      local old_eventignore = vim.o.eventignore
      vim.o.eventignore = "all"

      vim.api.nvim_win_set_cursor(0, { current_pos[1] + 1, 0 })
      next_fence_line = vim.fn.search(fence_pattern, "cnW")
      vim.api.nvim_win_set_cursor(0, current_pos)

      vim.o.eventignore = old_eventignore
    else
      next_fence_line = 0
    end
  end

  if next_fence_line == 0 then
    return process_last_cell(cursor_line + 1)
  else
    local start_line = cursor_line + 1
    local end_line = next_fence_line - 1

    if end_line < start_line or not buffer_has_content(start_line, end_line) then
      vim.notify("Cell is empty.", vim.log.levels.INFO)
      exit_visual_mode()
      return false
    end

    set_visual_selection(start_line, end_line)
    return true
  end
end

--- Logic when cursor is INSIDE a cell (Search Up and Down).
local function select_surrounding_cell(fence_pattern)
  local next_fence_line = vim.fn.search(fence_pattern, "nW")
  local prev_fence_line = vim.fn.search(fence_pattern, "bnW")

  if prev_fence_line == 0 then
    vim.notify("Not inside a code cell (no fences found).", vim.log.levels.WARN)
    exit_visual_mode()
    return false
  end

  local start_line = prev_fence_line + 1

  if next_fence_line == 0 then
    return process_last_cell(start_line)
  else
    local end_line = next_fence_line - 1

    if end_line < start_line or not buffer_has_content(start_line, end_line) then
      vim.notify("Cell is empty.", vim.log.levels.INFO)
      exit_visual_mode()
      return false
    end

    set_visual_selection(start_line, end_line)
    return true
  end
end

--- Selects the content block between two fences.
function M.between_cell()
  local cursor_line = get_cursor_row()
  local fence_pattern = "^" .. get_code_fence()

  local start_fence_line = vim.fn.search(fence_pattern, "bnW")
  if start_fence_line == 0 then
    return
  end

  local start_line = start_fence_line + 1
  local end_line = cursor_line
  if cursor_line == start_line then
    end_line = start_line
  end

  set_visual_selection(start_line, end_line)
end

--- Jumps to the next code fence.
function M.jump_cell()
  local fence_pattern = "^" .. get_code_fence()
  local next_fence = vim.fn.search(fence_pattern, "nW")

  if next_fence == 0 then
    local last_line = vim.api.nvim_buf_line_count(0)
    vim.api.nvim_win_set_cursor(0, { last_line, 0 })
  else
    vim.api.nvim_win_set_cursor(0, { next_fence, 0 })
  end
end

--- Jumps to the previous code fence.
function M.jump_cell_back()
  local fence_pattern = "^" .. get_code_fence()
  local prev_fence = vim.fn.search(fence_pattern, "bnW")

  if prev_fence == 0 then
    vim.api.nvim_win_set_cursor(0, { 1, 0 })
  else
    vim.api.nvim_win_set_cursor(0, { prev_fence, 0 })
  end
end

--- Main function to visually select the current "cell".
function M.select_visual()
  local fence_pattern = "^" .. get_code_fence()
  local cursor_line = get_cursor_row()

  if M.is_fence() then
    return select_from_fence_down(cursor_line, fence_pattern)
  else
    return select_surrounding_cell(fence_pattern)
  end
end

--- Wraps the selected cell in a function for isolated testing.
function M.debug_cell()
  if not M.select_visual() then
    return
  end

  local _, start_row, _, _ = unpack(vim.fn.getpos("v"))
  local _, end_row, _, _ = unpack(vim.fn.getpos("."))
  if start_row > end_row then
    start_row, end_row = end_row, start_row
  end

  local lines = vim.api.nvim_buf_get_lines(0, start_row - 1, end_row, false)
  local indent = get_indent_str()

  for i, line in ipairs(lines) do
    lines[i] = indent .. line
  end

  table.insert(lines, 1, "def " .. DEBUG_FUNC_NAME .. "():")
  table.insert(lines, DEBUG_FUNC_NAME .. "()")

  vim.api.nvim_buf_set_lines(0, start_row - 1, end_row, false, lines)
  vim.api.nvim_win_set_cursor(0, { start_row + #lines - 1, 0 })

  exit_visual_mode()
  vim.notify("Debug cell created.", vim.log.levels.INFO)
end

--- Finds and removes the wrapper.
function M.debug_delete()
  if vim.fn.search("^def " .. DEBUG_FUNC_NAME, "nw") == 0 then
    vim.notify("Debug Cell is not found!", vim.log.levels.WARN)
    return
  end

  if not M.select_visual() then
    return
  end

  local _, start_row, _, _ = unpack(vim.fn.getpos("v"))
  local _, end_row, _, _ = unpack(vim.fn.getpos("."))
  if start_row > end_row then
    start_row, end_row = end_row, start_row
  end

  local lines = vim.api.nvim_buf_get_lines(0, start_row - 1, end_row, false)

  if not lines[1]:match("^def " .. DEBUG_FUNC_NAME) then
    vim.notify("Selection mismatch. Aborting.", vim.log.levels.ERROR)
    exit_visual_mode()
    return
  end

  local filtered_lines = {}
  local indent_pattern = "^" .. vim.pesc(get_indent_str())

  -- Iterate from 2 to N-1 (skipping the first and last wrapper lines)
  for i = 2, #lines - 1 do
    local line = lines[i]:gsub(indent_pattern, "")
    if not line:match("core%.debugger%.set_trace") then
      table.insert(filtered_lines, line)
    end
  end

  vim.api.nvim_buf_set_lines(0, start_row - 1, end_row, false, filtered_lines)

  local closing_fence_row = start_row + #filtered_lines
  local total_lines = vim.api.nvim_buf_line_count(0)
  if closing_fence_row > total_lines then
    closing_fence_row = total_lines
  end

  vim.api.nvim_win_set_cursor(0, { closing_fence_row, 0 })
  exit_visual_mode()
  vim.notify("Debug delete sequence executed.", vim.log.levels.INFO)
end

return M
