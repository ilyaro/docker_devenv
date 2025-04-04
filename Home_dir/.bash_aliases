alias drun='export IMNAME=devenv_amazonlinux_2023 && docker run -it -d --restart unless-stopped --name "${IMNAME}" -v /Volumes:/Volumes -v "${HOME}:${HOME}" -v /etc/resolv.conf:/etc/resolv.conf  --user root --env HOME="${HOME}" --env USER="${USER}" --env UID="$(id -u)" --env GID="$(id -g)" --entrypoint /bin/bash gfish/${IMNAME} -c "getent group \$GID || groupadd -g \$GID \$USER; id -u \$UID || useradd -m -u \$UID -g \$GID -d \$HOME -s /bin/bash \$USER; echo \"\$USER ALL=(ALL) NOPASSWD: ALL\" > /etc/sudoers.d/\$USER; chmod 0440 /etc/sudoers.d/\$USER; tail -f /dev/null"'

alias de='export IMNAME=devenv_amazonlinux_2023 && docker exec -it ${IMNAME} bash -c "export HOME=${HOME} && cd $HOME && sudo su - ${USER}"'

alias ls='ls -Fa'
alias ll='ls -lah'
alias l='ls -lah'
alias lt='du -sh * | sort -h'
alias mnt='mount | grep -E ^/dev | column -t'
alias gh='history|grep'

alias g=git
alias k=kubectl
alias t=terraform 
alias h=helm
alias tg="/opt/homebrew/bin/terragrunt"
alias d=docker
alias v=vim
alias c='code -r' 
alias git-bd='git checkout origin/HEAD;git remote prune origin;git branch --merged | grep -v HEAD | xargs -I{} git branch -d {}'