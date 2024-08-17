 "adding more character objectives
for s:char in [',','/', '*', '%', '_', '`', '!','.']
    execute 'xnoremap i' . s:char . ' :<C-u>normal! T' . s:char . 'vt' . s:char . '<CR>'
    execute 'onoremap i' . s:char . ' :normal vi' . s:char . '<CR>'
    execute 'xnoremap a' . s:char . ' :<C-u>normal! F' . s:char . 'vf' . s:char . '<CR>'
    execute 'onoremap a' . s:char . ' :normal va' . s:char . '<CR>'
endfor


" using vim-signify
nnoremap gK :SignifyDiff<cr>
nnoremap gJ :SignifyHunkDiff<cr>
nnoremap <leader>hr :SignifyHunkUndo<cr>
vnoremap <leader>hr :SignifyHunkUndo<cr>
