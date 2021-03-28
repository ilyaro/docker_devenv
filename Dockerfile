FROM centos:latest

LABEL maintainer="Ilya Rokhkin"

RUN yum update -y \
  && yum install -y \
  sudo \
  git \
  python3 \
  python3-pip \
  && yum clean all
RUN python3 -m pip install boto3
RUN python3 -m pip install pyyaml

ENTRYPOINT ["/bin/bash"]
