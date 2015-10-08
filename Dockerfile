FROM centos:centos6

# because theses where the most stable php 5.3.x repos are!

MAINTAINER paimpozhil@gmail.com

# Centos default image for some reason does not have tools like Wget/Tar/etc so lets add them
RUN yum -y install wget

# EPEL has good RPM goodies!
RUN rpm -Uvh   http://download.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm

RUN yum -y install which openssh-server php-mysql php-gd php-mcrypt php-zip php-xml php-iconv php-curl php-soap php-simplexml php-pdo php-dom php-cli php-fpm nginx

RUN yum -y install tar mysql bzr

ADD default.conf /etc/nginx/conf.d/default.conf
 
RUN chkconfig php-fpm on

RUN chkconfig nginx on

#apply patch https://bugzilla.redhat.com/show_bug.cgi?id=1253897 for bzr on python 2.6.6
RUN yum -y install patch

ADD python-bzr.patch /tmp/

RUN cd /usr/lib64/python2.6/site-packages && patch -p0 -N < /tmp/python-bzr.patch

#install magento files 

RUN cd /tmp && wget http://www.magentocommerce.com/downloads/assets/1.7.0.2/magento-1.7.0.2.tar.gz

RUN cd /tmp && tar -zxvf magento-1.7.0.2.tar.gz

RUN mv /tmp/magento /var/www

RUN cd /var/www/ && chmod -R o+w media var && chmod o+w app/etc && rm -f magento-*tar.gz

RUN cd /tmp && wget http://www.magentocommerce.com/downloads/assets/1.6.1.0/magento-sample-data-1.6.1.0.tar.gz

RUN cd /tmp && tar -zxvf magento-sample-data-1.6.1.0.tar.gz

RUN cd /tmp && bzr checkout --lightweight http://bazaar.launchpad.net/~magentoerpconnect-core-editors/magentoerpconnect/module-magento-trunk/

ADD mage-cache.xml /var/www/app/etc/mage-cache.xml

ADD seturl.php /var/www/seturl.php

ADD start.sh /start.sh

RUN chmod 0755 /start.sh 

RUN echo "daemon off;" >> /etc/nginx/nginx.conf

CMD /start.sh


