FROM    registry.access.redhat.com/ubi8/ubi-init
MAINTAINER joramk@gmail.com
ENV     container docker

LABEL   name="RHEL UBI 8 - Latest base Apache / Remi PHP 8.2" \
        vendor="https://github.com/joramk/ubi8-httpd-php" \
        license="none" \
        build-date="20230823" \
        maintainer="joramk@gmail.com"

COPY	docker-entrypoint.sh /

RUN {   sed -i 's/enabled=1/enabled=0/g' /etc/yum/pluginconf.d/subscription-manager.conf; \
	dnf --disableplugin=subscription-manager update -y; \
        dnf --disableplugin=subscription-manager install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm; \
        dnf --disableplugin=subscription-manager install -y dnf-plugin-ovl; \
        dnf --disableplugin=subscription-manager install -y http://rpms.famillecollet.com/enterprise/remi-release-8.rpm; \
        dnf --disableplugin=subscription-manager repolist --nogpgcheck --enablerepo=remi; \
        dnf --disableplugin=subscription-manager module -y --nogpgcheck install httpd php:remi-8.2; \
        dnf --disableplugin=subscription-manager install -y --nogpgcheck rpmconf hostname nano vim php php-intl \
                php-json php-cli php-mbstring php-mysqlnd php-gd php-xml php-bcmath php-common php-pecl-xdebug3 \
                php-mcrypt php-pear php-xmlrpc php-zip php-brotli php-pdo php-process php-soap php-zip \
		php-redis php-memcached; \
        dnf --disableplugin=subscription-manager clean all; rm -rf /var/cache/yum; \
        rpmconf -a -c -u use_maintainer; \
	rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2022; \
	dnf --disableplugin=subscription-manager install -y https://repo.mysql.com/mysql80-community-release-el8-1.noarch.rpm; \
	dnf --disableplugin=subscription-manager install -y mysql; \
	chmod +x /docker-entrypoint.sh && mkdir /run/php-fpm && \
	chgrp -R 0 /var/log/httpd /var/run/httpd /run/php-fpm && \
	chmod -R g=u /var/log/httpd /var/run/httpd /run/php-fpm && \
	/usr/libexec/httpd-ssl-gencerts; \
	ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime; \
	systemctl enable httpd; \
	sed -i 's/zend_extension=xdebug.so/;zend_extension=xdebug.so/g' /etc/php.d/15-xdebug.ini; \
	touch /var/log/php-fpm/error.log /var/log/php-fpm/www-error.log; \
	chown apache:apache /var/log/php-fpm/www-error.log; \
}

EXPOSE		80
STOPSIGNAL	SIGRTMIN+3
ENTRYPOINT	[ "/docker-entrypoint.sh" ]
CMD		[ "/sbin/init" ]
HEALTHCHECK CMD /usr/bin/systemctl is-active --quiet httpd php-fpm || exit 1
