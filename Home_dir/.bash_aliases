alias drun='export IMNAME=devenv_amazonlinux;docker rm -f ${IMNAME};docker run --restart unless-stopped --name ${IMNAME} -it -d -v /mnt/d:/mnt/d -v /mnt/c:/mnt/c -v ${HOME}:${HOME} -v /etc/passwd:/etc/passwd -v /etc/shadow:/etc/shadow -v /etc/group:/etc/group -v /etc/ssl/certs:/etc/ssl/certs -v /etc/sudoers:/etc/sudoers gfish/${IMNAME}:latest'

alias de='docker exec -it devenv_amazonlinux /bin/bash'
