# docker_devenv
Creating and maintain Docker image for development work, keeping development environment the same, on any system Need to be run with volume of git repositories attached 
Based on:
https://www.codemag.com/Article/1811021/Docker-for-Developers

https://docs.microsoft.com/en-us/learn/modules/use-docker-container-dev-env-vs-code/


# Building Docker image
docker build --rm -f Dockerfile -t gfish/devenv_npm:1.0 -t gfish/devenv_npm:latest .

# Pushing to my account
docker login

docker push gfish/devenv:1.0

# Running development environment in Docker container:
docker run --rm -it gfish/devenv

# Running with volume mapping, -d daemon, $HOME evn variable. 
docker run --restart unless-stopped --name devenv_npm -it -d -e "HOME=/work" -v /mnt/d/:/work gfish/devenv_npm:1.0


# Execute container
docker exec -it devenv_npm /bin/bash
