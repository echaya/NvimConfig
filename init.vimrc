"NOTE one need to create a file under nvim working dir
"To find the working directory is exactly, use the command :echo stdpath('config') inside Neovim.

" for windows it is usually c:\Users\abc\AppData\Local\nvim\
"for linux, a init.vim file should be created in ~/.config/nvim/init.vim
"IMP example
"let g:WorkDir = '~/.config/nvim/'
"exe 'source '.g:WorkDir.'config/init.vimrc'

let g:config_dir = expand('<sfile>:p:h')
let g:config_dir = substitute(g:config_dir, '\\', '/', 'g')
if g:config_dir[-1:] !=# '/'
    let g:config_dir = g:config_dir . '/'
endif


" Universal plugins
let g:share_plugin = [
            \'dstein64/vim-startuptime',
            \'svermeulen/vim-cutlass',
            \'MTDL9/vim-log-highlighting',
            \'tpope/vim-repeat',
            \'unblevable/quick-scope',
            \'dhruvasagar/vim-table-mode'
            \]
" Vim specific plugins
let g:vim_plugin = [
            \ 'mhinz/vim-signify',
            \ 'itchyny/lightline.vim',
            \ 'itchyny/vim-gitbranch',
            \ 'tpope/vim-commentary',
            \ 'tpope/vim-speeddating',
            \ 'kana/vim-textobj-user',
            \ 'Julian/vim-textobj-variable-segment',
            \ 'mbbill/undotree',
            \ 'machakann/vim-sandwich',
            \ 'tpope/vim-fugitive',
            \ 'airblade/vim-rooter',
            \ ['bluz71/vim-nightfly-colors',"nightfly"]
            \]

if has("nvim")
    " loading neovim plugins handled by nvim
    exe 'luafile '.g:config_dir.'init.lua'
else
    try
        let s:path_package = $HOME . '/.local/share/nvim/site/'
        "source plug.vim manually from plugged folder.
        "It should normally sit in nvim working dir autoload folder
        exe 'source '. s:path_package.'pack/deps/opt/plug.vim'
    catch
        let s:path_package = $HOME . '/AppData/local/nvim-data/site/'
        exe 'source '. s:path_package.'pack/deps/opt/plug.vim'
    endtry
    call plug#begin(s:path_package.'pack/deps/opt/')

    for plugin in g:share_plugin
        Plug plugin
    endfor
    for plugin in g:vim_plugin
        if type(plugin) == type([])
            Plug plugin[0], {'as': plugin[1]}
        else
            Plug plugin
        endif
    endfor
    call plug#end()
    exe 'source '.g:config_dir.'vim/vim_config.vimrc'
endif

if !exists('g:vscode')
    exe 'source '.g:config_dir.'vim/nvim_vim_config.vimrc'
    exe 'source '.g:config_dir.'vim/md.vimrc'
endif

exe 'source '.g:config_dir.'vim/univ_config.vimrc'

" colorscheme and highlight
try
    colorscheme tokyonight
catch
    try
        colorscheme nightfly
    catch
        colorscheme  habamax
    endtry
endtry

function! s:ApplyCustomHighlights()
    " QuickScope
    highlight QuickScopePrimary guifg=#afff5f gui=underline ctermfg=155 cterm=underline
    highlight QuickScopeSecondary guifg='#5fffff' gui=undercurl ctermfg=81 cterm=undercurl

    " colorschme TODO, XXX, IMP, NOTE
    highlight MiniHipatternsTodo guibg=#FF9E3B guifg=#282c34
    highlight MiniHipatternsFixme guibg=#E82424 guifg=#282c34
    highlight MiniHipatternsHack guibg=#957FB8 guifg=#282c34
    highlight MiniHipatternsNote guibg=#76946A guifg=#282c34

    " Spelling
    highlight clear SpellBad
    highlight clear SpellRare
    highlight clear SpellLocal
    highlight SpellBad gui=undercurl guifg=pink
    highlight SpellRare guifg=#E5C07B
    highlight SpellLocal gui=undercurl guifg=#FFFEE2

    " Snacks
    highlight SnacksStatusColumnMark guibg=NONE guifg=#D27E99
endfunction

" 2. Create the autocmd group to re-apply highlights after a colorscheme changes.
augroup HighlightGroupRefresher
    autocmd!
    autocmd ColorScheme * call s:ApplyCustomHighlights()
augroup END

" 3. Call the function once on startup to apply highlights immediately.
call s:ApplyCustomHighlights()
