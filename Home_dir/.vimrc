" Commit on each save :w 
" if in git repository, if the being saved file is part of the repo, commit with comment of last changed line, if current branch is not default branch - push it  
autocmd BufWritePost * !git rev-parse --is-inside-work-tree >/dev/null 2>&1 && 
\ git ls-files --error-unmatch % && 
\ git commit -m "`git diff -U0 % | tail -1`" % &&
\ git symbolic-ref --short refs/remotes/origin/HEAD | grep -v $(git branch --show-current) > /dev/null 2>&1 && git push
" Not to add end of file automatically
set nofixendofline
" replace tab with spaces
set expandtab
" 4 chars tab
set ts=4 sw=4
" syntax text
syntax on
