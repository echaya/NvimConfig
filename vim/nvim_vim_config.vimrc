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

"Move to previous/next tabpage
noremap <silent> J :tabp<CR>
noremap <silent> K :tabn<CR>
noremap <silent> T :tabnew<CR>
noremap <silent> <Del> :tabc<CR>


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

" remove noh
nnoremap <silent><C-c> :noh<CR><Esc>

" formatted paste
inoremap <silent> <c-s-v> <Esc>:set paste<Cr>a<c-r>+<Esc>:set nopaste<Cr>a

" diff windows
:command Dthis wind diffthis
:command Doff diffoff

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

" copy so to windows from WSL
:command CopySo !source ~/.config/nvim/config/copy_so.sh


"table-mode uses default mapping start with <leader>t
let g:table_mode_syntax = 0

"vim-fugitive or mini.git
command! GC execute "Git diff --staged" | execute "Git commit"
command GP execute "Git! push"

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

" ============================================================================
"  Powerline Tabline Configuration
" ============================================================================
" Define the Nerd Font characters you want to use for separators.
"  = U+E0B0,  = U+E0B2
let g:pl_sep = ''
let g:pl_sep_left = ''
"  = U+E0B1,  = U+E0B3 (thin variants)
let g:pl_sep_thin = ''
let g:pl_sep_thin_left = ''


" ============================================================================
"  Highlight Setup
" ============================================================================
" This function reads the colors from the active colorscheme and creates
" the "bridging" highlight groups for the powerline separators.
function! s:SetupPowerlineHighlights()
    " Helper to get colors, with a fallback.
    function! s:GetColor(group, attr, mode, fallback)
        let id = hlID(a:group)
        if id == 0
            return a:fallback
        endif
        " The correct syntax is synIDattr(id, 'fg'/'bg', 'gui'/'cterm')
        let color = synIDattr(id, a:attr, a:mode)
        return (color == '' || color == -1) ? a:fallback : color
    endfunction

    " --- Get GUI Colors ---
    let s:bg_sel = s:GetColor('TabLineSel', 'bg', 'gui', 'Gray')
    let s:bg_norm = s:GetColor('TabLine', 'bg', 'gui', 'DarkGray')
    let s:bg_fill = s:GetColor('TabLineFill', 'bg', 'gui', 'LightGray')
    let s:fg_sel = s:GetColor('TabLineSel', 'fg', 'gui', 'Black')
    let s:fg_norm = s:GetColor('TabLine', 'fg', 'gui', 'White')

    " --- Create GUI highlight groups ---
    execute 'hi HlSelToNorm guifg=' . s:bg_sel . ' guibg=' . s:bg_norm
    execute 'hi HlNormToSel guifg=' . s:bg_norm . ' guibg=' . s:bg_sel
    execute 'hi HlNormToNorm guifg=' . s:fg_norm . ' guibg=' . s:bg_norm
    execute 'hi HlSelToFill guifg=' . s:bg_sel . ' guibg=' . s:bg_fill
    execute 'hi HlNormToFill guifg=' . s:bg_norm . ' guibg=' . s:bg_fill
    execute 'hi HlCloseBtn guifg=Red guibg=' . s:bg_sel
    execute 'hi HlCloseBtnInactive guifg=Gray guibg=' . s:bg_norm

    " --- Get CTerm Colors ---
    " Provide sensible numeric fallbacks for cterm
    let s:cbg_sel = s:GetColor('TabLineSel', 'bg', 'cterm', '238')
    let s:cbg_norm = s:GetColor('TabLine', 'bg', 'cterm', '235')
    let s:cbg_fill = s:GetColor('TabLineFill', 'bg', 'cterm', '234')
    let s:cfg_norm = s:GetColor('TabLine', 'fg', 'cterm', '252')
    let s:c_red = '196' " cterm for 'Red'
    let s:c_gray = '245' " cterm for 'Gray'
    let s:c_darkgray = '240' " cterm for 'DarkGray'

    " --- Create CTerm highlight groups ---
    execute 'hi HlSelToNorm ctermfg=' . s:cbg_sel . ' ctermbg=' . s:cbg_norm
    execute 'hi HlNormToSel ctermfg=' . s:cbg_norm . ' ctermbg=' . s:cbg_sel
    execute 'hi HlNormToNorm ctermfg=' . s:cfg_norm . ' ctermbg=' . s:cbg_norm
    execute 'hi HlSelToFill ctermfg=' . s:cbg_sel . ' ctermbg=' . s:cbg_fill
    execute 'hi HlNormToFill ctermfg=' . s:cbg_norm . ' ctermbg=' . s:cbg_fill
    execute 'hi HlCloseBtn ctermfg=' . s:c_red . ' ctermbg=' . s:cbg_sel
    execute 'hi HlCloseBtnInactive ctermfg=' . s:c_darkgray . ' ctermbg=' . s:cbg_norm
endfunction


" ============================================================================
"  Helper Function: Get Display Name (Updated)
" ============================================================================
function! s:GetTabDisplayName(tabnr, bufnr)
    let current_tab = tabpagenr()
    let is_current = (a:tabnr == current_tab)
    let display_name = ''

    " Handle edge case of no buffer (e.g., empty tab)
    if a:bufnr == -1
        return '[No Window]'
    endif

    let filename = bufname(a:bufnr)
    let buftype = getbufvar(a:bufnr, '&buftype')

    " Handle special buffer types first
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
        " This is a regular file buffer
        if is_current
            let full_path = fnamemodify(filename, ':p')
            " Shorten path if it's too long
            if strlen(full_path) > 100
                let display_name = pathshorten(full_path)
            else
                let display_name = full_path
            endif
        else
            let display_name = fnamemodify(filename, ':t')
        endif
    endif

    " Final fallback check
    if display_name == ''
        let display_name = '[No Name]'
    endif

    " Prepend modified flag
    if getbufvar(a:bufnr, '&modified')
        let display_name = '+' . display_name
    endif

    return display_name
endfunction

function! MyTabLine()
    let s = ''
    let current_tab = tabpagenr()
    let last_tab = tabpagenr('$')
    let i = 1

    " Loop through all existing tab pages
    while i <= last_tab
        " Get the buffer number of the currently active window in tab 'i'
        let buflist = tabpagebuflist(i)
        let winnr_in_tab = tabpagewinnr(i)
        let bufnr = (winnr_in_tab > 0 && winnr_in_tab <= len(buflist)) ? buflist[winnr_in_tab - 1] : -1

        let is_current = (i == current_tab)
        let is_next_current = (i + 1 == current_tab)

        " --- 1. Draw Tab Label ---
        " Set main highlight
        let s .= (is_current ? '%#TabLineSel#' : '%#TabLine#')
        " Set clickable region to switch to tab
        let s .= '%' . i . 'T'

        " Build label content
        let file_display_name = s:GetTabDisplayName(i, bufnr)
        let s .= ' ' . i . ':' . file_display_name . ' '

        " Add close button
        if last_tab > 1
            " Use a different highlight for the close button
            let s .= (is_current ? '%#HlCloseBtn#' : '%#HlCloseBtnInactive#')
            " Set clickable region to close tab
            let s .= '%' . i . 'X' . '✕ '
        else
            let s .= ' ' " Add padding
        endif

        " --- 2. Draw Separator ---
        if is_current
            if i == last_tab
                " Current tab is the last tab, bridge to Fill
                let s .= '%#HlSelToFill#' . g:pl_sep
            else
                " Current tab, bridge to next Normal tab
                let s .= '%#HlSelToNorm#' . g:pl_sep
            endif
        else
            if is_next_current
                " This is a Normal tab, bridge to next Selected tab
                let s .= '%#HlNormToSel#' . g:pl_sep
            elseif i == last_tab
                " This is the last Normal tab, bridge to Fill
                let s .= '%#HlNormToFill#' . g:pl_sep
            else
                " Normal tab, bridge to next Normal tab (use thin separator)
                let s .= '%#HlNormToNorm#' . g:pl_sep_thin . '%#TabLine#'
            endif
        endif

        let i += 1
    endwhile

    " Fill the rest of the line and align right
    let s .= '%#TabLineFill#'
    let s .= '%='

    return s
endfunction

" Set the tabline to use our custom function
set tabline=%!MyTabLine()

" Use an augroup to prevent duplicate autocmds
augroup MyTabLineConfig
    autocmd!
    " Redraw highlights whenever the colorscheme changes
    autocmd ColorScheme * call s:SetupPowerlineHighlights()
augroup END

" Run setup once on load
call s:SetupPowerlineHighlights()
