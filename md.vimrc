"markdown config
let g:vim_markdown_folding_disabled = 1
let g:vmt_auto_update_on_save = 0
let g:mkdp_path_to_chrome = "c:\Program Files\Google\Chrome\Application\chrome.exe"
let g:mkdp_auto_start = 0
let g:mkdp_auto_close = 1
let g:mkdp_refresh_slow = 0
let g:mkdp_command_for_global = 0
let g:mkdp_open_to_the_world = 0
let g:mkdp_open_ip = ''
let g:mkdp_echo_preview_url = 0
let g:mkdp_browserfunc = ''
let g:mkdp_preview_options = {
    \ 'mkit': {},
    \ 'katex': {},
    \ 'uml': {},
    \ 'maid': {},
    \ 'disable_sync_scroll': 0,
    \ 'sync_scroll_type': 'middle',
    \ 'hide_yaml_meta': 1
    \ }

nmap <F5> <Plug>MarkdownPreviewToggle

let g_mkdp_refresh_slow=0

"table-mode
noremap <leader>\ :TableModeToggle<CR>
noremap <leader>= :TableModeRealign<CR>

augroup mdgroup
    autocmd!
    autocmd FileType markdown set conceallevel=0
    autocmd FileType markdown normal zR


    " markdown paste from clipboard
    autocmd FileType markdown nmap <buffer><silent> <leader><leader>p :call mdip#MarkdownClipboardImage()<CR>
    let g:mdip_imgdir = 'img'
    let g:mdip_imgname = 'image'

    "edit link
    autocmd Filetype markdown nnoremap <silent><leader>md :call EditMdLink()<cr>
    "table-mode
    autocmd Filetype markdown nnoremap <leader>\ :TableModeToggle<CR>
    autocmd Filetype markdown nnoremap <leader>= :TableModeRealign<CR>

augroup END

" spell check
augroup markdownSpell
        autocmd!
        autocmd FileType markdown setlocal spell spelllang=en_us,cjk
        autocmd BufRead,BufNewFile *.md setlocal spell spelllang=en_us,cjk
        autocmd FileType markdown inoremap ;f <c-g>u<Esc>[s1z=`]a<c-g>u
augroup END

highlight clear SpellCap 
highlight clear SpellBad 
highlight clear SpellRare
highlight clear SpellLocal
highlight SpellBad gui=undercurl cterm=undercurl guifg=pink ctermfg=210
highlight SpellRare gui=underline guifg='#63D6FD' ctermfg=81 cterm=underline
highlight SpellLocal gui=undercurl cterm=undercurl guifg='#FFFEE2' ctermfg=226

" vim wiki settings
let g:vimwiki_list = [{'path': g:WorkDir.'markdown\', 'syntax': 'markdown','ext': '.md'}]
let g:vimwiki_ext2syntax = {'.md': 'markdown', '.markdown': 'markdown'}
let g:vimwiki_key_mappings =
\ {
\ 'table_mappings': 0,
\ 'lists': 0, 
\ }
" nmap <F7> <Plug>VimwikiNextLink
" nmap <F9> <Plug>VimwikiPrevLink
" nmap <S-Cr> <Plug>VimwikiFollowLink
" nmap <C-Cr> <Plug>VimwikiVSplitLink
" nmap <Backspace> <Plug>VimwikiGoBackLink
