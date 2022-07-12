" Commit on each save :w if in git repository 
autocmd BufWritePost * !git ls-files --error-unmatch % && git commit -m "`git diff -U0 % | tail -1`" %
" Not to add end of file automatically
set nofixendofline
" replace tab with spaces
set expandtab
" 4 chars tab
set ts=4 sw=4
