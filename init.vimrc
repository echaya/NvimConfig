"NOTE one need to create a file under nvim working directory and source this file.
"To find the working directory is exactly, use the command :echo stdpath('config') inside Neovim.

" for windows it is usually c:\Users\abc\AppData\Local\nvim\
"for linux, a init.vim file should be created in ~/.config/nvim/init.vim
"IMP example
"let g:WorkDir = '~/.config/nvim/'
"exe 'source '.g:WorkDir.'config/init.vimrc'

"source plug.vim manually from plugged folder. It should normally sit in
" nvim working dir autoload folder

if has('nvim')
    lua if vim.loader then vim.loader.enable() end
endif

exe 'source '.g:WorkDir.'plugged/plug.vim'

call plug#begin(g:WorkDir.'plugged')
" universal plugins
Plug 'dstein64/vim-startuptime'
Plug 'unblevable/quick-scope'
Plug 'tpope/vim-repeat'
Plug 'svermeulen/vim-cutlass'


"neovim universal plugins
if has ('nvim')
    Plug 'nvim-lua/plenary.nvim'
    Plug 'ggandor/leap.nvim'
    Plug 'max397574/better-escape.nvim'
    Plug 'monaqa/dial.nvim'
    Plug 'echasnovski/mini.nvim'
endif

if !exists('g:vscode')

    "vim and neovim specific plugins
    Plug '907th/vim-auto-save'
    Plug 'airblade/vim-rooter'

    " markdown & log plugins
    Plug 'vimwiki/vimwiki'
    Plug 'dhruvasagar/vim-table-mode',{'on':'TableModeToggle'}
    Plug 'ferrine/md-img-paste.vim', {'for':['markdown','vimwiki']}
    Plug 'MTDL9/vim-log-highlighting', {'for':['log']}

    if has('nvim')
        " ui, display
        Plug 'rebelot/kanagawa.nvim'
        Plug 'folke/snacks.nvim'
        Plug 'nvim-lualine/lualine.nvim'
        Plug 'lewis6991/satellite.nvim'
        Plug 'MunifTanjim/nui.nvim'
        Plug 'rcarriga/nvim-notify'
        Plug 'folke/noice.nvim'

        "utility plugins
        Plug 'nvim-telescope/telescope.nvim'
        Plug 'debugloop/telescope-undo.nvim'
        Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' }
        "Plug 'kkharji/sqlite.lua'
        "Plug 'danielfalk/smart-open.nvim'
        Plug 'chentoast/marks.nvim'
        Plug 'Shatur/neovim-session-manager'
        Plug 'folke/which-key.nvim'
        Plug 'stevearc/dressing.nvim'

        "lsp and autocomplete
        Plug 'neovim/nvim-lspconfig'
        Plug 'iguanacucumber/mag-nvim-lsp', {'as':'cmp-nvim-lsp'}
        Plug 'iguanacucumber/mag-nvim-lua',  {'as':'cmp-nvim-lua'}
        Plug 'iguanacucumber/mag-buffer',  {'as': 'cmp-buffer'}
        Plug 'iguanacucumber/mag-cmdline',  { 'as':'cmp-cmdline' }
        Plug 'https://codeberg.org/FelipeLema/cmp-async-path', {'as':'async_path'}
        Plug 'saadparwaiz1/cmp_luasnip'
        Plug 'L3MON4D3/LuaSnip' ", {'tag': 'v2.*', 'do': 'make install_jsregexp'}
        "Plug 'rafamadriz/friendly-snippets'
        Plug 'echaya/friendly-snippets'
        Plug 'iguanacucumber/magazine.nvim', { 'as': 'nvim-cmp' }
        Plug 'SmiteshP/nvim-navic'
        Plug 'dnlhc/glance.nvim'

        "treesitter other programming tools
        Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
        Plug 'Vigemus/iron.nvim'
        Plug 'stevearc/conform.nvim'
        Plug 'lewis6991/gitsigns.nvim'
        Plug 'sindrets/diffview.nvim'
        Plug 'MeanderingProgrammer/render-markdown.nvim'

    else
        " vim specific alternative
        Plug 'mhinz/vim-startify' "butify the vim start up page
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
        Plug 'machakann/vim-sandwich'
        Plug 'tpope/vim-fugitive'
        Plug 'godlygeek/tabular', {'for':['markdown','vimwiki']} "prerequisite for vim-markdown
        Plug 'plasticboy/vim-markdown', {'for':['markdown','vimwiki']}
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
    colorscheme  habamax
endtry

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

