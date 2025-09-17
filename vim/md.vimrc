"markdown config

function! EditMdLink() abort
    " use Ctrl-r Ctrl-r `X` to call out macro recorded on `X`
    " alternatively use "Xp in normal mode where X being register
    let cmd = 'normal :s/\V\\/:/g$F:;ld0xf: ojp$r/kI. jk:s/\V./|/g/|mdD:s/ /_/g:s/|/_/gd2lYys$]j$p0ys$)k jdl'
    execute cmd
endfunction

augroup mdgroup
    autocmd!
    autocmd FileType markdown set conceallevel=2
    autocmd FileType markdown normal zR
    "edit link
    autocmd Filetype markdown nnoremap <buffer> <localleader>md :call EditMdLink()<cr>
    autocmd Filetype markdown nnoremap <silent> <buffer> gO :<C-u>call append(line(".")-1, repeat([""], v:count1))<CR>
augroup END

" spell check
augroup markdownSpell
    autocmd!
    autocmd FileType markdown setlocal spell spelllang=en_us,cjk
    autocmd BufRead,BufNewFile *.md setlocal spell spelllang=en_us,cjk
    autocmd FileType markdown inoremap ;f <c-g>u<Esc>[s1z=`]a<c-g>u
augroup END

