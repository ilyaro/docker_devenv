alias drun='export IMNAME=devenv_amazonlinux_mac;podman rm -f ${IMNAME};podman run --restart unless-stopped --name ${IMNAME} -it -d -v /mnt/Users:/mnt/Users -v /mnt/Users/ilyaro:${HOME} -v /etc/passwd:/etc/passwd -v /etc/shadow:/etc/shadow -v /etc/group:/etc/group -v /etc/ssl/certs:/etc/ssl/certs -v /etc/sudoers:/etc/sudoers gfish/${IMNAME}:latest'

alias de='podman exec -it devenv_amazonlinux_mac /bin/bash'

alias ls='ls -F'
alias ll='ls -lah'

<<<<<<< HEAD
alias g=git
alias k=kubectl
alias t=terraform
=======
alias lt='du -sh * | sort -h'
>>>>>>> da6dc47 (+alias lt='du -sh * | sort -h')
