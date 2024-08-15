" system
set tabstop=4 softtabstop=0 expandtab shiftwidth=4 smarttab
set noswapfile
set nobackup
set nowritebackup
set backupcopy=yes "to work with Joplin
set autoread "to autoload from Joplin / disk when the file opened is changed
set nocompatible
set mouse=a
set showmatch
set backspace=indent,eol,start
if has('persistent_undo')
    exe 'set undodir='.g:WorkDir.'undo'
    set undolevels=10000
    set undofile
endif
set updatetime=100

set splitbelow
set splitright
filetype plugin indent on
" encoding
set fileencodings=ucs-bom,utf-8,utf-16,gbk,big5,gb18030,latin1
set enc=utf-8
" color, display, theme
syntax on
set number relativenumber
set scrolloff=3
set splitright
set splitbelow
set wrap
set linebreak
set showcmd
set noshowmode
set ruler
set shellslash
if !has('unix')
    let &shell = 'pwsh'
    let &shellcmdflag = '-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;'
    let &shellredir = '-RedirectStandardOutput %s -NoNewWindow -Wait'
    let &shellpipe = '2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode'
    set shellquote= shellxquote=
endif

if has('gui_running')
    set guioptions-=e
else
    let &t_SI = "\e[6 q"
    let &t_EI = "\e[2 q"
endif

"coloring and status line
set showtabline=2
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

" Navigate buffers. use :bufferN to jump based on buffer number
noremap <silent> J :bp<CR>
noremap <silent> K :bn<CR>
nnoremap <silent> ZX :e #<CR>

"Move to previous/next tabpage
noremap <silent> <PageUp> :tabp<CR>
noremap <silent> <PageDown> :tabn<CR>
noremap <silent> <Del> :tabc<CR>
noremap <silent> <Insert> :tabnew<CR>
noremap <silent> H :tabp<CR>
noremap <silent> L :tabn<CR>

augroup CursorLine
    au!
    au VimEnter * setlocal cursorline
    au WinEnter * setlocal cursorline
    au BufWinEnter * setlocal cursorline
    au WinLeave * setlocal nocursorline
augroup END

au InsertLeave,WinEnter * set cursorline
au InsertEnter,WinLeave * set nocursorline


" Escape shortcut
inoremap jk <ESC>

" buffers management
set hidden
" noremap <silent> <s-j> :bp<CR>
" noremap <silent> <s-k> :bn<CR>
noremap <A-h> <C-w><C-h>
noremap <A-j> <C-w><C-j>
noremap <A-k> <C-w><C-k>
noremap <A-l> <C-w><C-l>
tnoremap <A-h> <Cmd>wincmd h<CR>
tnoremap <A-j> <Cmd>wincmd j<CR>
tnoremap <A-k> <Cmd>wincmd k<CR>
tnoremap <A-l> <Cmd>wincmd l<CR>
" noremap <silent> <C-F4> :bdelete<CR>:bn<CR>
" noremap <silent> <C-n> :enew<CR>

" adjust split window size
" nnoremap <down> :vertical resize-5<CR>
" nnoremap <up> :vertical resize+5<CR>
nnoremap <up> :res +5<CR>
nnoremap <down> :res -5<CR>
nnoremap <left> :vertical resize-5<CR>
nnoremap <right> :vertical resize+5<CR>

" to overcome accidental c-u/w to delete the word/line
inoremap <c-u> <c-g>u<c-u>
inoremap <c-w> <c-g>u<c-w>
inoremap , ,<c-g>u
inoremap . .<c-g>u
inoremap ; ;<c-g>u

" use <leader><Esc> to escape terminal mode
tnoremap <leader><Esc> <C-\><C-n>

" autosave on
let g:auto_save = 1
let g:auto_save_silent = 1

" load and reload vimrc
:command! LV source $MYVIMRC
:command! EV e $MYVIMRC

" auto root change by vim-roooter
let g:rooter_targets = '/,*'
let g:rooter_buftypes = ['']
let g:rooter_patterns = ['.git']

" edit as dos, to remove ^m
:command DOS e ++ff=dos | set ff=unix | w
" duplicate current window in Vertical
:command V vsplit
:command S split
:command RemoveTrailingSpace %s/\s\+$//e

" add comment string for bat, autohotkey files
"use `:lua print(vim.bo.filetype)` to check file type of current window
augroup MyGroup | au!
    autocmd FileType dosbatch setlocal commentstring=::\ %s
    autocmd FileType autohotkey setlocal commentstring=;\ %s
augroup END

let g:temp_cb_name = "temp_cb"


function! PowerClose(strong)

    let buffer_count = 0
    for i in range(0, bufnr("$"))
        if buflisted(i)
            let buffer_count += 1
        endif
    endfor

    let window_counter = 0
    windo let window_counter = window_counter + 1

    if (window_counter > 1 || stridx(expand('%'), "ipython.EXE") > 0)
        let l:cmd = "q"
    else
        if buffer_count <= 1
            let l:cmd = "q"
        else
            let l:cmd = "bd"
        endif
    endif

    if a:strong != 0
        let l:cmd .= "!"
    endif

    if expand('%') == g:temp_cb_name
        let l:cmd = "call delete('".g:temp_cb_name."') | bd!"
    endif

    if (&buftype == 'terminal' && window_counter == 1)
        normal i
    else
        echo "powercloser: ".cmd."| bc=".buffer_count."|; wc=".window_counter
        execute cmd
    endif
endfunction

nnoremap <silent> ZZ :call PowerClose(0)<cr>
nnoremap <silent> ZQ :call PowerClose(1)<cr>

function! ChooseBuffer(buffername)
    let bnr = bufwinnr(a:buffername)
    if bnr > 0
        execute bnr . "wincmd w"
    else
        " echom a:buffername . ' is not existent'
        silent execute 'vsplit ' . a:buffername
    endif
endfunction

noremap <silent><leader>y :call ChooseBuffer(g:temp_cb_name)<cr>Go<esc>p

if !has('nvim')
    " hunk navigation and viewing using signify
    nnoremap gK :SignifyDiff<cr>
    nnoremap gJ :SignifyHunkDiff<cr>
    nnoremap <leader>hr :SignifyHunkUndo<cr>
    vnoremap <leader>hr :SignifyHunkUndo<cr>
endif
