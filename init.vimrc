"NOTE one need to create a file under nvim working dir
"To find the working directory is exactly, use the command :echo stdpath('config') inside Neovim.

" for windows it is usually c:\Users\abc\AppData\Local\nvim\
"for linux, a init.vim file should be created in ~/.config/nvim/init.vim
"IMP example
"let g:WorkDir = '~/.config/nvim/'
"exe 'source '.g:WorkDir.'config/init.vimrc'

"source plug.vim manually from plugged folder. It should normally sit in
" nvim working dir autoload folder
if has("linux")
    let s:path_package = $HOME . '/.local/share/nvim/site/'
else
    let s:path_package = $HOME . '/AppData/local/nvim-data/site/'
endif

let g:lst_plugin = [
            \'dstein64/vim-startuptime',
            \'svermeulen/vim-cutlass',
            \'tpope/vim-repeat',
            \'unblevable/quick-scope',
            \'907th/vim-auto-save',
            \'vimwiki/vimwiki',
            \'dhruvasagar/vim-table-mode',
            \'ferrine/md-img-paste.vim',
            \'MTDL9/vim-log-highlighting']


if !has('nvim')
    "universal plugins
    exe 'source '. s:path_package.'pack/deps/vim/plug.vim'
    call plug#begin(s:path_package.'pack/deps/opt/')
    for plugin in g:lst_plugin
        Plug plugin
    endfor
    call plug#end()
    "vim specifit
    call plug#begin(s:path_package.'pack/deps/vim/')
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
    Plug 'airblade/vim-rooter'
    call plug#end()
endif



exe 'source '.g:WorkDir.'config/univ_config.vimrc'

if exists('g:vscode')
    exe 'source '.g:WorkDir.'config/vscode_config.vimrc'
else
    exe 'source '.g:WorkDir.'config/nvim_vim_config.vimrc'
    exe 'source '.g:WorkDir.'config/md.vimrc'
    exe 'source '.g:WorkDir.'config/python.vimrc'
    if has("nvim")
        " loading neovim plugins handled by nvim
        exe 'luafile '.g:WorkDir.'config/mini_deps.lua'
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
highlight SatelliteMark guibg=#223249 guifg=#D27E99

highlight TermCursor guifg=#D27E99
highlight SnacksStatusColumnMark guibg=#16161d guifg=#D27E99
