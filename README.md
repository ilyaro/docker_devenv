# docker_devenv
Creating and maintain Docker image for development work, keeping development environment the same, on any system Need to be run with volume of git repositories attached 
Based on:
https://www.codemag.com/Article/1811021/Docker-for-Developers

https://docs.microsoft.com/en-us/learn/modules/use-docker-container-dev-env-vs-code/


# Building Docker image
$ docker build --rm -f Dockerfile -t gfish/devenv:$(git show -s --format=%ct-%h) -t gfish/devenv:latest .

# Pushing to my account
$ docker login

$ docker push gfish/devenv --all-tags

# Running development environment in Docker container:
$ docker run --rm -it gfish/devenv

# Running with volume mapping, -d daemon, $HOME evn variable. 
$ cd ~
$ docker run --restart unless-stopped --name devenv -it -d -e "HOME=/work" -v $(pwd):/work gfish/devenv:latest

# On Windows 10 with WSL
$ docker run --restart unless-stopped --name devenv -it -d -e "HOME=/work" -v /mnt/d/:/work gfish/devenv:latest

# Execute container
docker exec -it devenv /bin/bash
