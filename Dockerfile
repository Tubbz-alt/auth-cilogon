FROM centos:7

MAINTAINER Yee-Ting Li <ytl@slac.stanford.edu>

#ENV buildDeps git make gcc-c++ readline-devel ncurses-devel libcurl-devel httpd-devel openssl-devel krb5-devel

RUN yum -y --setopt=tsflags=nodocs install wget \
      && cd /etc/yum.repos.d \
      && wget https://repo.codeit.guru/codeit.el`rpm -q --qf "%{VERSION}" $(rpm -q --whatprovides redhat-release)`.repo \
      && yum -y remove wget

RUN yum -y --setopt=tsflags=nodocs install epel-release \
      && yum -y --setopt=tsflags=nodocs update \
      && yum -y --setopt=tsflags=nodocs install \
           httpd openssl \
           libtool httpd-tools mod_ssl perl-autodie perl-Readonly \
           https://github.com/zmartzone/mod_auth_openidc/releases/download/v2.3.11/mod_auth_openidc-2.3.11-1.el7.x86_64.rpm https://github.com/zmartzone/mod_auth_openidc/releases/download/v2.3.11/cjose-0.6.1.4-1.el7.x86_64.rpm \
      && yum clean all

COPY httpd.conf /etc/httpd/conf/httpd.conf
COPY magic /etc/httpd/conf/magic

# copy empty cert files: use docker bind mounts to overwrite
COPY certs /etc/httpd/certs

# copy app config
COPY proxy-app.conf /etc/httpd/conf.d/proxy-app.conf
COPY openidc.conf /etc/httpd/conf.d/openidc.conf

# index redirect
COPY oidc-index.php /var/www/html/oidc/index.php
#COPY index.html /var/www/html/index.html

# copy startup scripts
ADD docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod -v +x /docker-entrypoint.sh

CMD ["/docker-entrypoint.sh"]

