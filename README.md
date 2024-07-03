### ginit.vim

```vim
GuiTabline 0
GuiLinespace 0
let g:MyFont = "Roboto Mono"
let g:FontSize = 10

exe "GuiFont! ".MyFont.":h".FontSize

function! AdjustFontSize(amount)
  let g:FontSize = g:FontSize+a:amount
  :execute "GuiFont! ".g:MyFont.":h" . g:FontSize
endfunction

noremap <C-=> :call AdjustFontSize(1)<CR>
noremap <C--> :call AdjustFontSize(-1)<CR>

```
### VSCode

``` JSON
    {
        "key": "alt+.",
        "command": "vscode-neovim.send",
        "args": "<a-.>",
        "when": "editorTextFocus && neovim.init"
    },
    {
        "key": "alt+,",
        "command": "vscode-neovim.send",
        "args": "<a-,>",
        "when": "editorTextFocus && neovim.init"
    },
```

### Vimium
```vim
map <a-,> previousTab
map <a-.> nextTab
unmap J
unmap K
unmap <a-c>
unmap <a-s-c>
unmap x
unmap X
map ZQ removeTab
map ZZ removeTab
map ZX restoreTab
```
