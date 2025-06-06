"markdown config

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
    autocmd FileType vimwiki normal zR
    "edit link
    autocmd Filetype markdown nnoremap <buffer> <localleader>md :call EditMdLink()<cr>
    " vimwiki checkbox toggle
    autocmd Filetype markdown nnoremap <buffer> <localleader><localleader> <Cmd>VimwikiToggleListItem<CR>
    autocmd FileType markdown let b:CodeFence = "```"
    autocmd Filetype markdown nnoremap <buffer> <localleader>v <cmd>call SelectVisual()<cr>
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
let g:vimwiki_global_ext = 0
let g:vimwiki_key_mappings =
            \ {
            \ 'table_mappings': 0,
            \ 'lists': 0,
            \ }
let g:vimwiki_folding = 'expr'
let g:vimwiki_table_auto_fmt = 0
" nmap <F7> <Plug>VimwikiNextLink
" nmap <F9> <Plug>VimwikiPrevLink
" nmap <S-Cr> <Plug>VimwikiFollowLink
" nmap <C-Cr> <Plug>VimwikiVSplitLink
" nmap <Backspace> <Plug>VimwikiGoBackLink
