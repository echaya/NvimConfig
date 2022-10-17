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
noremap <F6> <Plug>Markdown_EditUrlUnderCursor

augroup mdgroup
    autocmd!
    autocmd FileType markdown set conceallevel=0
    autocmd FileType markdown normal zR
    "markdown shortcut
    autocmd Filetype markdown inoremap ;f <Esc>/<++><CR>:nohlsearch<CR>c4l
    "autocmd Filetype markdown inoremap ;n ---<Enter><Enter>
    autocmd Filetype markdown inoremap ;b **** <++><Esc>F*hi
    "autocmd Filetype markdown inoremap ;a ****** <++><Esc>F*hhi
    autocmd Filetype markdown inoremap ;s ~~~~ <++><Esc>F~hi
    autocmd Filetype markdown inoremap ;i ** <++><Esc>F*i
    autocmd Filetype markdown inoremap ;h `` <++><Esc>F`i
    autocmd Filetype markdown inoremap ;c ```<Enter><++><Enter>```<Enter><Enter><++><Esc>4kA
    autocmd Filetype markdown inoremap ;C ```python<Enter><Enter>```<Enter><Enter><++><Esc>3kA
    "autocmd Filetype markdown inoremap ;h ====<Space><++><Esc>F=hi
    autocmd Filetype markdown inoremap ;p ![](./pic/<++>) <++><Esc>F[a
    autocmd Filetype markdown inoremap ;w [](<++>) <++><Esc>F[a

    autocmd Filetype markdown inoremap ;l <Enter>--------<Enter>
    autocmd Filetype markdown inoremap ;1 #<Space><Enter><++><Esc>kA
    autocmd Filetype markdown inoremap ;2 ##<Space><Enter><++><Esc>kA
    autocmd Filetype markdown inoremap ;3 ###<Space><Enter><++><Esc>kA
    autocmd Filetype markdown inoremap ;4 ####<Space><Enter><++><Esc>kA
    autocmd Filetype markdown inoremap ;5 #####<Space><Enter><++><Esc>kA
    autocmd Filetype markdown inoremap ;6 ######<Space><Enter><++><Esc>kA

    " markdown paste from clipboard
    autocmd FileType markdown nmap <buffer><silent> <leader><leader>p :call mdip#MarkdownClipboardImage()<CR>
    let g:mdip_imgdir = 'img'
    let g:mdip_imgname = 'image'

    autocmd Filetype markdown nnoremap <silent><leader>md :call EditMdLink()<cr>

augroup END

" spell check
augroup markdownSpell
        autocmd!
        autocmd FileType markdown setlocal spell spelllang=en_us,cjk
        autocmd BufRead,BufNewFile *.md setlocal spell spelllang=en_us,cjk
        autocmd FileType markdown inoremap ;g <c-g>u<Esc>[s1z=`]a<c-g>u
augroup END

" vim wiki settings
let g:vimwiki_list = [{'path': 'd:\Dropbox\markdown\', 'syntax': 'markdown','ext': '.md'}]
let g:vimwiki_ext2syntax = {'.md': 'markdown', '.markdown': 'markdown'}
let g:vimwiki_key_mappings =
\ {
\ 'table_mappings': 0,
\ }
" nmap <F7> <Plug>VimwikiNextLink
" nmap <F9> <Plug>VimwikiPrevLink
" nmap <S-Cr> <Plug>VimwikiFollowLink
" nmap <C-Cr> <Plug>VimwikiVSplitLink
" nmap <Backspace> <Plug>VimwikiGoBackLink
