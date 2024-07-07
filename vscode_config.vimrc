" window and tab navigation
nnoremap <silent> J <Cmd>lua require('vscode').call('workbench.action.previousEditor')<CR>
nnoremap <silent> K <Cmd>lua require('vscode').call('workbench.action.nextEditor')<CR>
nnoremap <silent> ZZ <Cmd>lua require('vscode').call('workbench.action.closeActiveEditor')<CR>
nnoremap <silent> ZX <Cmd>lua require('vscode').call('workbench.action.reopenClosedEditor')<CR>

" require register a-x into vscode shortcut
nnoremap <silent> <a-,> <Cmd>lua require('vscode').call('workbench.action.moveEditorLeftInGroup')<CR>
nnoremap <silent> <a-.> <Cmd>lua require('vscode').call('workbench.action.moveEditorRightInGroup')<CR>
nnoremap <silent> <a-b> <Cmd>lua require('vscode').call('workbench.action.toggleSidebarVisibility')<CR>
nnoremap <silent> <a-del> <Cmd>lua require('vscode').call('jupyter.interactive.clearAllCells')<CR>

" code navigation and execution
nnoremap <silent> - <Cmd>lua require('vscode').call('workbench.view.explorer')<CR>
nnoremap <silent> gD <Cmd>lua require('vscode').action('editor.action.revealDefinitionAside')<CR>
nnoremap <silent> o <Cmd>lua require('vscode').action('editor.action.insertLineAfter')<CR>i
nnoremap <silent> O <Cmd>lua require('vscode').action('editor.action.insertLineBefore')<CR>i
xnoremap <silent> <S-CR> <Cmd>lua require('vscode').call('jupyter.execSelectionInteractive')<CR><Esc>
" with below vscode binding
"{
"    "key": "shift+Enter",
"    "command": "vscode-neovim.send",
"    "args": "<S-CR>",
"    "when": "editorTextFocus && neovim.init && neovim.mode == 'visual'"
"},

" format
nnoremap <silent> == <Cmd>lua require('vscode').action('editor.action.formatDocument')<CR>
nnoremap <silent> <up> <Cmd>lua require('vscode').action('workbench.action.increaseViewSize')<CR>
nnoremap <silent> <down> <Cmd>lua require('vscode').action('workbench.action.decreaseViewSize')<CR>

" git related
xnoremap <silent> <left> <Cmd>lua require('vscode').call('git.stageSelectedRanges')<CR><Esc>
nnoremap <silent> <left> <Cmd>lua require('vscode').action('git.commitStaged')<CR>
nnoremap <silent> <right> <Cmd>lua require('vscode').action('git.sync')<CR>
nnoremap <silent> gJ <Cmd>lua require('vscode').action('editor.action.dirtydiff.next')<CR>
nnoremap <silent> gK <Cmd>lua require('vscode').action('editor.action.dirtydiff.previous')<CR>
nnoremap <silent> gj <Cmd>lua require('vscode').action('workbench.action.editor.nextChange')<CR>
nnoremap <silent> gk <Cmd>lua require('vscode').action('workbench.action.editor.previousChange')<CR>

" bookmark
nnoremap <silent> mm <Cmd>lua require('vscode').call('bookmarks.toggle')<CR>
nnoremap <silent> mj <Cmd>lua require('vscode').call('bookmarks.jumpToNext')<CR>
nnoremap <silent> mk <Cmd>lua require('vscode').call('bookmarks.jumpToPrevious')<CR>
nnoremap <silent> mi <Cmd>lua require('vscode').call('bookmarks.toggleLabeled')<CR>
nnoremap <silent> m; <Cmd>lua require('vscode').call('bookmarks.listFromAllFiles')<CR>
nnoremap <silent> dmm <Cmd>lua require('vscode').call('bookmarks.clearFromAllFiles')<CR>

" comment
xnoremap gc  <Plug>VSCodeCommentary
nnoremap gc  <Plug>VSCodeCommentary
onoremap gc  <Plug>VSCodeCommentary
nnoremap gcc <Plug>VSCodeCommentaryLine

" handled by VSCODE

"{
"    "key": "alt+`",
"    "command": "workbench.action.terminal.toggleTerminal",
"    "when": "terminal.active || editorFocus"
"},
"{
"    "key": "alt+p",
"    "command": "workbench.action.pinEditor",
"    "when": "!activeEditorIsPinned"
"},
"{
"    "key": "alt+p",
"    "command": "workbench.action.unpinEditor",
"    "when": "activeEditorIsPinned"
"},
" {
"     "key": "alt+h",
"     "command": "workbench.action.focusFirstEditorGroup"
" },
" {
"     "key": "alt+l",
"     "command": "workbench.action.focusSecondEditorGroup"
" }

" [test] set vim.notify as default notify
vim.notify = vscode.notify

au InsertEnter * <Cmd> redraw
