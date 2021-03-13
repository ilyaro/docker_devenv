# docker_devenv
Creating and maintain Docker image for development work, keeping development environment the same, on any system Need to be run with volume of git repositories attached 
Based on https://www.codemag.com/Article/1811021/Docker-for-Developers

# Building Docker image
docker build --rm -f Dockerfile -t gfish/devenv:1.0 .

# Pushing to my account
docker login

docker push gfish/devenv:1.0
