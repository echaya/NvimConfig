"NOTICE: one need to create a file under vnim working directory and source this file. e.g.,
"source d:\vnim\init.vim
"To find the working directory is exactly, use the command :echo stdpath('config') inside Neovim.
"
"set work directory for nvim
let WorkDir = 'D:/Dropbox/'
"universal settings
"change <leader> to SPACE
nnoremap <SPACE> <Nop>
let mapleader=" "
nnoremap ZZ <Nop>
nnoremap Z <Nop>

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
" using <leader> j to join lines
noremap <leader>j J

" insert lines without entering insert mode
noremap <silent> <leader>o :<C-u>call append(line("."),   repeat([""], v:count1))<CR>
nnoremap <silent> <leader>O :<C-u>call append(line(".")-1, repeat([""], v:count1))<CR>

" use backspace to trigger edit
nnoremap <silent> <backspace> ciw


" swap v and Ctrl-v
nnoremap  v <C-V>
nnoremap <C-V> v
" ex command remap
:command! Wq wq
:command! W w
:command! Q q
:command Bd bd


" adding more character objectives
for s:char in [',','/', '*', '%', '_', '`', '!','.']
  execute 'xnoremap i' . s:char . ' :<C-u>normal! T' . s:char . 'vt' . s:char . '<CR>'
  execute 'onoremap i' . s:char . ' :normal vi' . s:char . '<CR>'
  execute 'xnoremap a' . s:char . ' :<C-u>normal! F' . s:char . 'vf' . s:char . '<CR>'
  execute 'onoremap a' . s:char . ' :normal va' . s:char . '<CR>'
endfor

" execute macro at visual range, does not stop when no match
function! ExecuteMacroOverVisualRange()
  echo "@".getcmdline()
  execute ":'<,'>normal @".nr2char(getchar())
endfunction
xnoremap @ :<C-u>call ExecuteMacroOverVisualRange()<CR>

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


call plug#begin(WorkDir..'Neovim/nvim-win64/share/nvim/vimfiles/plugged')
      " universal plugins
      Plug 'unblevable/quick-scope'
      Plug 'tpope/vim-repeat'
      Plug 'tpope/vim-speeddating'
      Plug 'svermeulen/vim-cutlass'
      "text obj plugin
      Plug 'kana/vim-textobj-user' "dependent plugin
      Plug 'kana/vim-textobj-indent' "ai,ii, aI, iI
      Plug 'Julian/vim-textobj-variable-segment' "av,iv
      Plug 'bps/vim-textobj-python' "ac,ic,af,if
      "neovim plugin
      Plug 'ggandor/leap.nvim'
      Plug 'kylechui/nvim-surround'

if exists('g:vscode')
    call plug#end()

    nnoremap <silent> J <Cmd>lua require('vscode').call('workbench.action.previousEditor')<CR>
    nnoremap <silent> K <Cmd>lua require('vscode').call('workbench.action.nextEditor')<CR>
    nnoremap <silent> ZZ <Cmd>lua require('vscode').call('workbench.action.closeActiveEditor')<CR>
    nnoremap <silent> ZX <Cmd>lua require('vscode').call('workbench.action.reopenClosedEditor')<CR>
    nnoremap <silent> <a-,> <Cmd>lua require('vscode').call('workbench.action.moveEditorLeftInGroup')<CR>
    nnoremap <silent> <a-.> <Cmd>lua require('vscode').call('workbench.action.moveEditorRightInGroup')<CR>
    " pin and unpin editor using a-p using vscode shortcut
    nnoremap <silent> - <Cmd>lua require('vscode').call('workbench.view.explorer')<CR>

    nnoremap <silent> gD <Cmd>lua require('vscode').action('editor.action.revealDefinitionAside')<CR>
    nnoremap <silent> o <Cmd>lua require('vscode').action('editor.action.insertLineAfter')<CR>i
    nnoremap <silent> O <Cmd>lua require('vscode').action('editor.action.insertLineBefore')<CR>i

    nnoremap <silent> gJ <Cmd>lua require('vscode').action('editor.action.dirtydiff.next')<CR>
    nnoremap <silent> gK <Cmd>lua require('vscode').action('editor.action.dirtydiff.previous')<CR>
    nnoremap <silent> gj <Cmd>lua require('vscode').action('workbench.action.editor.nextChange')<CR>
    nnoremap <silent> gk <Cmd>lua require('vscode').action('workbench.action.editor.previousChange')<CR>

    nnoremap <silent> == <Cmd>lua require('vscode').action('editor.action.formatDocument')<CR>
    nnoremap <silent> <up> <Cmd>lua require('vscode').action('workbench.action.increaseViewSize')<CR>
    nnoremap <silent> <down> <Cmd>lua require('vscode').action('workbench.action.decreaseViewSize')<CR>

    xnoremap <silent> <left> <Cmd>lua require('vscode').call('git.stageSelectedRanges')<CR><Esc>
    nnoremap <silent> <left> <Cmd>lua require('vscode').action('git.commitStaged')<CR>
    nnoremap <silent> <right> <Cmd>lua require('vscode').action('git.sync')<CR>

    nnoremap <silent> mm <Cmd>lua require('vscode').call('bookmarks.toggle')<CR>
    nnoremap <silent> mj <Cmd>lua require('vscode').call('bookmarks.jumpToNext')<CR>
    nnoremap <silent> mk <Cmd>lua require('vscode').call('bookmarks.jumpToPrevious')<CR>
    nnoremap <silent> mi <Cmd>lua require('vscode').call('bookmarks.toggleLabeled')<CR>
    nnoremap <silent> m; <Cmd>lua require('vscode').call('bookmarks.listFromAllFiles')<CR>
    nnoremap <silent> dmm <Cmd>lua require('vscode').call('bookmarks.clearFromAllFiles')<CR>

    xnoremap gc  <Plug>VSCodeCommentary
    nnoremap gc  <Plug>VSCodeCommentary
    onoremap gc  <Plug>VSCodeCommentary
    nnoremap gcc <Plug>VSCodeCommentaryLine

else
        "neovim specific plugins
        " ui, display
        Plug 'olimorris/onedarkpro.nvim'
        Plug 'itchyny/lightline.vim'
        Plug 'romgrk/barbar.nvim'
        Plug 'mhinz/vim-startify' "butify the vim start up page

        " markdown plugin
        Plug 'godlygeek/tabular' "prerequisite for vim-markdown
        Plug 'plasticboy/vim-markdown'
        Plug 'vimwiki/vimwiki'
        " Plug 'mzlogin/vim-markdown-toc' "table of content, not so useful?
        Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for':'markdown'}
        Plug 'dhruvasagar/vim-table-mode',{'on':'TableModeToggle'}
        Plug 'ferrine/md-img-paste.vim'

        "utility plug-in
        Plug 'tpope/vim-commentary' "comment / uncomment code
        Plug '907th/vim-auto-save' "to auto-save files
        Plug 'MTDL9/vim-log-highlighting' "log highlight
        Plug 'nvim-tree/nvim-web-devicons'
        Plug 'stevearc/oil.nvim'
        Plug 'nvim-lua/plenary.nvim'
        Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.8' }
        Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' }
        Plug 'chentoast/marks.nvim'

        "lsp
        Plug 'neovim/nvim-lspconfig'
        Plug 'hrsh7th/cmp-nvim-lsp'
        Plug 'hrsh7th/cmp-buffer'
        Plug 'hrsh7th/cmp-path'
        Plug 'hrsh7th/cmp-cmdline'
        Plug 'hrsh7th/nvim-cmp'
        Plug 'saadparwaiz1/cmp_luasnip'
        Plug 'L3MON4D3/LuaSnip' ", {'tag': 'v2.*', 'do': 'make install_jsregexp'}
        Plug 'rafamadriz/friendly-snippets'
        Plug 'windwp/nvim-autopairs'
        " Plug 'Vigemus/iron.nvim'

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
        exe 'set undodir='.WorkDir.'neovim\\undo'
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
    set termguicolors
    set shellslash

    "coloring
    let g:lightline = {
          \ 'colorscheme': 'one',
          \ 'active': {
          \   'left': [ [ 'mode', 'paste' ],
          \             ['readonly', 'filename', 'modified' ] ]
          \ },
          \ }
    try
            colorscheme onedark
    catch
            colorscheme industry
    endtry

    " Move to previous/next
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
    " noremap <silent> <s-j> :bp<CR>
    " noremap <silent> <s-k> :bn<CR>
    noremap <A-h> <C-w><C-h>
    noremap <A-j> <C-w><C-j>
    noremap <A-k> <C-w><C-k>
    noremap <A-l> <C-w><C-l>
    " noremap <silent> <C-F4> :bdelete<CR>:bn<CR>
    " noremap <silent> <C-n> :enew<CR>

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

    " load and reload vimrc
    :command! LV source $MYVIMRC
    :command! EV e $MYVIMRC
    " set cd to current dir
    nnoremap <leader>cd :lcd %:h<CR>

    "Plug management
    let g:plug_window = 'vertical topleft new'
    let g:plug_pwindow = 'above 12'

endif

" use 'x' as to cut text into register, cutlass prevents C/D go into register
nnoremap x d
xnoremap x d
nnoremap xx dd
nnoremap X D

" quick-scope specs
let g:qs_lazy_highlight = 0
highlight QuickScopePrimary guifg='#afff5f' gui=underline ctermfg=155 cterm=underline
highlight QuickScopeSecondary guifg='#5fffff' gui=underline ctermfg=81 cterm=underline

exe 'luafile '.WorkDir.'neovim/config/lua_univ_config.lua'

if exists('g:vscode')
    exe 'luafile '.WorkDir.'neovim/config/lua_vscode_config.lua'
else
    exe 'source '.WorkDir.'neovim/config/md.vimrc'
    exe 'source '.WorkDir.'neovim/config/learnvim.vimrc'
    exe 'source '.WorkDir.'neovim/config/mylog.vimrc'
    exe 'source '.WorkDir.'neovim/config/python.vimrc'

    exe 'luafile '.WorkDir.'neovim/config/lsp_config.lua'
    exe 'luafile '.WorkDir.'neovim/config/lua_nvim_config.lua'
    exe 'luafile '.WorkDir.'neovim/config/lua_lsp_config.lua'
endif
