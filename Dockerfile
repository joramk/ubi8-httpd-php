FROM    registry.access.redhat.com/ubi8/ubi-init
MAINTAINER joramk@gmail.com
ENV     container docker

LABEL   name="RHEL UBI 8 - Latest base Apache / Remi PHP 8.1" \
        vendor="https://github.com/joramk/ubi8-httpd-php" \
        license="none" \
        build-date="20220510" \
        maintainer="joramk@gmail.com"

COPY    ./docker-entrypoint.sh /

RUN {	dnf --disableplugin=subscription-manager install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm; \
        dnf --disableplugin=subscription-manager install -y dnf-plugin-ovl; \
        dnf --disableplugin=subscription-manager install -y http://rpms.famillecollet.com/enterprise/remi-release-8.rpm; \
        dnf --disableplugin=subscription-manager repolist --nogpgcheck --enablerepo=remi; \
        dnf --disableplugin=subscription-manager module -y --nogpgcheck install httpd; \
        dnf --disableplugin=subscription-manager install -y --nogpgcheck rpmconf hostname php81-php \
                php81-php-json php81-php-cli php81-php-mbstring php81-php-mysqlnd php81-php-gd php81-php-xml php81-php-bcmath php81-php-common \
                php81-php-mcrypt php81-php-pear php81-php-xmlrpc php81-php-zip php81-php-brotli php81-php-pdo php81-php-process php81-php-soap php81-php-zip; \
        dnf --disableplugin=subscription-manager clean all; rm -rf /var/cache/yum; \
        rpmconf -a -c -u use_maintainer; \
}

RUN {	mkdir /run/php-fpm && \
	chgrp -R 0 /var/log/httpd /var/run/httpd && \
	chmod -R g=u /var/log/httpd /var/run/httpd && \
	ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime; \
	systemctl enable httpd php81-php-fpm; \
}

EXPOSE     80
STOPSIGNAL SIGRTMIN+3
ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD        [ "/sbin/init" ]
