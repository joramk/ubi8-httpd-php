FROM    registry.access.redhat.com/ubi8/ubi-init
MAINTAINER joramk@gmail.com
ENV     container docker

LABEL   name="RHEL UBI 8 - Latest base Apache / Remi PHP 8.1" \
        vendor="https://github.com/joramk/ubi8-httpd-php" \
        license="none" \
        build-date="20220510" \
        maintainer="joramk@gmail.com"

RUN {	dnf --disableplugin=subscription-manager install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm; \
        dnf --disableplugin=subscription-manager install -y http://rpms.famillecollet.com/enterprise/remi-release-8.rpm; \
        dnf --disableplugin=subscription-manager repolist --nogpgcheck --enablerepo=remi; \
        dnf --disableplugin=subscription-manager module -y --nogpgcheck install httpd php:remi-8.1; \
	dnf --disableplugin=subscription-manager install -y --nogpgcheck rpmconf hostname php php-json php-cli php-mbstring php-mysqlnd php-gd php-xml php-bcmath php-common php-pdo php-process php-soap; \
        dnf --disableplugin=subscription-manager clean all; rm -rf /var/cache/yum; \
	rpmconf -a -c -u use_maintainer; \
}

RUN {	mkdir /run/php-fpm && \
	chgrp -R 0 /var/log/httpd /var/run/httpd /run/php-fpm && \
	chmod -R g=u /var/log/httpd /var/run/httpd /run/php-fpm && \
	/usr/libexec/httpd-ssl-gencerts; \
	ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime; \
	systemctl enable httpd php-fpm; \
}

EXPOSE  80
CMD	/sbin/init
