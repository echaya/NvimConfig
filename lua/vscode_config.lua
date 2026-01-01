-- delete multi cursor related
vim.keymap.del("x", "ma")
vim.keymap.del("x", "mi")
vim.keymap.del("x", "mA")
vim.keymap.del("x", "mI")

-- For VSCode specific actions, it's good practice to have a local variable.
local vscode = require("vscode")
vim.notify = vscode.notify

-- Window and Tab Navigation
vim.keymap.set("n", "J", function()
  vscode.call("workbench.action.previousEditor")
end, { desc = "VSCode: Previous Editor" })
vim.keymap.set("n", "K", function()
  vscode.call("workbench.action.nextEditor")
end, { desc = "VSCode: Next Editor" })
vim.keymap.set("n", "ZZ", function()
  vscode.call("workbench.action.closeActiveEditor")
end, { desc = "VSCode: Close Editor" })
vim.keymap.set("n", "ZX", function()
  vscode.call("workbench.action.reopenClosedEditor")
end, { desc = "VSCode: Re-open Closed Editor" })

-- Moving editors within a group
vim.keymap.set("n", "<A-,>", function()
  vscode.call("workbench.action.moveEditorLeftInGroup")
end, { desc = "VSCode: Move Editor Left" })
vim.keymap.set("n", "<A-.>", function()
  vscode.call("workbench.action.moveEditorRightInGroup")
end, { desc = "VSCode: Move Editor Right" })
vim.keymap.set("n", "<A-del>", function()
  vscode.call("jupyter.interactive.clearAllCells")
end, { desc = "Jupyter: Clear All Cells" })

-- Code Navigation and Execution
vim.keymap.set("n", "<A-e>", function()
  vscode.call("workbench.view.explorer")
end, { desc = "VSCode: Toggle Explorer" })
vim.keymap.set("n", "gD", function()
  vscode.action("editor.action.revealDefinitionAside")
end, { desc = "VSCode: Reveal Definition Aside" })

-- For 'o' and 'O', we replicate the trailing 'i' from your original vim.keymap.setping
-- by programmatically entering insert mode after the action.
-- For 'o' and 'O', we replicate the trailing 'i' from your original mapping
-- by programmatically entering insert mode after the action.
vim.keymap.set("n", "o", function()
  vscode.action("editor.action.insertLineAfter")
  vim.cmd("startinsert") -- Enter insert mode
end, { desc = "Editor: Insert Line After" })

vim.keymap.set("n", "O", function()
  vscode.action("editor.action.insertLineBefore")
  vim.cmd("startinsert") -- Enter insert mode
end, { desc = "Editor: Insert Line Before" })
-- In visual mode, when a Lua function is called, Neovim automatically exits
-- the mode, so the trailing `<Esc>` is no longer needed.
vim.keymap.set("x", "<CR>", function()
  vscode.call("jupyter.execSelectionInteractive")
end, { desc = "Jupyter: Execute Selection" })

-- Format
vim.keymap.set("n", "==", function()
  vscode.action("editor.action.formatDocument")
end, { desc = "Editor: Format Document" })
vim.keymap.set("n", "<Up>", function()
  vscode.action("workbench.action.increaseViewSize")
end, { desc = "VSCode: Increase View Size" })
vim.keymap.set("n", "<Down>", function()
  vscode.action("workbench.action.decreaseViewSize")
end, { desc = "VSCode: Decrease View Size" })

-- Git Related
vim.keymap.set("x", "gh", function()
  vscode.call("git.stageSelectedRanges")
end, { desc = "Git: Stage Selected Ranges" })
vim.keymap.set("n", "<leader>hh", function()
  vscode.action("editor.action.dirtydiff.next")
end, { desc = "Git: Next Diff" })
-- The original vim.keymap.setpings for [c and ]c were swapped. I've corrected them to be more conventional.
vim.keymap.set("n", "]c", function()
  vscode.action("workbench.action.editor.nextChange")
end, { desc = "Editor: Next Change" })
vim.keymap.set("n", "[c", function()
  vscode.action("workbench.action.editor.previousChange")
end, { desc = "Editor: Previous Change" })

-- User commands defined in Lua
vim.api.nvim_create_user_command("GC", function()
  vscode.action("git.commitStaged")
end, { desc = "Git: Commit Staged" })
vim.api.nvim_create_user_command("GP", function()
  vscode.action("git.sync")
end, { desc = "Git: Sync (Pull/Push)" })

-- Commenting (using <Plug> mappings)
-- For <Plug> mappings, we map to the placeholder string itself.
-- These mappings are designed to be remappable by the plugin.
vim.keymap.set(
  { "n", "x", "o" },
  "gc",
  "<Plug>VSCodeCommentary",
  { desc = "VSCode: Toggle Comment" }
)
vim.keymap.set("n", "gcc", "<Plug>VSCodeCommentaryLine", { desc = "VSCode: Toggle Line Comment" })

-- handled by VSCODE
--
--{
--    "key": "alt+`",
--    "command": "workbench.action.terminal.toggleTerminal",
--    "when": "terminal.active || editorFocus"
--},
--{
--    "key": "alt+p",
--    "command": "workbench.action.pinEditor",
--    "when": "!activeEditorIsPinned"
--},
--{
--    "key": "alt+p",
--    "command": "workbench.action.unpinEditor",
--    "when": "activeEditorIsPinned"
--},
-- {
--     "key": "ctrl+h",
--     "command": "workbench.action.focusFirstEditorGroup"
-- },
-- {
--     "key": "ctrl+l",
--     "command": "workbench.action.focusSecondEditorGroup"
-- },
-- {
--     "key": "alt+b",
--     "command": "workbench.action.toggleSidebarVisibility"
-- },
