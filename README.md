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

### Vimium
```vim
map <a-,> moveTabLeft
map <a-.> moveTabRight
unmap <<
unmap >>
unmap x
unmap X
map ZQ removeTab
map ZZ removeTab
map ZX restoreTab
```
### conda activation
* add the following into a bat file `path` can access. E.g., `zz.bat`
```
c:\\blp\\bqnt\\bootstrapper\\condabin\\activate.bat c:\\blp\\bqnt\\environments\\bqnt-3 && nvim-qt | taskkill /F /IM cmd.exe
```
