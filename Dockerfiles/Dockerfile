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
RUN python3 -m pip install redis

ARG UNAME=ilyaro
ARG UID=1000
ARG GID=1000
RUN groupadd -g $GID -o $UNAME
RUN useradd -m -u $UID -g $GID -o -s /bin/bash $UNAME
USER $UNAME

ENTRYPOINT ["/bin/bash"]
