" system
set tabstop=4 softtabstop=0 expandtab shiftwidth=4 smarttab
set noswapfile
set nobackup
set nowritebackup
set nocompatible
set mouse=a
set showmatch
set backspace=indent,eol,start

"change <leader> to SPACE
nnoremap <SPACE> <Nop>
let mapleader=" "
set clipboard=unnamedplus

"seaerch
set incsearch
set hlsearch
set ignorecase
set smartcase

" color, display, theme
syntax on
filetype plugin indent on
set linebreak
set noshowmode
set ruler
set wrap
set fillchars = "eob: "
set signcolumn=yes
set splitbelow
set splitright

if has('termguicolors')
    set termguicolors
endif

noremap <C-h> <C-w><C-h>
noremap <C-j> <C-w><C-j>
noremap <C-k> <C-w><C-k>
noremap <C-l> <C-w><C-l>

" adjust split window size
nnoremap <c-up> :res +2<CR>
nnoremap <c-down> :res -2<CR>
nnoremap <c-left> :vertical resize-5<CR>
nnoremap <c-right> :vertical resize+5<CR>

" change default Y behavior to match with D, C, etc
noremap Y y$
" reselect just pasted block
nnoremap gV `[v`]

" " better j/k using gj and gk
nnoremap <expr> j v:count == 0 ? 'gj' : 'j'
xnoremap <expr> j v:count == 0 ? 'gj' : 'j'
nnoremap <expr> k v:count == 0 ? 'gk' : 'k'
xnoremap <expr> k v:count == 0 ? 'gk' : 'k'

" insert lines without entering insert mode (allow count)
noremap <silent> go :<C-u>call append(line("."),   repeat([""], v:count1))<CR>
nnoremap <silent> gO :<C-u>call append(line(".")-1, repeat([""], v:count1))<CR>

" use <leader><Esc> to escape terminal mode
tnoremap <leader><Esc> <C-\><C-n>
 "adding more character objectives
for s:char in [',','/', '*', '%', '_', '`', '!','.']
    execute 'xnoremap i' . s:char . ' :<C-u>normal! T' . s:char . 'vt' . s:char . '<CR>'
    execute 'onoremap i' . s:char . ' :normal vi' . s:char . '<CR>'
    execute 'xnoremap a' . s:char . ' :<C-u>normal! F' . s:char . 'vf' . s:char . '<CR>'
    execute 'onoremap a' . s:char . ' :normal va' . s:char . '<CR>'
endfor


" using vim-signify
nnoremap <leader>hd :SignifyDiff<cr>
nnoremap <leader>hh :SignifyHunkDiff<cr>
nnoremap <leader>hr :SignifyHunkUndo<cr>

"coloring and status line
set laststatus=2
let g:lightline = {
            \ 'colorscheme': 'nightfly',
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

:command! PU PlugUpdate

" auto root change by vim-roooter
let g:rooter_targets = '/,*'
let g:rooter_buftypes = ['']
let g:rooter_patterns = ['.git']

