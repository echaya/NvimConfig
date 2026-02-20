try
    if has('persistent_undo')
        exe 'set undodir='.stdpath('data') . '/undo'
        set undolevels=1000
        set undofile
    endif
catch
    exe 'set undodir='.$HOME. '/undo'
    set undolevels=1000
    set undofile
endtry

set updatetime=100
set timeoutlen=500

" encoding
set tabstop=4 softtabstop=0 expandtab shiftwidth=4 smarttab
set fileencodings=ucs-bom,utf-8,utf-16,gbk,big5,gb18030,latin1
set enc=utf-8
" color, display, theme
set number relativenumber
set scrolloff=5
set showcmd
set showcmdloc=statusline
set shellslash
set showtabline=2
set wrap

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
    let g:FontSize = 9
    exe "set guifont=".MyFont.":h".FontSize
    function! AdjustFontSize(amount)
        let g:FontSize = g:FontSize+a:amount
        :execute "set guifont=".g:MyFont.":h" . g:FontSize
    endfunction
    noremap <C-=> :call AdjustFontSize(1)<CR>
    noremap <C--> :call AdjustFontSize(-1)<CR>
endif


" reopen just closed buffer to edit
nnoremap <silent> ZX :e #<CR>


" buffers management
set hidden
tnoremap <C-h> <Cmd>wincmd h<CR>
tnoremap <C-j> <Cmd>wincmd j<CR>
tnoremap <C-k> <Cmd>wincmd k<CR>
tnoremap <C-l> <Cmd>wincmd l<CR>
tnoremap <localleader>[ <Cmd>wincmd p<CR>
nnoremap <localleader>[ <Cmd>wincmd p<CR>
nnoremap <leader>= <Cmd>wincmd =<CR>


" to overcome accidental c-u/w to delete the word/line
inoremap <c-u> <c-g>u<c-u>
inoremap <c-w> <c-g>u<c-w>
inoremap , ,<c-g>u
inoremap . .<c-g>u
inoremap ; ;<c-g>u

" remove highlight
nnoremap <silent><C-c> <cmd>noh<CR><Esc>
nnoremap <silent><esc> <cmd>noh<CR><Esc>

" SAFE PASTE SYSTEM
let g:paste_threshold = 100000 " ~100KB

function! s:SafePaste(mode, key, force_reg) abort
    " A. Identify Register
    let l:reg = a:force_reg
    if l:reg == ''
        let l:reg = v:register
        if a:mode == 'i' | let l:reg = len(@+) > 0 ? '+' : '*' | endif
    endif

    let l:content = getreg(l:reg)
    let l:length = len(l:content)

    if l:length > g:paste_threshold
        let l:size_kb = l:length / 1024
        let l:msg = "Paste is HUGE (" . l:size_kb . " KB). Do you want to proceed?"
        " Returns 1 for Yes. If No/Cancel, we stop here.
        if confirm(l:msg, "&Yes\n&No", 2) != 1
            echo "Paste cancelled."
            return
        endif
    endif

    if a:mode == 'n'
        let l:cmd = 'normal! ' . v:count1 . '"' . l:reg . a:key
        execute l:cmd

    elseif a:mode == 'i'
        let l:keys = "\<Esc>:set paste\<Cr>a\<c-r>" . l:reg . "\<Esc>:set nopaste\<Cr>a"
        call feedkeys(l:keys, 'n')
    endif
endfunction

nnoremap <silent> p :call <SID>SafePaste('n', 'p', '')<CR>
nnoremap <silent> P :call <SID>SafePaste('n', 'P', '')<CR>

" diff windows
:command Dthis wind diffthis
:command Doff diffoff

" load and reload vimrc
:command! LV source $MYVIMRC
:command! EV e $MYVIMRC

" jump to the next / previous quickfix item
nnoremap [Q <cmd>cfirst<CR>
nnoremap [q <cmd>cp<CR>
nnoremap ]q <cmd>cn<CR>
nnoremap ]Q <cmd>clast<CR>
:command CC cclose

" centerize on page navigation
nnoremap n nzzzv
nnoremap N Nzzzv
nnoremap <C-u> <C-u>zz
nnoremap <C-d> <C-d>zz

" copy so to windows from WSL
:command CopySo !source ~/.config/nvim/config/copy_so.sh


"table-mode uses |t
let g:table_mode_syntax = 0


if !exists('g:snacks_main_cursorline_enabled')
  let g:snacks_main_cursorline_enabled = 1
endif
if !exists('g:snacks_vertical_cursor_enabled')
  let g:snacks_vertical_cursor_enabled = 0
endif

function! ApplyCursorLine() abort
  if get(g:, 'snacks_main_cursorline_enabled', 1)
    set cursorline
  else
    set nocursorline
  endif
  if get(g:, 'snacks_vertical_cursor_enabled', 0)
    set cursorcolumn
  else
    set nocursorcolumn
  endif
endfunction

augroup CursorLineManagementIndependent au!
  au InsertLeave,WinEnter *  call ApplyCursorLine()
  au InsertEnter,WinLeave *  set nocursorline |  set nocursorcolumn
augroup END

" add comment string for bat, autohotkey files
"use `:lua print(vim.bo.filetype)` to check file type of current window
augroup MyGroup | au!
    autocmd FileType dosbatch setlocal commentstring=::\ %s
    autocmd FileType autohotkey setlocal commentstring=;\ %s
augroup END

function! s:GetTabDisplayName(tabnr, bufnr)
    let current_tab = tabpagenr()
    let is_current = (a:tabnr == current_tab)
    let display_name = ''
    if a:bufnr == -1
        return '[No Window]'
    endif
    let filename = bufname(a:bufnr)
    let buftype = getbufvar(a:bufnr, '&buftype')
    if filename == '' && buftype != 'quickfix' && buftype != 'help'
        let display_name = '[No Name]'
    elseif buftype == 'help'
        let display_name = 'help:' . fnamemodify(filename, ':t:r')
    elseif buftype == 'quickfix'
        let display_name = 'quickfix'
    elseif buftype == 'terminal'
        let term_parts = split(filename, ':')
        if len(term_parts) > 1 && term_parts[-1] != ''
            let display_name = 'term:' . term_parts[-1]
        else
            let display_name = '[Terminal]'
        endif
    elseif buftype == 'nofile'
        if filename =~ '\/.'
            let display_name = substitute(filename, '.*\/\ze.', '', '')
        elseif filename != ''
            let display_name = filename
        else
            let display_name = '[Scratch]'
        endif
    else
        if is_current
            let full_path = fnamemodify(filename, ':p')
            if strlen(full_path) > 200
                let display_name = pathshorten(full_path)
            else
                let display_name = full_path
            endif
        else
            let display_name = fnamemodify(filename, ':t')
        endif
    endif
    if display_name == ''
        let display_name = '[No Name]'
    endif
    if getbufvar(a:bufnr, '&modified')
        let display_name = '+' . display_name
    endif
    return display_name
endfunction

" Creates dynamic highlight groups for the close button
function! s:SetupTabLineHighlights()
    " --- Get Colors ---
    " Get Error FG
    let err_fg_gui = synIDattr(hlID('Error'), 'fg', 'gui')
    let err_fg_cterm = synIDattr(hlID('Error'), 'fg', 'cterm')
    if err_fg_gui == '' | let err_fg_gui = 'Red' | endif
    if err_fg_cterm == '' | let err_fg_cterm = 'Red' | endif

    " Get TabLineSel BG
    let sel_bg_gui = synIDattr(hlID('TabLineSel'), 'bg', 'gui')
    let sel_bg_cterm = synIDattr(hlID('TabLineSel'), 'bg', 'cterm')
    if sel_bg_gui == '' | let sel_bg_gui = 'NONE' | endif
    if sel_bg_cterm == '' | let sel_bg_cterm = 'NONE' | endif

    " Get TabLine BG
    let norm_bg_gui = synIDattr(hlID('TabLine'), 'bg', 'gui')
    let norm_bg_cterm = synIDattr(hlID('TabLine'), 'bg', 'cterm')
    if norm_bg_gui == '' | let norm_bg_gui = 'NONE' | endif
    if norm_bg_cterm == '' | let norm_bg_cterm = 'NONE' | endif

    " --- Define Highlights ---
    " Active close button: Error FG, TabLineSel BG
    execute 'hi TabLineCloseActive'
    \   ' guifg=' . err_fg_gui . ' guibg=' . sel_bg_gui
    \   ' ctermfg=' . err_fg_cterm . ' ctermbg=' . sel_bg_cterm

    " Inactive close button: Error FG, TabLine BG
    execute 'hi TabLineCloseInactive'
    \   ' guifg=' . err_fg_gui . ' guibg=' . norm_bg_gui
    \   ' ctermfg=' . err_fg_cterm . ' ctermbg=' . norm_bg_cterm
endfunction

function! MyTabLine()
    let s = ''
    let current_tab = tabpagenr()
    let i = 1
    while i <= tabpagenr('$')
        let buflist = tabpagebuflist(i)
        let winnr_in_tab = tabpagewinnr(i)
        let bufnr = (winnr_in_tab > 0 && winnr_in_tab <= len(buflist)) ? buflist[winnr_in_tab - 1] : -1

        " Set main highlight
        let s .= '%' . i . 'T'
        if i == current_tab
            let s .= '%#TabLineSel#'
        else
            let s .= '%#TabLine#'
        endif

        " Get display name
        let file_display_name = s:GetTabDisplayName(i, bufnr)
        let s .= ' ' . i . ':' . file_display_name . ' '

        " Add a per-tab close button
        if tabpagenr('$') > 1
            " 1. Set highlight based on tab status
            if i == current_tab
                let s .= '%#TabLineCloseActive#'
            else
                let s .= '%#TabLineCloseInactive#'
            endif
            " 2. Add clickable close button
            let s .= '%' . i . 'X' . '✕ '
            " 3. Restore highlight group to the tab's main group
            if i == current_tab
                let s .= '%#TabLineSel#'
            else
                let s .= '%#TabLine#'
            endif
            " 4. Add a trailing space for separation
            let s .= ' '
        else
            let s .= '  ' " Add padding
        endif

        let i += 1
    endwhile

    " Fill the rest of the line
    let s .= '%#TabLineFill#'
    let s .= '%='

    return s
endfunction

set tabline=%!MyTabLine()

" Use an augroup to prevent duplicate autocmds
augroup MyTabLineConfig
    autocmd!
    " Redraw highlights whenever the colorscheme changes
    autocmd ColorScheme * call s:SetupTabLineHighlights()
augroup END

" Run setup once on load
call s:SetupTabLineHighlights()

"vim-fugitive
command! GCommit execute "tab Git diff --staged" | execute "vertical Git commit"
command GPush execute "Git! push"
nnoremap <leader>G <Cmd>tab G<cr>

augroup FugitiveCustomMaps
  autocmd!
  " unbind J/K from autoload/fugitive
  autocmd User FugitiveIndex,FugitiveObject,FugitiveCommit,FugitiveBlame silent! nunmap <buffer> J
  autocmd User FugitiveIndex,FugitiveObject,FugitiveCommit,FugitiveBlame silent! nunmap <buffer> K
augroup END
