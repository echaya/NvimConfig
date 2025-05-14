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
set timeoutlen=500

set splitbelow
set splitright
filetype plugin indent on
" encoding
set fileencodings=ucs-bom,utf-8,utf-16,gbk,big5,gb18030,latin1
set enc=utf-8
" color, display, theme
syntax on
set number relativenumber
set scrolloff=5
set splitright
set splitbelow
set wrap
set linebreak
set showcmd
set noshowmode
set ruler
set shellslash
set showtabline=2
set fillchars = "eob: "
set signcolumn=yes

if !has('unix')
    let &shell = 'pwsh -nologo -noexit'
    let &shellcmdflag = '-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;'
    let &shellredir = '-RedirectStandardOutput %s -NoNewWindow -Wait'
    let &shellpipe = '2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode'
    set shellquote= shellxquote=
endif

if has('gui_running')
    set guioptions-=e
    let g:MyFont = "Iosevka_NF"
    let g:FontSize = 10
    exe "set guifont=".MyFont.":h".FontSize
    function! AdjustFontSize(amount)
        let g:FontSize = g:FontSize+a:amount
        :execute "set guifont=".g:MyFont.":h" . g:FontSize
    endfunction
    noremap <C-=> :call AdjustFontSize(1)<CR>
    noremap <C--> :call AdjustFontSize(-1)<CR>
endif

if has('termguicolors')
    set termguicolors
endif

" Navigate buffers. use :bufferN to jump based on buffer number
"noremap <silent> J :bp<CR>
"noremap <silent> K :bn<CR>
nnoremap <silent> ZX :e #<CR>

"Move to previous/next tabpage
noremap <silent> J :tabp<CR>
noremap <silent> K :tabn<CR>
noremap <silent> H :0tabnew<CR>
noremap <silent> L :tabnew<CR>
noremap <silent> <PageUp> :tabp<CR>
noremap <silent> <PageDown> :tabn<CR>
noremap <silent> <Del> :tabc<CR>
noremap <silent> <Insert> :tabnew<CR>

augroup CursorLine
    au!
    au InsertLeave,WinEnter * set cursorline
    au InsertEnter,WinLeave * set nocursorline
augroup END


" buffers management
set hidden
" noremap <silent> <s-j> :bp<CR>
" noremap <silent> <s-k> :bn<CR>
noremap <C-h> <C-w><C-h>
noremap <C-j> <C-w><C-j>
noremap <C-k> <C-w><C-k>
noremap <C-l> <C-w><C-l>
tnoremap <C-h> <Cmd>wincmd h<CR>
tnoremap <C-j> <Cmd>wincmd j<CR>
tnoremap <C-k> <Cmd>wincmd k<CR>
tnoremap <C-l> <Cmd>wincmd l<CR>
tnoremap <localleader>[ <Cmd>wincmd p<CR>
nnoremap <localleader>[ <Cmd>wincmd p<CR>
nnoremap <leader>= <Cmd>wincmd =<CR>
" noremap <silent> <C-F4> :bdelete<CR>:bn<CR>
" noremap <silent> <C-n> :enew<CR>

" adjust split window size
" nnoremap <down> :vertical resize-5<CR>
" nnoremap <up> :vertical resize+5<CR>
nnoremap <up> :res +2<CR>
nnoremap <down> :res -2<CR>
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

" <leader>gc to comment out and copy the line
nmap <leader>gc gccyypgcc
xmap <leader>gc ygvgc`>p

" autosave on
let g:auto_save = 1
let g:auto_save_silent = 1

" load and reload vimrc
:command! LV source $MYVIMRC
:command! EV e $MYVIMRC

" jump to the next / previous quickfix item
nnoremap [q <cmd>cp<CR>
nnoremap ]q <cmd>cn<CR>
:command CC cclose

" centerize on page navigation
nnoremap n nzzzv
nnoremap N Nzzzv
nnoremap <C-u> <C-u>zz
nnoremap <C-d> <C-d>zz


" edit as dos, to remove ^m
:command DOS e ++ff=dos | set ff=unix | w
" duplicate current window in Vertical
:command V vsplit
:command S split
:command RemoveTrailingSpace %s/\s\+$//e
:command CopySo !source ~/.config/nvim/config/copy_so.sh
" convert # In[ ]: => ### Cell
:command ReplaceIn %s/#\s*In\[\s*\d*\s*\]\?:/###/g

:command Dthis wind diffthis
:command Doff diffoff

nnoremap <leader>gb <CMD>execute '!start ' .. shellescape(expand('<cfile>'), v:true)<CR>

"table-mode uses default mapping start with <leader>t
let g:table_mode_syntax = 0

"vim-fugitive or mini.git
command! GC execute "Git diff --staged" | execute "Git commit"
command GP execute "Git! push"

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
            let l:cmd = "wq"
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
        "echo "powercloser: ".cmd."| bc=".buffer_count."|; wc=".window_counter
        execute cmd
    endif
endfunction

if has("nvim")
    nnoremap <silent> ZZ <cmd>Noice dismiss<cr> <cmd>lua Snacks.bufdelete()<cr>
else
    nnoremap <silent> ZZ <cmd>call PowerClose(0)<cr>
endif

function! ChooseBuffer(buffername)
    let bnr = bufwinnr(a:buffername)
    if bnr > 0
        execute bnr . "wincmd w"
    else
        " echom a:buffername . ' is not existent'
        silent execute 'vsplit ' . a:buffername
    endif
endfunction

"noremap <silent><leader>y :call ChooseBuffer(g:temp_cb_name)<cr>Go<esc>p

function! MyTabLine()
    let s = ''
    let current_tab = tabpagenr()
    let i = 1

    " Loop through all existing tab pages
    while i <= tabpagenr('$')
        let buflist = tabpagebuflist(i)
        let winnr_in_tab = tabpagewinnr(i)
        if winnr_in_tab > 0 && winnr_in_tab <= len(buflist)
            let bufnr = buflist[winnr_in_tab - 1]
        else
            let bufnr = -1
        endif
        let s .= '%' . i . 'T'
        if i == current_tab
            let s .= '%#TabLineSel#'
        else
            let s .= '%#TabLine#'
        endif
        let s .= ' ' . i . ' '

        let filename = bufname(bufnr)
        let buftype = getbufvar(bufnr, '&buftype')
        let file_display_name = ''
        if bufnr == -1 "
            let file_display_name = '[No Window]'
        elseif filename == '' && buftype != 'quickfix' && buftype != 'help'
            let file_display_name = '[No Name]'
        elseif buftype == 'help'
            let file_display_name = 'help:' . fnamemodify(filename, ':t:r')
        elseif buftype == 'quickfix'
            let file_display_name = 'quickfix'
        elseif buftype == 'terminal'
            let term_parts = split(filename, ':')
            if len(term_parts) > 1 && term_parts[-1] != ''
                let file_display_name = 'term:' . term_parts[-1]
            else
                let file_display_name = '[Terminal]'
            endif
        elseif buftype == 'nofile'
            if filename =~ '\/.'
                let file_display_name = substitute(filename, '.*\/\ze.', '', '')
            elseif filename != ''
                let file_display_name = filename
            else
                let file_display_name = '[Scratch]'
            endif
        else
            if i == current_tab
                let full_path = fnamemodify(filename, ':p')
                if strlen(full_path) > 100
                    let file_display_name = pathshorten(full_path)
                else
                    let file_display_name = full_path
                endif
            else
                let file_display_name = fnamemodify(filename, ':t')
            endif
            if getbufvar(bufnr, '&modified')
                let file_display_name = '+' . file_display_name
            endif
        endif
        if file_display_name == ''
            let file_display_name = '[No Name]'
        endif

        let s .= ' ' . file_display_name
        if i < tabpagenr('$')
            let s .= ' %#TabLine#|'
        else
            let s .= ' '
        endif

        let i += 1
    endwhile

    let s .= '%#TabLineFill#'
    let s .= '%='
    if tabpagenr('$') > 1
        let s .= '%999X' . '✕ '
    endif
    return s

endfunction

set tabline=%!MyTabLine()
