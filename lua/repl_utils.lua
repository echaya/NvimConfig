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
-- If in the last cell, it creates a new one below.
-- Otherwise, it selects the content of the current cell.
function M.select_visual()
  -- If a forward search for the fence fails, we are in the last cell.
  if vim.fn.search("^" .. get_code_fence(), "W") == 0 then
    M.build_fence()
    M.close_cell()
  else
    -- Move cursor up one line. This helps correctly position the cursor
    -- for the selection logic that follows.
    vim.cmd("normal! -")
    M.between_cell()
  end
end

return M
