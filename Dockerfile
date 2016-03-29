FROM centos:centos6
LABEL version="1.1.0"

ENV TERM xterm

# Any file with the "repo" extension will be added to /etc/yum.repos.d folder
# COPY *.repo /etc/yum.repos.d/

RUN yum update -y -x kernel && \
    yum install -y \
        epel-release && \
    yum install -y \
        bind-utils \
        curl \
        git \
        mc \
        net-tools \
        ntp \
        openssh-server \
        openssh-clients \
        sudo \
        tar \
        unzip \
        vim \
        wget

# RUN rm -f /etc/localtime && ln -s /usr/share/zoneinfo/UTC /etc/localtime
VOLUME /var/log
CMD ["/start.sh"]
