-- Create a table to hold our module's functions.
local M = {}

--- Helper to get the code fence string from a buffer variable.
-- Provides a default value to prevent errors if `b:CodeFence` is not set.
-- @return string The code fence pattern.
local function get_code_fence()
  return vim.b.CodeFence or "```"
end

--- Checks if the current line is indented (starts with a space).
-- @return boolean: true if the line is indented, false otherwise.
function M.is_line_indented()
  local line_content = vim.api.nvim_get_current_line()
  -- string.find returns the start and end indices of a match, or nil if not found.
  -- The '^ ' pattern checks for a space at the beginning of the line.
  return string.find(line_content, "^ ") ~= nil
end

--- Checks if the current line is a code fence.
-- @return boolean: true if the line matches the code fence.
function M.is_fence()
  return vim.api.nvim_get_current_line() == get_code_fence()
end

--- Builds a new code fence at the end of the file.
-- Preserves original logic to clean up the line if it was auto-indented.
function M.build_fence()
  -- A direct translation of `normal Go` followed by the fence string.
  -- Using 'normal!' is crucial to prevent user mappings from interfering.
  vim.cmd("normal! Go" .. get_code_fence())

  -- This logic handles a specific formatting case where an indent and
  -- comment character (like '#') might be automatically inserted.
  vim.cmd("silent! s/^\\s\\+//e")
end

--- Selects the cell content after creating a new fence.
-- NOTE: This is a direct translation. Its behavior is highly dependent on
-- cursor position and jump history, which can be fragile.
function M.close_cell()
  vim.cmd("normal! #jV``")
  vim.cmd("normal! -")
end

--- Selects the content block between two fences.
function M.between_cell()
  local start_line = vim.api.nvim_win_get_cursor(0)[1]
  -- Search backwards for a line starting with the code fence.
  -- Flags: 'W' = don't wrap, 'b' = backwards, 's' = don't move cursor on search.
  local prev_fence_line = vim.fn.search("^" .. get_code_fence(), "Wbs")

  -- `+` moves to the first non-blank character of the next line.
  vim.cmd("normal! +")

  if start_line - prev_fence_line == 1 then
    -- If we were on the line immediately following a fence, just select this line.
    vim.cmd("normal! V")
  else
    -- Otherwise, visually select from the current line to the mark set by the
    -- last jump (`''`), which was set by the `search()` function.
    vim.cmd("normal! V''")
  end
end

--- Jumps to the next code fence. Goes to the end of the file if none is found.
function M.jump_cell()
  -- fn.search() returns 0 on failure. 'W' prevents file wrap-around.
  if vim.fn.search("^" .. get_code_fence(), "W") == 0 then
    vim.cmd("normal! G")
  end
end

--- Jumps to the previous code fence. Goes to the start of the file if none is found.
function M.jump_cell_back()
  -- 'Wb' prevents wrap-around and searches backwards.
  if vim.fn.search("^" .. get_code_fence(), "Wb") == 0 then
    vim.cmd("normal! gg")
  end
end

--- Main function to visually select the current "cell".
-- Handles the corner case where the cursor is on the last fence line.
function M.select_visual()
  -- Check if a code fence exists after the current cursor position.
  -- If fn.search returns 0, no fence is found, meaning we are in the last cell.
  if vim.fn.search("^" .. get_code_fence(), "W") == 0 then
    -- We are in the last cell. Only build a new fence if this cell has content.

    -- 1. Correctly determine the top boundary of the last cell.
    local prev_fence_line
    if M.is_fence() then
      -- This is the key to solving the corner case.
      prev_fence_line = vim.api.nvim_win_get_cursor(0)[1]
    else
      -- Otherwise, if the cursor is within the cell's content, search backwards
      -- for the fence that defines the top of the current cell.
      prev_fence_line = vim.fn.search("^" .. get_code_fence(), "bW")
    end

    -- 2. Define the line range of the last cell's content.
    -- It starts on the line after the determined fence (or line 1 if no previous fence exists).
    local cell_start_line = (prev_fence_line == 0) and 1 or (prev_fence_line + 1)
    local file_last_line = vim.api.nvim_buf_line_count(0)

    -- If the cell's calculated start is beyond the file's end, there's nothing to do.
    if cell_start_line > file_last_line then
      vim.notify("Last cell is empty.", vim.log.levels.INFO, { title = "Cell Logic" })
      return
    end

    -- 3. Get all lines within the last cell's potential content range.
    local cell_lines = vim.api.nvim_buf_get_lines(0, cell_start_line - 1, file_last_line, false)

    -- 4. Iterate through the lines to find any non-blank content.
    local has_content = false
    for _, line in ipairs(cell_lines) do
      if line:match("%S") then
        has_content = true
        break
      end
    end

    -- 5. Conditionally build the new fence.
    if has_content then
      M.build_fence()
      M.close_cell()
    else
      vim.notify(
        "Last cell is empty, not creating new fence.",
        vim.log.levels.INFO,
        { title = "Cell Logic" }
      )
    end
  else
    -- This is the original logic for when the cursor is not in the last cell.
    vim.cmd("normal! -")
    M.between_cell()
  end
end
--- Wraps the selected cell in a "DebugCell" function for isolated testing.
-- This version is designed to work with the normal-mode-based select_visual.
local debug_func = "repl_debug_cell"
function M.debug_cell()
  -- First, use your existing logic to select a cell.
  M.select_visual()

  -- Ensure that a visual selection was actually made before proceeding.
  if not (vim.fn.mode() == "V" or vim.fn.mode() == "v") then
    vim.notify("Visual selection failed, cannot create debug cell.", vim.log.levels.WARN)
    return
  end

  -- This sequence is a direct translation of the original Vimscript's state changes.
  -- It is designed to work correctly after your select_visual leaves Neovim in visual mode.
  vim.cmd("normal! >O") -- Indent selection, then open a line above in insert mode.
  vim.cmd("normal! Idef " .. debug_func .. "():") -- Leave insert, move to BOL, re-enter, type, and leave.
  vim.cmd("normal! `>o") -- Jump to the end-of-selection mark, open a line below.
  vim.cmd("normal! I" .. debug_func .. "()") -- Leave insert, move to BOL, re-enter, type, and leave.

  vim.notify("Debug cell created.", vim.log.levels.INFO)
end
--- Finds and removes the "DebugCell" wrapper, un-indenting the code.
--- Finds and removes the "DebugCell" wrapper by locating and deleting the specific wrapper lines.
--- Finds "def DebugCell" and then attempts to unwrap it using a sequence of normal commands.
-- This is a direct translation of the original Vimscript logic.
function M.debug_delete()
  -- 1. Search for the "def DebugCell" string and move the cursor there.
  --    This mimics the behavior of the Vimscript `search()` function.
  if vim.fn.search("^" .. debug_func, "wc") == 0 then
    vim.notify("Debug Cell is not found!", vim.log.levels.WARN)
    return
  end

  -- 2. Call the select_visual function. The rest of the logic depends on
  --    the specific visual selection this function makes from this position.
  M.select_visual()
  vim.cmd("normal! <")
  vim.cmd("normal! '<dd")
  vim.cmd("normal! `>dd")
  vim.cmd("silent! '<,'>g/core.debugger.set_trace/d")
  vim.notify("Debug delete sequence executed.", vim.log.levels.INFO)
end
return M
