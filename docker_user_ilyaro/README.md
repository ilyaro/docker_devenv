# docker_devenv_ilyaro
Creating and maintain Docker image for development work, keeping development environment the same, on any system Need to be run with volume of git repositories attached 
Based on:
https://www.codemag.com/Article/1811021/Docker-for-Developers

https://docs.microsoft.com/en-us/learn/modules/use-docker-container-dev-env-vs-code/


# Building Docker image
$ docker build --build-arg UID=$(id -u) --build-arg GID=$(id -g) --rm -f Dockerfile -t gfish/devenv:$(git show -s --format=%ct-%h) -t gfish/devenv_ilyaro:latest . 
-v $(pwd):/work
# Pushing to my account
$ docker login

$ docker push gfish/devenv_ilyaro --all-tags

# Running development environment in Docker container:
$ docker run --rm -it gfish/devenv_ilyaro

# Running with volume mapping, -d daemon, $HOME evn variable. 
$ cd ~
$ docker run --restart unless-stopped --name devenv -it -d -e "HOME=/work" -v $(pwd):/work gfish/devenv_ilyaro:latest

# On Windows 10 with WSL

$ docker run --restart unless-stopped --name devenv -it -d -e "HOME=/work" -v /mnt/c/Users/ilyaro:/work -v /mnt/d/:/d gfish/devenv_ilyaro:latest

# Execute container
docker exec -it devenv /bin/bash

## How to set dockerd running on startup of Windows 10 WSL Ubuntu
https://blog.nillsf.com/index.php/2020/06/29/how-to-automatically-start-the-docker-daemon-on-wsl2/
