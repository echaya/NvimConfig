"NOTE one need to create a file under nvim working directory and source this file.
"To find the working directory is exactly, use the command :echo stdpath('config') inside Neovim.

" for windows it is usually c:\Users\abc\AppData\Local\nvim\
"for linux, a init.vim file should be created in ~/.config/nvim/init.vim
"IMP example
"let g:WorkDir = '~/.config/nvim/'
"exe 'source '.g:WorkDir.'config/init.vimrc'

"source plug.vim manually from plugged folder. It should normally sit in
" nvim working dir autoload folder
exe 'source '.g:WorkDir.'plugged/plug.vim'

call plug#begin(g:WorkDir.'plugged')
" universal plugins
Plug 'dstein64/vim-startuptime'
Plug 'unblevable/quick-scope'
Plug 'tpope/vim-repeat'
Plug 'svermeulen/vim-cutlass'
Plug 'machakann/vim-sandwich'


"neovim universal plugins
if has ('nvim')
    Plug 'nvim-lua/plenary.nvim'
    Plug 'ggandor/leap.nvim'
    Plug 'max397574/better-escape.nvim'
    Plug 'monaqa/dial.nvim'
    Plug 'echasnovski/mini.ai'
endif

if !exists('g:vscode')

    "vim and neovim specific plugins
    Plug '907th/vim-auto-save'
    Plug 'airblade/vim-rooter'

    " markdown & log plugins
    Plug 'godlygeek/tabular', {'for':['markdown','vimwiki']} "prerequisite for vim-markdown
    Plug 'plasticboy/vim-markdown', {'for':['markdown','vimwiki']}
    Plug 'vimwiki/vimwiki'
    Plug 'dhruvasagar/vim-table-mode',{'on':'TableModeToggle'}
    Plug 'ferrine/md-img-paste.vim', {'for':['markdown','vimwiki']}
    Plug 'MTDL9/vim-log-highlighting', {'for':['log']}

    if has('nvim')
        " ui, display
        Plug 'olimorris/onedarkpro.nvim'
        Plug 'rebelot/kanagawa.nvim'
        Plug 'nvim-lualine/lualine.nvim'
        Plug 'lewis6991/satellite.nvim'
        Plug 'MunifTanjim/nui.nvim'
        Plug 'rcarriga/nvim-notify'
        Plug 'folke/noice.nvim'

        "utility plugins
        Plug 'nvim-tree/nvim-web-devicons'
        Plug 'echasnovski/mini.files'
        Plug 'nvim-telescope/telescope.nvim'
        Plug 'debugloop/telescope-undo.nvim'
        Plug 'chentoast/marks.nvim'
        Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' }
        Plug 'Shatur/neovim-session-manager'
        Plug 'folke/which-key.nvim'
        Plug 'stevearc/dressing.nvim'
        Plug 'echasnovski/mini.bufremove'
        Plug 'echasnovski/mini.indentscope'
        Plug 'echasnovski/mini.trailspace'

        "lsp and snippets
        Plug 'neovim/nvim-lspconfig'
        Plug 'hrsh7th/cmp-nvim-lsp'
        Plug 'hrsh7th/cmp-buffer'
        Plug 'hrsh7th/cmp-path'
        Plug 'hrsh7th/cmp-cmdline'
        "Plug 'hrsh7th/nvim-cmp'
        Plug 'yioneko/nvim-cmp', { 'branch': 'perf' }
        Plug 'saadparwaiz1/cmp_luasnip'
        Plug 'L3MON4D3/LuaSnip' ", {'tag': 'v2.*', 'do': 'make install_jsregexp'}
        "Plug 'rafamadriz/friendly-snippets'
        Plug 'echaya/friendly-snippets'
        Plug 'SmiteshP/nvim-navic'

        "programming tools
        Plug 'Vigemus/iron.nvim'
        Plug 'stevearc/conform.nvim'
        Plug 'lewis6991/gitsigns.nvim'
        Plug 'windwp/nvim-autopairs'
        Plug 'echasnovski/mini.hipatterns'
        Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
        Plug 'RRethy/vim-illuminate'
        Plug 'sindrets/diffview.nvim'
        Plug 'akinsho/toggleterm.nvim'
        Plug 'MeanderingProgrammer/render-markdown.nvim'

    else
        " vim specific alternative
        Plug 'mhinz/vim-startify' "butify the vim start up page
        Plug 'joshdick/onedark.vim'
        Plug 'ap/vim-buftabline' "butify the tab line
        Plug 'mhinz/vim-signify'
        Plug 'itchyny/lightline.vim'
        Plug 'itchyny/vim-gitbranch'
        Plug 'tpope/vim-commentary' "comment / uncomment code
        Plug 'tpope/vim-speeddating'
        Plug 'kana/vim-textobj-user' "dependent plugin
        Plug 'Julian/vim-textobj-variable-segment' "av,iv
        Plug 'kana/vim-textobj-indent' "ai,ii, aI, iI
        Plug 'bps/vim-textobj-python' "ac,ic,af,if
        Plug 'mbbill/undotree'
    endif

endif

call plug#end()

exe 'source '.g:WorkDir.'config/univ_config.vimrc'
if has("nvim")
    exe 'luafile '.g:WorkDir.'config/univ_config.lua'
endif

if exists('g:vscode')
    exe 'source '.g:WorkDir.'config/vscode_config.vimrc'
    exe 'luafile '.g:WorkDir.'config/vscode_config.lua'
else
    exe 'source '.g:WorkDir.'config/nvim_vim_config.vimrc'
    exe 'source '.g:WorkDir.'config/md.vimrc'
    exe 'source '.g:WorkDir.'config/python.vimrc'
    if has("nvim")
        exe 'luafile '.g:WorkDir.'config/nvim_gui_config.lua'
        exe 'luafile '.g:WorkDir.'config/nvim_utils_config.lua'
        exe 'luafile '.g:WorkDir.'config/lsp_config.lua'
        exe 'luafile '.g:WorkDir.'config/repl_config.lua'
    else
        exe 'source '.g:WorkDir.'config/vim_config.vimrc'
    endif
endif

" colorscheme and highlight
try
    colorscheme kanagawa
catch
    colorscheme onedark
endtry

if has('termguicolors')
    set termguicolors
endif

highlight IlluminatedWordText guibg=#505664 gui=NONE
highlight IlluminatedWordRead guibg=#505664 gui=NONE
highlight IlluminatedWordWrite guibg=#505664 gui=NONE

highlight QuickScopePrimary guifg=#afff5f gui=underline ctermfg=155 cterm=underline
highlight QuickScopeSecondary guifg='#5fffff' gui=underline ctermfg=81 cterm=underline

" colorschme TODO, XXX, IMP, NOTE
highlight MiniHipatternsTodo guibg=#FF9E3B guifg=#282c34
highlight MiniHipatternsFixme guibg=#E82424 guifg=#282c34
highlight MiniHipatternsHack guibg=#957FB8 guifg=#282c34
highlight MiniHipatternsNote guibg=#76946A guifg=#282c34

highlight OperatorSandwichBuns guifg=#d19a66 gui=underline
highlight OperatorSandwichChange guifg=#edc41f gui=underline
highlight OperatorSandwichAdd guibg=#b1fa87 gui=none
highlight OperatorSandwichDelete guibg=#cf5963 gui=none

highlight clear SpellBad
highlight clear SpellRare
highlight clear SpellLocal
highlight SpellBad gui=undercurl guifg=pink
highlight SpellRare guifg=#63D6FD
highlight SpellLocal gui=undercurl guifg=#FFFEE2

highlight link SatelliteCursor CursorLineNr
highlight link SatelliteMark Identifier

highlight TermCursor guifg=#D27E99
