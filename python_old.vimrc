" ctag configfs
" ctag gD to open definition in vertical tab
map gD :vsp <CR>:exec("tag ".expand("<cword>"))<CR>
set tags=tags
" set tags+=d:\Dropbox\software\Neovim\backup\nvim\tags\tags
" gutentags搜索工程目录的标志，碰到这些文件/目录名就停止向上一级目录递归 "
let g:gutentags_project_root = ['.root', '.svn', '.git', '.proj','__init__']
let g:gutentags_ctags_exclude = [
  \ '*.git', '*.svg', '*.hg',
  \ '*/tests/*',
  \ '*/.ipynb_checkpoints/*',
  \ '.ipynb_checkpoints/*',
  \ 'build',
  \ 'dist',
  \ '*sites/*/files/*',
  \ 'bin',
  \ 'node_modules',
  \ 'bower_components',
  \ 'cache',
  \ 'compiled',
  \ 'docs',
  \ 'example',
  \ 'bundle',
  \ 'vendor',
  \ '*.md',
  \ '*-lock.json',
  \ '*.lock',
  \ '*bundle*.js',
  \ '*build*.js',
  \ '.*rc*',
  \ '*.json',
  \ '*.min.*',
  \ '*.map',
  \ '*.bak',
  \ '*.zip',
  \ '*.pyc',
  \ '*.class',
  \ '*.sln',
  \ '*.Master',
  \ '*.csproj',
  \ '*.tmp',
  \ '*.csproj.user',
  \ '*.cache',
  \ '*.pdb',
  \ 'tags*',
  \ 'cscope.*',
  \ '*.css',
  \ '*.less',
  \ '*.scss',
  \ '*.exe', '*.dll',
  \ '*.mp3', '*.ogg', '*.flac',
  \ '*.swp', '*.swo',
  \ '*.bmp', '*.gif', '*.ico', '*.jpg', '*.png',
  \ '*.rar', '*.zip', '*.tar', '*.tar.gz', '*.tar.xz', '*.tar.bz2',
  \ '*.pdf', '*.doc', '*.docx', '*.ppt', '*.pptx',
  \ ]

"python config
let pythonthreedll='c:\Program Files\Python39\python39.dll'
let pythonthreehome='c:\Users\echay\AppData\Local\Programs\Python\Python39'
" let g:python3_host_prog='c:\blp\bqnt\environments\bqnt-2\python'
let g:python3_host_prog='c:\Users\echay\AppData\Local\Programs\Python\Python39\python'
let g:repl_python_pre_launch_command = 'c:\\blp\\bqnt\\bootstrapper\\condabin\\activate.bat c:\\blp\\bqnt\\environments\\bqnt-2'
let g:repl_position = 3
let g:repl_cursor_down = 1
let g:repl_python_automerge = 1
let g:repl_ipython_version = '7'
nnoremap <leader>r :REPLToggle<Cr>
autocmd Filetype python nnoremap <F12> <Esc>:REPLDebugStopAtCurrentLine<Cr>
autocmd Filetype python nnoremap <F10> <Esc>:REPLPDBN<Cr>
autocmd Filetype python nnoremap <F11> <Esc>:REPLPDBS<Cr>
let g:sendtorepl_invoke_key = "<F8>" 
let g:repl_code_block_fences = {'python': '###', 'zsh': '# %%', 'markdown': '```'}
