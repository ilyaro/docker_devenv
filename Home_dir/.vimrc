" Commit on each save :w if in git repository 
autocmd BufWritePost * !git ls-files --error-unmatch % && git commit -m "`git diff -U0 % | tail -1`" %
