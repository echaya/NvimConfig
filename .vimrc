"NOTICE: one need to create a file under nvim working directory and source this file. e.g.,
"source d:\vnim\init.vim
"To find the working directory is exactly, use the command :echo stdpath('config') inside Neovim.
"
"set work directory for nvim
if isdirectory("c:/Users/echay/")
    let g:WorkDir = 'D:/Dropbox/'
else
    let g:WorkDir = 'C:/tools/'
endif

"source plug.vim manually from plugged folder. It should normally sit in the
" nvim working dir autoload folder
exe 'source '.g:WorkDir.'Neovim/nvim-win64/share/nvim/vimfiles/plugged/plug.vim'

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
    Plug 'dstein64/vim-startuptime'

if !exists('g:vscode')

    "vim and neovim specific plugins
    Plug 'sainnhe/everforest'
    Plug 'sainnhe/sonokai'
    Plug 'itchyny/lightline.vim'
    Plug 'itchyny/vim-gitbranch'
    Plug 'mhinz/vim-startify' "butify the vim start up page
    Plug 'tpope/vim-commentary' "comment / uncomment code
    Plug '907th/vim-auto-save' "to auto-save files
    " markdown & log plugins
    Plug 'godlygeek/tabular' "prerequisite for vim-markdown
    Plug 'plasticboy/vim-markdown'
    Plug 'vimwiki/vimwiki'
    Plug 'dhruvasagar/vim-table-mode',{'on':'TableModeToggle'}
    Plug 'ferrine/md-img-paste.vim'
    Plug 'MTDL9/vim-log-highlighting' "log highlight

    if has('nvim')
        " ui, display
        Plug 'olimorris/onedarkpro.nvim'
        Plug 'romgrk/barbar.nvim'
        " markdown plugin
        " Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for':['markdown','vim-plug','md']}
        "utility plugins
        Plug 'nvim-lua/plenary.nvim'
        Plug 'nvim-tree/nvim-web-devicons'
        Plug 'stevearc/oil.nvim'
        Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.8' }
        Plug 'chentoast/marks.nvim'
        Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' }
        Plug 'ahmedkhalf/project.nvim'
        Plug 'nvim-tree/nvim-tree.lua'

        "lsp and snippets
        Plug 'neovim/nvim-lspconfig'
        Plug 'hrsh7th/cmp-nvim-lsp'
        Plug 'hrsh7th/cmp-buffer'
        Plug 'hrsh7th/cmp-path'
        Plug 'hrsh7th/cmp-cmdline'
        Plug 'hrsh7th/nvim-cmp'
        Plug 'saadparwaiz1/cmp_luasnip'
        Plug 'L3MON4D3/LuaSnip' ", {'tag': 'v2.*', 'do': 'make install_jsregexp'}
        Plug 'rafamadriz/friendly-snippets'

        "programming tools
        Plug 'Vigemus/iron.nvim'
        Plug 'stevearc/conform.nvim'
        Plug 'kdheepak/lazygit.nvim'
        Plug 'lewis6991/gitsigns.nvim'
        Plug 'windwp/nvim-autopairs'
        Plug 'echasnovski/mini.hipatterns', { 'branch': 'stable' }
        Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

    else
        " ui, display
        Plug 'joshdick/onedark.vim'
        Plug 'ap/vim-buftabline' "butify the tab line
        " Plug 'airblade/vim-gitgutter'
        Plug 'mhinz/vim-signify'
    endif

endif

call plug#end()
    
exe 'source '.g:WorkDir.'neovim/config/univ_config.vimrc'
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
    if has("nvim")
        exe 'luafile '.g:WorkDir.'neovim/config/lsp_config.lua'
        exe 'luafile '.g:WorkDir.'neovim/config/lua_nvim_config.lua'
        exe 'luafile '.g:WorkDir.'neovim/config/repl_config.lua'
    endif
endif

" colorscheme and highlight
try
    colorscheme onedark
catch
    colorscheme industry
endtry

set termguicolors
hi MatchParen guibg=#c678dd guifg=#282c34
highlight QuickScopePrimary guifg='#afff5f' gui=underline ctermfg=155 cterm=underline
highlight QuickScopeSecondary guifg='#5fffff' gui=underline ctermfg=81 cterm=underline

" colorschme TODO, FIXME, HACK, NOTE 
highlight MiniHipatternsTodo guibg=#d19a66 guifg=#282c34
highlight MiniHipatternsFixme guibg=#e06c75 guifg=#282c34
highlight MiniHipatternsHack guibg=#c678dd guifg=#282c34
highlight MiniHipatternsNote guibg=#98c379 guifg=#282c34

highlight clear SpellBad 
highlight clear SpellRare
highlight clear SpellLocal
highlight SpellBad gui=undercurl cterm=undercurl guifg=pink ctermfg=210
highlight SpellRare gui=underline guifg='#63D6FD' ctermfg=81 cterm=underline
highlight SpellLocal gui=undercurl cterm=undercurl guifg='#FFFEE2' ctermfg=226
