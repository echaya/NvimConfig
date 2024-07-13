" system
set tabstop=8 softtabstop=0 expandtab shiftwidth=4 smarttab
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
    exe 'set undodir='.g:WorkDir.'neovim\\undo'
    set undolevels=10000
    set undofile
endif
"open the cursor at the last saved position
au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

set splitbelow
set splitright
filetype plugin indent on
" encoding
set fileencodings=ucs-bom,utf-8,utf-16,gbk,big5,gb18030,latin1
set enc=utf-8
" color, display, theme
syntax on
set t_Co=256
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

if has('gui_running')
    set guioptions-=e
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
try
    colorscheme onedark
catch
    colorscheme industry
endtry

if has('nvim')
    " Move to previous/next tab
    nnoremap <silent>    J <Cmd>BufferPrevious<CR>
    nnoremap <silent>    K <Cmd>BufferNext<CR>
    " Re-order to previous/next
    nnoremap <silent>    <A-,> <Cmd>BufferMovePrevious<CR>
    nnoremap <silent>    <A-.> <Cmd>BufferMoveNext<CR>
    " Close buffer using ZZ
    " nnoremap <silent>    <A-x> <Cmd>BufferClose<CR>
    nnoremap <silent>    ZX <Cmd>BufferRestore<CR>
    " Magic buffer-picking mode
    nnoremap <silent> <C-P>    <Cmd>BufferPick<CR>
    " Pin/unpin buffer
    nnoremap <silent>    <A-p> <Cmd>BufferPin<CR>

    set termguicolors
else
    noremap <silent> J :bp<CR>
    noremap <silent> K :bn<CR>
    let &t_SI = "\e[6 q"
    let &t_EI = "\e[2 q"
endif

" Move to previous/next tabpage
noremap <silent> <PageUp> :tabp<CR>
noremap <silent> <PageDown> :tabn<CR>
noremap <silent> <Del> :tabc<CR>
noremap <silent> <Insert> :tabnew<CR>

" augroup ThemeSwitch
"   autocmd!
"     autocmd BufEnter * colorscheme onedark
"     autocmd BufEnter *.md colorscheme pencil
" augroup END

augroup CursorLine
    au!
    au VimEnter * setlocal cursorline
    au WinEnter * setlocal cursorline
    au BufWinEnter * setlocal cursorline
    au WinLeave * setlocal nocursorline
augroup END

au InsertLeave,WinEnter * set cursorline
au InsertEnter,WinLeave * set nocursorline

augroup numbertoggle
  autocmd!
  autocmd BufEnter,FocusGained,InsertLeave * set relativenumber
  autocmd BufLeave,FocusLost,InsertEnter   * set norelativenumber
augroup END


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
" set cd to current dir
nnoremap <leader>cd :lcd %:h<CR>
" edit as dos, to remove ^m
:command DOS e ++ff=dos | set ff=unix | w

"Plug management
let g:plug_window = 'vertical topleft new'
let g:plug_pwindow = 'above 12'

let g:temp_cb_name = "temp_cb"

function! PowerClose(strong)
    
    let cnt = 0

    for i in range(0, bufnr("$"))
        if buflisted(i) 
            let cnt += 1 
        endif
    endfor

    if cnt <= 1
        let l:cmd = "q"
    else
        if has('nvim')
            let l:cmd = "BufferClose"
        else
            let l:cmd = "bd"
        endif
    endif

    if a:strong != 0
        let l:cmd .= "!"
    endif

    if expand('%') == g:temp_cb_name
        let l:cmd = "call delete('".g:temp_cb_name."') | bd!"
    else
        if stridx(expand('%'),"HEAD~")
            let l:cmd = "q"
        endif
    endif
    " echo cmd
    execute cmd

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

noremap <silent><leader>+ :call ChooseBuffer(g:temp_cb_name)<cr>Go<esc>p

if !has('nvim')
    " hunk navigation and viewing using signify
    nnoremap gK :SignifyDiff<cr>
    nnoremap gJ :SignifyHunkDiff<cr>
    nnoremap gZ :SignifyHunkUndo<cr>
    nmap gj <plug>(signify-next-hunk)
    nmap gk <plug>(signify-prev-hunk)
endif
