" Vim filetype plugin file
" Language:	python
" Author: Patrick Hogan 
" Email: patrick.hogan527@gmail.com
" Last Change: 2018-05-18
"
" This extends the default python ftplugin for vim, primarily by automatically
" setting the vim path to include the current file directory, the python path
" and appropirate python libraries. It's intended to be added to the distributed
" python ftplugin, or placed standalone in ~/.vim/after/ftplugin/python.vim
"
" Python module paths are determined by running $PYTHONEXE if it exists, or
" 'python' if $PYTHONEXE is not set, and calling sys.path. 
"
" Additionally, several options I find useful when editing python files are set;
" the most intrusive of which is removing trailing whitespace from all lines on
" write.

"Autoindent after keywords:
setlocal smartindent
setlocal cinwords=if,elif,else,for,while,try,except,finally,def,class
setlocal expandtab
setlocal shiftwidth=4
setlocal softtabstop=4
setlocal tabstop=4
setlocal autoindent
setlocal fileformat=unix
setlocal encoding=utf-8

if !exists("s:pythonlibs")
    " Using $PYTHONEXE if set, or default python, determine which lib path(s) to 
    " include:
    let s:pythonexe=$PYTHONEXE
    if s:pythonexe == ""
        let s:pythonexe='python'
    endif
    let s:pythonlibs=filter(split(substitute(substitute(system(
        \ s:pythonexe.' -c "import sys; print(sys.path)"'), "[] \n\[']", '', 'g'),
        \ '^,','',''),','),'isdirectory(v:val)')
endif

" Pythonpath uses ':' as separator; change to ',' for vim. This adds ',' to the
" path if PYTHONPATH is not set, but that's harmless:
execute "setlocal path=.,".substitute($PYTHONPATH,':',',','g').",".join(s:pythonlibs,',')
"'include' and 'includeexpr' set by global ftplugin/python.vim

" Remove trailing whitespace from lines:
autocmd BufWritePre * :%s/\s\+$//e

" Try to run the python-language-server:
if executable('pyls')
    au User lsp_setup call lsp#register_server({
        \ 'name': 'pyls',
        \ 'cmd': {server_info->['pyls']},
        \ 'whitelist': ['python'],
        \ })
endif

