## For using mobaxterm home directory with .ssh as in Windows
# Need to create d:\mobahome, specify it as Moba Home dir in Settings -> Configuration in MobaXterm
# And create symboilink link as Administrator only from c:\Users\ilyaro\.ssh to d:\mobahome\.ssh
C:\WINDOWS\system32>mklink /D d:\mobahome\.ssh c:\Users\ilyaro\.ssh
symbolic link created for d:\mobahome\.ssh <<===>> c:\Users\ilyaro\.ssh

## Copy Home_dir/* to ~/ (Home dir) of host Machine WSL2 Ubuntu20 Centos7 where we run docker run
 
## Copy Root_etc/* to /etc/ on WSL2 host machine only to enable docker start on WSL Ubuntu start 

## Copy ca-certificates.crt to /etc/pki/tls/certs/ca-bundle.crt for curl and git to work properly with passowrd 
ilyaro@ilyaro-5400:~$ sudo cp /etc/ssl/certs/ca-certificates.crt /etc/pki/tls/certs/ca-bundle.crt

# docker_devenv_ilyaro
Creating and maintain Docker image for development work, keeping development environment the same, on any system Need to be run with volume of git repositories attached 
Based on:
https://www.codemag.com/Article/1811021/Docker-for-Developers

https://docs.microsoft.com/en-us/learn/modules/use-docker-container-dev-env-vs-code/

Installing Docker od wsl2 Windows 10
https://www.codegrepper.com/code-examples/shell/install+docker+on+wsl2+ubuntu

# Building Docker image
$ docker build --build-arg UID=$(id -u) --build-arg GID=$(id -g) --rm -f Dockerfile -t gfish/devenv_user:$(git show -s --format=%ct-%h) -t gfish/devenv_user:latest . 

## For ec2-user 
docker build --build-arg UID=1000 --build-arg GID=1000 --rm -f Dockerfile_ec2-user -t gfish/devenv_ec2-user:$(git show -s --format=%ct-%h) -t g
fish/devenv_ec2-user:latest .

## For amazone linux base image, cloud9 based
docker build --rm -f Dockerfile_amazonlinux -t gfish/devenv_amazonlinux:$(git show -s --format=%ct-%h) -t gfish/devenv_amazonlinux:latest .

## For Centos 7 base image with tools 
NAME=devenv_centos7tools

$ docker build --rm -f Dockerfile_ -t gfish/devenv_:$(git show -s --format=%ct-%h) -t gfish/devenv_:latest .

# Pushing to my account
$ docker login

$ docker push gfish/devenv_user --all-tags

# Running development environment in Docker container:
$ docker run --rm -it gfish/devenv_user

# Running with volume mapping, -d daemon, $HOME evn variable. 
$ cd ~
$ NAME=devenv_amazonlinux;docker rm -f ${NAME};docker run --restart unless-stopped --name ${NAME} -it -d -v ${HOME}:${HOME} -v /etc/passwd:/etc/passwd -v /etc/shadow:/etc/shadow -v /etc/group:/etc/group -v /etc/ssl/certs:/etc/ssl/certs -v /etc/sudoers:/etc/sudoers gfish/${NAME}:latest

# On Windows 10 with WSL2
# Add aliases to ~/.bash_aliases

$ alias drun='export IMNAME=devenv_amazonlinux;docker rm -f ${IMNAME};docker run --restart unless-stopped --name ${IMNAME} -it -d -v /mnt/d:/mnt/d -v /mnt/c:/mnt/c -v ${HOME}:${HOME} -v /etc/passwd:/etc/passwd -v /etc/shadow:/etc/shadow -v /etc/group:/etc/group -v /etc/ssl/certs:/etc/ssl/certs -v /etc/pki/tls/certs:/etc/pki/tls/certs -v /etc/sudoers:/etc/sudoers gfish/${IMNAME}:latest'

$ alias de='docker exec -it devenv_amazonlinux /bin/bash'

## For ec2-user
docker run --restart unless-stopped --name devenv_ec2-user -it -d -v /home/ec2-user:/home/ec2-user gfish/devenv_ec2-user:latest

# Execute container
docker exec -it devenv_user /bin/bash

## How to set docker running on startup of Windows 10 WSL Ubuntu
https://blog.nillsf.com/index.php/2020/06/29/how-to-automatically-start-the-docker-daemon-on-wsl2/
