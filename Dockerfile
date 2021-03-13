FROM centos:latest

LABEL maintainer="Ilya Rokhkin"

RUN yum update -y \
  && yum install -y \
  sudo \
  git \
  python3 \
  && yum clean all

ENTRYPOINT ["/bin/bash"]
