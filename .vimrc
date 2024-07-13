"NOTICE: one need to create a file under vnim working directory and source this file. e.g.,
"source d:\vnim\init.vim
"To find the working directory is exactly, use the command :echo stdpath('config') inside Neovim.
"
"set work directory for nvim
let g:WorkDir = 'D:/Dropbox/'
"universal settings
"change <leader> to SPACE
nnoremap <SPACE> <Nop>
let mapleader=" "

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
" join lines by leader j
nnoremap <leader>j J
nnoremap <leader>l :redraw<CR>

" insert lines without entering insert mode (allow count)
noremap <silent> <leader>o :<C-u>call append(line("."),   repeat([""], v:count1))<CR>
nnoremap <silent> <leader>O :<C-u>call append(line(".")-1, repeat([""], v:count1))<CR>

" use Ctrl+j/k to swap lines (allow count)
nnoremap <C-j> :<c-u>execute 'move +'. v:count1<cr>
nnoremap <C-k> :<c-u>execute 'move -1-'. v:count1<cr>
xnoremap <silent> <C-j> :m '>+1<cr>gv=gv
xnoremap <silent> <C-k> :m '<-2<cr>gv=gv

" saner command-line histsory
cnoremap <expr> <c-n> wildmenumode() ? "\<c-n>" : "\<down>"
cnoremap <expr> <c-p> wildmenumode() ? "\<c-p>" : "\<up>"

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


call plug#begin(g:WorkDir..'Neovim/nvim-win64/share/nvim/vimfiles/plugged')
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
    Plug 'ggandor/leap.nvim'
    Plug 'kylechui/nvim-surround'

if !exists('g:vscode')

    "vim and neovim specific plugins
    Plug 'itchyny/lightline.vim'
    Plug 'mhinz/vim-startify' "butify the vim start up page
    Plug 'tpope/vim-commentary' "comment / uncomment code
    Plug '907th/vim-auto-save' "to auto-save files
    Plug 'MTDL9/vim-log-highlighting' "log highlight
    " markdown plugin
    Plug 'godlygeek/tabular' "prerequisite for vim-markdown
    Plug 'plasticboy/vim-markdown'
    Plug 'vimwiki/vimwiki'
    Plug 'dhruvasagar/vim-table-mode',{'on':'TableModeToggle'}
    Plug 'ferrine/md-img-paste.vim'
    " Plug 'airblade/vim-gitgutter'
    " Plug 'mhinz/vim-signify'

    if has('nvim')
        " ui, display
        Plug 'olimorris/onedarkpro.nvim'
        Plug 'romgrk/barbar.nvim'
        " markdown plugin
        Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for':['markdown','vim-plug','md']}
        "utility plug-in
        Plug 'nvim-tree/nvim-web-devicons'
        Plug 'stevearc/oil.nvim'
        Plug 'nvim-lua/plenary.nvim'
        Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.8' }
        Plug 'chentoast/marks.nvim'
        Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' }
        Plug 'ahmedkhalf/project.nvim'
        Plug 'nvim-tree/nvim-tree.lua'

        "lsp and programming
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
        Plug 'Vigemus/iron.nvim'
        Plug 'stevearc/conform.nvim'
        Plug 'kdheepak/lazygit.nvim'
        Plug 'lewis6991/gitsigns.nvim'

    else
        " ui, display
        Plug 'joshdick/onedark.vim'
        Plug 'ap/vim-buftabline' "butify the tab line
    endif

endif

call plug#end()
    
" use 'x' as to cut text into register, cutlass prevents C/D go into register
nnoremap x d
xnoremap x d
nnoremap xx dd
nnoremap X D

" quick-scope specs
let g:qs_lazy_highlight = 0
highlight QuickScopePrimary guifg='#afff5f' gui=underline ctermfg=155 cterm=underline
highlight QuickScopeSecondary guifg='#5fffff' gui=underline ctermfg=81 cterm=underline

if exists('g:vscode') || has("nvim")
    exe 'luafile '.g:WorkDir.'neovim/config/lua_univ_config.lua'
endif

if exists('g:vscode')
    exe 'source '.g:WorkDir.'neovim/config/vscode_config.vimrc'
    exe 'luafile '.g:WorkDir.'neovim/config/lua_vscode_config.lua'
else
    exe 'source '.g:WorkDir.'neovim/config/vim_config.vimrc'
    exe 'source '.g:WorkDir.'neovim/config/md.vimrc'
    exe 'source '.g:WorkDir.'neovim/config/python.vimrc'
    " exe 'source '.g:WorkDir.'neovim/config/mylog.vimrc'
    if has("nvim")
        exe 'luafile '.g:WorkDir.'neovim/config/lsp_config.lua'
        exe 'luafile '.g:WorkDir.'neovim/config/lua_nvim_config.lua'
        exe 'luafile '.g:WorkDir.'neovim/config/repl_config.lua'
    endif
endif
