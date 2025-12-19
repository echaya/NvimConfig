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
map <c-s-j> previousTab
map <c-s-k> nextTab
map <c-d> scrollPageDown
map <c-u> scrollPageUp
```

### Lazygit
```yml
keybinding:
  universal:
    select: '-'
  files:
    collapseAll: '+'
  commits:
    moveDownCommit: '<pgdown>'
    moveUpCommit: '<pgup>'
```
