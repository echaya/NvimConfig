 "adding more character objectives
for s:char in [',','/', '*', '%', '_', '`', '!','.']
    execute 'xnoremap i' . s:char . ' :<C-u>normal! T' . s:char . 'vt' . s:char . '<CR>'
    execute 'onoremap i' . s:char . ' :normal vi' . s:char . '<CR>'
    execute 'xnoremap a' . s:char . ' :<C-u>normal! F' . s:char . 'vf' . s:char . '<CR>'
    execute 'onoremap a' . s:char . ' :normal va' . s:char . '<CR>'
endfor


" using vim-signify
nnoremap gK :SignifyDiff<cr>
nnoremap gJ :SignifyHunkDiff<cr>
nnoremap <leader>hr :SignifyHunkUndo<cr>
vnoremap <leader>hr :SignifyHunkUndo<cr>

"coloring and status line
let g:lightline = {
            \ 'colorscheme': 'one',
            \ 'active': {
            \   'left': [ [ 'mode', 'paste' ],
            \             [ 'gitbranch', 'readonly', 'filename', 'modified' ] ]
            \ },
            \ 'component_function': {
            \   'gitbranch': 'gitbranch#name'
            \ },
            \ }

" use startify to handle session. Need to SSave a session to become persistent
let g:startify_session_persistence = 1

"open the cursor at the last saved position even without session
au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

" Escape shortcut
inoremap jk <ESC>

let &t_SI = "\e[6 q"
let &t_EI = "\e[2 q"


let g:undotree_WindowLayout = 2
nnoremap <leader>fu :UndotreeToggle<CR>

runtime macros/sandwich/keymap/surround.vim
