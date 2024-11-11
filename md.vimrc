"markdown config
let g:vim_markdown_folding_disabled = 1
"let g:vmt_auto_update_on_save = 0 " TODO is it still in use

function! EditMdLink() abort
    " use Ctrl-r Ctrl-r `X` to call out macro recorded on `X`
    " alternatively use "Xp in normal mode where X being register
    let cmd = 'normal :s/\V\\/:/g$F:;ld0xf: ojp$r/kI. jk:s/\V./|/g/|mdD:s/ /_/g:s/|/_/gd2lYys$]j$p0ys$)k jdl'
    execute cmd
endfunction

augroup mdgroup
    autocmd!
    autocmd FileType markdown set conceallevel=0
    autocmd FileType markdown normal zR

    " markdown paste from clipboard
    autocmd FileType markdown nmap <buffer><silent> <leader><localleader>p :call mdip#MarkdownClipboardImage()<CR>
    let g:mdip_imgdir = 'img'
    let g:mdip_imgname = 'image'

    "edit link
    autocmd Filetype markdown nnoremap <buffer> <leader>md :call EditMdLink()<cr>
    " vimwiki checkbox toggle
    autocmd Filetype markdown nnoremap <buffer> <localleader><localleader> <Cmd>VimwikiToggleListItem<CR>
augroup END

" spell check
augroup markdownSpell
    autocmd!
    autocmd FileType markdown setlocal spell spelllang=en_us,cjk
    autocmd BufRead,BufNewFile *.md setlocal spell spelllang=en_us,cjk
    autocmd FileType markdown inoremap ;f <c-g>u<Esc>[s1z=`]a<c-g>u
augroup END

" vim wiki settings
" g:MDir should be set in the init.vim
let g:vimwiki_list = [{'path': g:MDir, 'syntax': 'markdown','ext': '.md'}]
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
