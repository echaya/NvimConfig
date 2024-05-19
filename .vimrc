"NOTICE: one need to create a file under vnim working directory and source this file. e.g.,
"source d:\vnim\init.vim
"To find the working directory is exactly, use the command :echo stdpath('config') inside Neovim.
"
"universal settings
let WorkDir = 'D:\\Dropbox\\'

"change <leader> to SPACE
nnoremap <SPACE> <Nop>
let mapleader=" "
"open the cursor at the last svaed position
au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

"seaerch
set incsearch
set hlsearch
set ignorecase
set smartcase
nnoremap <silent><Esc> :noh<CR><Esc>

"copy paste
set clipboard=unnamed
inoremap <silent> <c-v> <Esc>:set paste<Cr>a<c-r>+<Esc>:set nopaste<Cr>a
" change default Y behavior to match with D, C, etc
noremap Y y$

" use 'move' as to cut text into register
nnoremap m d
xnoremap m d
nnoremap mm dd
nnoremap M D
" use gj to join
nnoremap gj J
"use <leader>m to mark
nnoremap <leader>m m

" tab key
" inoremap <S-Tab> <C-D>
" inoremap <Tab> <C-T>

" insert lines without entering insert mode
noremap <silent> <leader>o :<C-u>call append(line("."),   repeat([""], v:count1))<CR>
nnoremap <silent> <leader>O :<C-u>call append(line(".")-1, repeat([""], v:count1))<CR>


" swap v and Ctrl-v
nnoremap  v <C-V>
nnoremap <C-V> v
" ex command remap
:command! Wq wq
:command! W w
:command! Q q
:command! LV source $MYVIMRC
:command! EV e $MYVIMRC


"adding more character objectives
for s:char in [',','/', '*', '%', '_', '`', '!']
  execute 'xnoremap i' . s:char . ' :<C-u>normal! T' . s:char . 'vt' . s:char . '<CR>'
  execute 'onoremap i' . s:char . ' :normal vi' . s:char . '<CR>'
  execute 'xnoremap a' . s:char . ' :<C-u>normal! F' . s:char . 'vf' . s:char . '<CR>'
  execute 'onoremap a' . s:char . ' :normal va' . s:char . '<CR>'
endfor
" execute macro at visual range, does not stop when no match
xnoremap @ :<C-u>call ExecuteMacroOverVisualRange()<CR>
function! ExecuteMacroOverVisualRange()
  echo "@".getcmdline()
  execute ":'<,'>normal @".nr2char(getchar())
endfunction

" toggle UPPER CASE, lower case and Title Case in visual mode
function! TwiddleCase(str)
  if a:str ==# toupper(a:str)
    let result = tolower(a:str)
  elseif a:str ==# tolower(a:str)
    let result = substitute(a:str,'\(\<\w\+\>\)', '\u\1', 'g')
  else
    let result = toupper(a:str)
  endif
  return result
endfunction
vnoremap ~ y:call setreg('', TwiddleCase(@"), getregtype(''))<CR>gv""Pgv


"table-mode
noremap <leader>\ :TableModeToggle<CR>
noremap <leader>= :TableModeRealign<CR>

"""env specific

"Plug management
if exists('g:vscode')

    " call plug#begin('$VIM\vimfiles\plugged')
    " call plug#begin('~/AppData/Local/nvim/plugged')
    call plug#begin(WorkDir.'Neovim\\nvim-win64\\share\\nvim\\vimfiles\\plugged')
        Plug 'unblevable/quick-scope'
        Plug 'machakann/vim-sandwich'
        " Plug 'tpope/vim-surround'
        Plug 'tpope/vim-repeat'
        Plug 'tpope/vim-commentary'
        Plug 'svermeulen/vim-cutlass'
	" Plug 'echaya/vscode-easymotion'
        Plug 'tpope/vim-speeddating'
        " Plug 'mg979/vim-visual-multi'
        "text obj plugin
        Plug 'kana/vim-textobj-user' "dependent plugin
        Plug 'kana/vim-textobj-indent' "ai,ii, aI, iI
        Plug 'Julian/vim-textobj-variable-segment' "av,iv
        Plug 'bps/vim-textobj-python' "ac,ic,af,if
        Plug 'dhruvasagar/vim-table-mode',{'on':'TableModeToggle'} "table model

        if has('nvim')
            Plug 'ggandor/leap.nvim'
        endif

    call plug#end()
    "display
    "fix quick-scope and sandwich for vscode
    highlight QuickScopePrimary guifg='#afff5f' gui=underline ctermfg=155 cterm=underline
    highlight QuickScopeSecondary guifg='#5fffff' gui=underline ctermfg=81 cterm=underline
    highlight OperatorSandwichBuns guifg='#aa91a0' gui=underline ctermfg=172 cterm=underline
    highlight OperatorSandwichChange guifg='#edc41f' gui=underline ctermfg='yellow' cterm=underline
    highlight OperatorSandwichAdd guibg='#b1fa87' gui=none ctermbg='green' cterm=none
    highlight OperatorSandwichDelete guibg='#cf5963' gui=none ctermbg='red' cterm=none

    nnoremap <silent> <s-j> <Cmd>call VSCodeCall('workbench.action.previousEditor')<CR>
    nnoremap <silent> <s-k> <Cmd>call VSCodeCall('workbench.action.nextEditor')<CR>
    nnoremap <silent> gD <Cmd>call VSCodeNotify('editor.action.revealDefinitionAside')<CR>
    nnoremap <silent> o <Cmd>call VSCodeNotify('editor.action.insertLineAfter')<CR>i
    nnoremap <silent> O <Cmd>call VSCodeNotify('editor.action.insertLineBefore')<CR>i
    nnoremap <silent> <up> <Cmd>call VSCodeCall('workbench.action.increaseViewSize')<CR>
    nnoremap <silent> <down> <Cmd>call VSCodeCall('workbench.action.decreaseViewSize')<CR>
    " need to comment out multi-cursor from the below folder
    " c:\Users\echay\.vscode\extensions\asvetliakov.vscode-neovim-0.0.82\vim\vscode-insert.vim
    " xnoremap gc  <Plug>VSCodeCommentary
    " nnoremap gc  <Plug>VSCodeCommentary
    " onoremap gc  <Plug>VSCodeCommentary
    " nnoremap gcc <Plug>VSCodeCommentaryLine

else

    " call plug#begin('$VIM\vimfiles\plugged')
    call plug#begin(WorkDir.'Neovim\\nvim-win64\\share\\nvim\\vimfiles\\plugged')
        " Plug 'ggandor/lightspeed.nvim'
        " ui, display
        Plug '/joshdick/onedark.vim'
        Plug '/preservim/vim-colors-pencil'
        Plug 'itchyny/lightline.vim'

        " markdown plugin
        Plug 'godlygeek/tabular' "prerequisite for vim-markdown
        Plug 'plasticboy/vim-markdown'
        Plug 'vimwiki/vimwiki'
        " Plug 'mzlogin/vim-markdown-toc' "table of content, not so useful?
        " Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for':'markdown'}
        Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}
        " Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && yarn install' }
        Plug 'dhruvasagar/vim-table-mode',{'on':'TableModeToggle'}
        Plug 'ferrine/md-img-paste.vim'
        "text obj plugin
        Plug 'kana/vim-textobj-user' "dependent plugin
        Plug 'kana/vim-textobj-indent' "ai,ii, aI, iI
        Plug 'Julian/vim-textobj-variable-segment' "av,iv
        Plug 'bps/vim-textobj-python' "ac,ic,af,if
        " log plugin
        Plug 'MTDL9/vim-log-highlighting'

        ""nvim specific and vim alternative
        if has('nvim')
            Plug 'numirias/semshi', {'do': ':UpdateRemotePlugins'}   "neovim only
            Plug 'ggandor/leap.nvim'
        else
            Plug 'vim-python/python-syntax'
        endif

        " Plug 'preservim/tagbar' "to show function and variable defined
        " Plug 'ludovicchabant/vim-gutentags'
        " Plug 'sillybun/vim-repl'
        " Plug 'tpope/vim-fugitive'

        "utility plug-in
        Plug 'svermeulen/vim-cutlass' "prevent C, D, X to write to reg
        Plug 'mileszs/ack.vim' "to use ripgrep for keyword search through files
        Plug 'ctrlpvim/ctrlp.vim' "fuzzy file search
        Plug 'preservim/nerdtree' "folder structure
        " Plug 'tpope/vim-surround'
        Plug 'tpope/vim-repeat' "repeat for non-native vim actions
        Plug 'tpope/vim-commentary' "comment / uncomment code
        Plug 'tpope/vim-speeddating'
        Plug 'machakann/vim-sandwich' "substitute for vim-surrond
        Plug 'unblevable/quick-scope' "highlight the 1st / 2nd occurance in line
        Plug 'ap/vim-buftabline' "butify the tab line
        Plug 'mhinz/vim-startify' "butify the vim start up page
        Plug '907th/vim-auto-save' "to auto-save files

        "lsp
        Plug 'neovim/nvim-lspconfig'
        Plug 'hrsh7th/cmp-nvim-lsp'
        Plug 'hrsh7th/cmp-buffer'
        Plug 'hrsh7th/cmp-path'
        Plug 'hrsh7th/cmp-cmdline'
        Plug 'hrsh7th/nvim-cmp'
        Plug 'saadparwaiz1/cmp_luasnip'
        Plug 'L3MON4D3/LuaSnip', {'tag': 'v2.*', 'do': 'make install_jsregexp'}
        Plug 'rafamadriz/friendly-snippets'
        " Plug 'neoclide/coc.nvim', {'branch': 'release'}
        " Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
        " Plug 'junegunn/fzf.vim' "replicate ctrlp + ack plugin functionalities with preview

        " Plug 'zirrostig/vim-schlepp' "alt+<arrow> for move and duplication of blocks
    call plug#end()

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
        exe 'set undodir='.WorkDir.'Neovim\undo'
        set undolevels=10000
        set undofile
    endif
    set splitbelow
    set splitright
    filetype plugin indent on
    " encoding
    set fileencodings=ucs-bom,utf-8,utf-16,gbk,big5,gb18030,latin1
    set enc=utf-8
    " color, display, theme
    syntax on
    set t_Co=256
    set cursorline
    set number relativenumber
    set scrolloff=3
    set splitright
    set splitbelow
    set wrap
    set linebreak
    set showcmd
    set noshowmode
    set ruler
    "coloring


    function! CocCurrentFunction()
        return get(b:, 'coc_current_function', '')
    endfunction

    let g:lightline = {
          \ 'colorscheme': 'onedark',
          \ 'active': {
          \   'left': [ [ 'mode', 'paste' ],
          \             [ 'cocstatus', 'currentfunction', 'readonly', 'filename', 'modified' ] ]
          \ },
          \ 'component_function': {
          \   'cocstatus': 'coc#status',
          \   'currentfunction': 'CocCurrentFunction'
          \ },
          \ }
    try
            colorscheme onedark
    catch
            colorscheme industry
    endtry

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

    augroup numbertoggle
      autocmd!
      autocmd BufEnter,FocusGained,InsertLeave * set relativenumber
      autocmd BufLeave,FocusLost,InsertEnter   * set norelativenumber
    augroup END


    " Escape shortcut
    inoremap jk <ESC>
    " edit as dos, to remove ^m
    :command DOS e ++ff=dos | set ff=unix | w
    " buffers management
    set hidden
    noremap <silent> <s-j> :bp<CR>
    noremap <silent> <s-k> :bn<CR>
    noremap <A-h> <C-w><C-h>
    noremap <A-j> <C-w><C-j>
    noremap <A-k> <C-w><C-k>
    noremap <A-l> <C-w><C-l>
    " noremap <silent> <C-F4> :bdelete<CR>:bn<CR>
    " noremap <silent> <C-n> :enew<CR>
    :command Bd bd

    " adjust split window size
    nnoremap <down> :vertical resize-5<CR>
    nnoremap <up> :vertical resize+5<CR>
    " map <up> :res +5<CR>
    " map <down> :res -5<CR>
    " map <left> :vertical resize-5<CR>
    " map <right> :vertical resize+5<CR>

    " to overcome accidental c-u/w to delete the word/line
    inoremap <c-u> <c-g>u<c-u>
    inoremap <c-w> <c-g>u<c-w>

    " autosave on
    let g:auto_save = 1
    let g:auto_save_silent = 1

    " set cd to current dir
    nnoremap <leader>cd :lcd %:h<CR>

    ""fzf config
    "let g:fzf_layout = { 'window': { 'width': 0.9, 'height': 0.9 } }
    "let $FZF_DEFAULT_OPTS="--ansi --preview-window 'right:60%' --margin=1,4"
    "let $PATH = "C:\\Program Files\\Git\\usr\\bin;" . $PATH
    ""!! note: fd need to be installed separated before using in fd
    ""ignored file search is configured @ c:\Users\echay\AppData\Roaming\fd\ignore
    "let $FZF_DEFAULT_COMMAND = 'fd --type f --color always'
    "command! -bang -nargs=* Rg
    "  \ call fzf#vim#grep(
    "  \   'rg --column --line-number --no-heading --color=always --smart-case -- '.shellescape(<q-args>), 1,
    "  \   fzf#vim#with_preview(), <bang>0)
    "nnoremap <Leader>? :Rg<Space>

    " use ripgrep for ack
    let g:ackprg = "rg --vimgrep --type-not sql --smart-case"
    let g:ack_autoclose = 1
    let g:ack_use_cword_for_empty_search = 1
    nnoremap <Leader>/ :Ack!<Space>
    cnoreabbrev Ack Ack!

    " quick-scope specs
    let g:qs_lazy_highlight = 0
    highlight QuickScopePrimary guifg='#afff5f' gui=underline ctermfg=155 cterm=underline
    highlight QuickScopeSecondary guifg='#5fffff' gui=underline ctermfg=81 cterm=underline
    " augroup qs_colors
    "     autocmd!
    "     autocmd ColorScheme * highlight QuickScopePrimary guifg='#afff5f' gui=underline ctermfg=155 cterm=underline
    "     autocmd ColorScheme * highlight QuickScopeSecondary guifg='#5fffff' gui=underline ctermfg=81 cterm=underline
    " augroup END

    " NERDTree
    noremap <A-b>  :NERDTreeToggle<CR>

     " ctrlp config
     let g:ctrlp_working_path_mode = 'c'
     let g:ctrlp_cache_dir = WorkDir.'Neovim\\config\\.cache\\ctrlp'
     set wildignore+=*\\tmp\\*,*.swp,*.zip,*.exe,*.pyc  " Windows

    let g:ctrlp_custom_ignore = '\v[\/]\.(git|hg|svn)$'
    let g:ctrlp_custom_ignore = {
      \ 'dir':  '\v[\/]\.(git|hg|svn|ipynb_checkpoints)$',
      \ 'file': '\v\.(exe|so|dll|json)$',
      \ 'link': 'some_bad_symbolic_links',
      \ }
    " let g:ctrlp_map = '<F2>'
    let g:ctrlp_by_filename = 1
    let g:ctrlp_map = ''
    nnoremap <a-p> :CtrlPMixed<cr>


    "enable python config
    " exe 'source '.WorkDir.'neovim\\config\\coc.vimrc'
    exe 'source '.WorkDir.'neovim\\config\\python.vimrc'
    exe 'source '.WorkDir.'neovim\\config\\md.vimrc'
    exe 'source '.WorkDir.'neovim\\config\\learnvim.vimrc'
endif

runtime macros/sandwich/keymap/surround.vim


exe 'luafile '.WorkDir.'neovim\\config\\lua_config.lua'
