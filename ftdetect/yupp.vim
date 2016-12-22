autocmd BufRead,BufNewFile *.yu-c set filetype=c|hi clear Error
autocmd BufRead,BufNewFile *.yu-py set filetype=python
autocmd BufUnload * call yupp#cleanup()
