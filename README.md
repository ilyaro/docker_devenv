# docker_devenv
Creating and maintain Docker image for development work,
Docker images are usually used to run software on servers, Kubernetes

Here you can use it for your development environmant, always uptodate 
and the same on any system and for all team members using the image.

You need to add to Dockerfile whatever you neeed and update its versions regulary

Here I use several Dockerfiles for Devenv, based on Linux2, Centos7 with full stack
of tool we use in the team 

Need to be run with volume of git repositories attached 
Based on:
https://www.codemag.com/Article/1811021/Docker-for-Developers

https://docs.microsoft.com/en-us/learn/modules/use-docker-container-dev-env-vs-code/


# Building Docker image
$ docker build --rm -f Dockerfile -t gfish/devenv:$(git show -s --format=%ct-%h) -t gfish/devenv:latest .
-v $(pwd):/work
# Pushing to my account
$ docker login

$ docker push gfish/devenv --all-tags

# Running development environment in Docker container:
$ docker run --rm -it gfish/devenv

# Running with volume mapping, -d daemon, $HOME evn variable. 
$ cd ~
$ docker run --restart unless-stopped --name devenv -it -d -e "HOME=/work" -v $(pwd):/work gfish/devenv:latest

# On Windows 10 with WSL

$ docker run --restart unless-stopped --name devenv -it -d -e "HOME=/work" -v /mnt/c/Users/ilyaro:/work -v /mnt/d/:/d gfish/devenv:latest

# Execute container
docker exec -it devenv /bin/bash

## How to set dockerd running on startup of Windows 10 WSL Ubuntu
https://blog.nillsf.com/index.php/2020/06/29/how-to-automatically-start-the-docker-daemon-on-wsl2/
