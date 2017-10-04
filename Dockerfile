FROM centos:centos6

# because theses where the most stable php 5.3.x repos are!

MAINTAINER paimpozhil@gmail.com
ENV MAGENTO_VERSION=1.9.2.4

# Centos default image for some reason does not have tools like Wget/Tar/etc so lets add them
RUN yum -y install wget

# EPEL has good RPM goodies!
RUN rpm -Uvh   http://download.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm

RUN yum -y install which openssh-server php-mysql php-gd php-mcrypt php-zip php-xml php-iconv php-curl php-soap php-simplexml php-pdo php-dom php-cli php-fpm nginx

RUN yum -y install tar mysql bzr

COPY default.conf /etc/nginx/conf.d/default.conf

RUN chkconfig php-fpm on

RUN chkconfig nginx on

#apply patch https://bugzilla.redhat.com/show_bug.cgi?id=1253897 for bzr on python 2.6.6
RUN yum -y install patch

RUN cd /tmp && wget https://code.launchpad.net/~jelmer/bzr/readline-size/+merge/44612/+preview-diff/78466/+files/preview.diff

RUN cd /tmp && sed -n '1,20p' preview.diff > bzr_patch.txt

RUN cd /usr/lib64/python2.6/site-packages && patch -p0 -N < /tmp/bzr_patch.txt

#install magento files

RUN mkdir -p /var_www_backup && cd /tmp && curl https://codeload.github.com/OpenMage/magento-mirror/tar.gz/$MAGENTO_VERSION -o $MAGENTO_VERSION.tar.gz && tar xvf $MAGENTO_VERSION.tar.gz && mv magento-mirror-$MAGENTO_VERSION/* magento-mirror-$MAGENTO_VERSION/.htaccess /var_www_backup/

RUN cd /var_www_backup/ && chmod -R o+w media var && chmod o+w app/etc && rm -f magento-*tar.gz

COPY magento-sample-data-1.9.1.0.tgz /tmp

RUN cd /tmp && tar -zxvf magento-sample-data-1.9.1.0.tgz

RUN cd /tmp && bzr checkout --lightweight http://bazaar.launchpad.net/~magentoerpconnect-core-editors/magentoerpconnect/module-magento-trunk/

COPY mage-cache.xml /var_www_backup/app/etc/mage-cache.xml

COPY seturl.php /var_www_backup/seturl.php

COPY start.sh /start.sh

RUN chmod 0755 /start.sh

RUN echo "daemon off;" >> /etc/nginx/nginx.conf

CMD /start.sh
