"NOTE one need to create a file under nvim working dir
"To find the working directory is exactly, use the command :echo stdpath('config') inside Neovim.

" for windows it is usually c:\Users\abc\AppData\Local\nvim\
"for linux, a init.vim file should be created in ~/.config/nvim/init.vim
"IMP example
"let g:WorkDir = '~/.config/nvim/'
"exe 'source '.g:WorkDir.'config/init.vimrc'

"source plug.vim manually from plugged folder. It should normally sit in
" nvim working dir autoload folder

" Universal plugins
let g:lst_plugin = [
            \'dstein64/vim-startuptime',
            \'svermeulen/vim-cutlass',
            \'MTDL9/vim-log-highlighting',
            \'tpope/vim-repeat',
            \'unblevable/quick-scope',
            \'vimwiki/vimwiki',
            \'dhruvasagar/vim-table-mode']

if !has('nvim')
    try
        let s:path_package = $HOME . '/.local/share/nvim/site/'
        exe 'source '. s:path_package.'pack/deps/vim/plug.vim'
    catch
        let s:path_package = $HOME . '/AppData/local/nvim-data/site/'
        exe 'source '. s:path_package.'pack/deps/vim/plug.vim'
    endtry
    call plug#begin(s:path_package.'pack/deps/vim/')

    for plugin in g:lst_plugin
        if stridx(plugin, "scope") == -1
            Plug plugin
        endif
    endfor
    Plug 'mhinz/vim-startify' " Beautify the Vim startup page
    Plug 'mhinz/vim-signify'
    Plug 'itchyny/lightline.vim'
    Plug 'itchyny/vim-gitbranch'
    Plug 'tpope/vim-commentary' " Comment/uncomment code
    Plug 'tpope/vim-speeddating'
    Plug 'kana/vim-textobj-user' " Dependent plugin
    Plug 'Julian/vim-textobj-variable-segment' " av, iv
    Plug 'mbbill/undotree'
    Plug 'machakann/vim-sandwich'
    Plug 'tpope/vim-fugitive'
    Plug 'godlygeek/tabular', {'for': ['markdown', 'vimwiki']} " Prerequisite for vim-markdown
    Plug 'plasticboy/vim-markdown', {'for': ['markdown', 'vimwiki']}
    Plug 'airblade/vim-rooter'
    Plug 'bluz71/vim-nightfly-colors', { 'as': 'nightfly' }
    Plug '907th/vim-auto-save',
    call plug#end()
endif

let s:script_dir = expand('<sfile>:p:h')
let s:script_dir = substitute(s:script_dir, '\\', '/', 'g')
if s:script_dir[-1:] !=# '/'
    let s:script_dir = s:script_dir . '/'
endif
exe 'source '.s:script_dir.'vim/univ_config.vimrc'

if has("nvim")
    " loading neovim plugins handled by nvim
    exe 'luafile '.s:script_dir.'init.lua'
else
    exe 'source '.s:script_dir.'vim/vim_config.vimrc'
endif

if exists('g:vscode')
    exe 'source '.s:script_dir.'vim/vscode_config.vimrc'
else
    exe 'source '.s:script_dir.'vim/nvim_vim_config.vimrc'
    exe 'source '.s:script_dir.'vim/md.vimrc'
    exe 'source '.s:script_dir.'vim/python.vimrc'
endif

" colorscheme and highlight
try
    colorscheme kanagawa
catch
    try
        colorscheme nightfly
    catch
        colorscheme  habamax
    endtry
endtry

augroup color_refresh
    autocmd!

    highlight QuickScopePrimary guifg=#afff5f gui=underline ctermfg=155 cterm=underline
    highlight QuickScopeSecondary guifg='#5fffff' gui=underline ctermfg=81 cterm=underline

    " colorschme TODO, XXX, IMP, NOTE
    highlight MiniHipatternsTodo guibg=#FF9E3B guifg=#282c34
    highlight MiniHipatternsFixme guibg=#E82424 guifg=#282c34
    highlight MiniHipatternsHack guibg=#957FB8 guifg=#282c34
    highlight MiniHipatternsNote guibg=#76946A guifg=#282c34

    highlight clear SpellBad
    highlight clear SpellRare
    highlight clear SpellLocal
    highlight SpellBad gui=undercurl guifg=pink
    highlight SpellRare guifg=#63D6FD
    highlight SpellLocal gui=undercurl guifg=#FFFEE2

    highlight TermCursor guifg=#D27E99
    highlight SnacksStatusColumnMark guibg=#16161d guifg=#D27E99
augroup END
