# docker_devenv_ilyaro
Creating and maintain Docker image for development work, keeping development environment the same, on any system Need to be run with volume of git repositories attached 
Based on:
https://www.codemag.com/Article/1811021/Docker-for-Developers

https://docs.microsoft.com/en-us/learn/modules/use-docker-container-dev-env-vs-code/


# Building Docker image
$ docker build --build-arg UID=$(id -u) --build-arg GID=$(id -g) --rm -f Dockerfile -t gfish/devenv_user:$(git show -s --format=%ct-%h) -t gfish/devenv_user:latest . 

## For ec2-user 
docker build --build-arg UID=1000 --build-arg GID=1000 --rm -f Dockerfile_ec2-user -t gfish/devenv_ec2-user:$(git show -s --format=%ct-%h) -t g
fish/devenv_ec2-user:latest .

## For amazone linux base image, cloud9 based
docker build --rm -f Dockerfile_amazonlinux -t gfish/devenv_amazonlinux:$(git show -s --format=%ct-%h) -t gfish/devenv_amazonlinux:latest .

# Pushing to my account
$ docker login

$ docker push gfish/devenv_user --all-tags

# Running development environment in Docker container:
$ docker run --rm -it gfish/devenv_user

# Running with volume mapping, -d daemon, $HOME evn variable. 
$ cd ~
$ NAME=devenv_amazonlinux;docker rm -f ${NAME};docker run --restart unless-stopped --name ${NAME} -it -d -v ${HOME}:${HOME} -v /etc/passwd:/etc/passwd -v /etc/shadow:/etc/shadow -v /etc/group:/etc/group -v /etc/ssl/certs:/etc/ssl/certs -v /etc/sudoers:/etc/sudoers gfish/${NAME}:latest

# On Windows 10 with WSL

$ docker run --restart unless-stopped --name devenv_user -it -d -v /mnt/c/Users/ilyaro:/home/ilyaro -v /mnt/d/:/d gfish/devenv_user:latest

## For ec2-user
docker run --restart unless-stopped --name devenv_ec2-user -it -d -v /home/ec2-user:/home/ec2-user gfish/devenv_ec2-user:latest

# Execute container
docker exec -it devenv_user /bin/bash

## How to set dockerd running on startup of Windows 10 WSL Ubuntu
https://blog.nillsf.com/index.php/2020/06/29/how-to-automatically-start-the-docker-daemon-on-wsl2/
