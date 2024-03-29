alias drun='export IMNAME=devenv_amazonlinux_mac;podman rm -f ${IMNAME};podman run --restart unless-stopped --name ${IMNAME} -it -d -v /mnt/Users:/mnt/Users -v /mnt/Users/ilyaro:${HOME} -v /etc/passwd:/etc/passwd -v /etc/shadow:/etc/shadow -v /etc/group:/etc/group -v /etc/ssl/certs:/etc/ssl/certs -v /etc/sudoers:/etc/sudoers gfish/${IMNAME}:latest'

alias de='podman exec -it devenv_amazonlinux_mac /bin/bash'

alias left='ls -t -1'

alias ls='ls -Fa'
alias ll='ls -lah'
alias l='ls -lah'
alias lt='du -sh * | sort -h'
alias mnt='mount | grep -E ^/dev | column -t'
alias gh='history|grep'

alias g=git
alias k=kubectl
alias t=terraform
