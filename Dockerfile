FROM centos:centos6
LABEL version="1.1.1"

ENV TERM xterm

# Simple startup script to avoid some issues observed with container restart
# RUN yum -y update -x kernel; yum clean all
# RUN yum -y install httpd; yum clean all
RUN yum update -y -x kernel && \
    yum install -y \
        epel-release && \
    yum install -y \
        bind-utils \
        curl \
        git \
        httpd \
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

RUN echo "Apache HTTPD" >> /var/www/html/index.html

EXPOSE 80

# RUN rm -f /etc/localtime && ln -s /usr/share/zoneinfo/UTC /etc/localtime

RUN service httpd start

VOLUME /var/log
