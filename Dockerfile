FROM    registry.access.redhat.com/ubi8/ubi-init
MAINTAINER joramk@gmail.com
ENV     container docker

LABEL   name="RHEL UBI 8 - Latest base Apache / Remi PHP 8.2" \
        vendor="https://github.com/joramk/ubi8-httpd-php" \
        license="none" \
        build-date="20230108" \
        maintainer="joramk@gmail.com"


RUN {   sed -i 's/enabled=1/enabled=0/g' /etc/yum/pluginconf.d/subscription-manager.conf; \
	dnf --disableplugin=subscription-manager update -y; \
}

RUN {	dnf --disableplugin=subscription-manager install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm; \
        dnf --disableplugin=subscription-manager install -y dnf-plugin-ovl; \
        dnf --disableplugin=subscription-manager install -y http://rpms.famillecollet.com/enterprise/remi-release-8.rpm; \
        dnf --disableplugin=subscription-manager repolist --nogpgcheck --enablerepo=remi; \
	dnf --disableplugin=subscription-manager module -y --nogpgcheck install httpd; \
	dnf --disableplugin=subscription-manager install -y --nogpgcheck rpmconf hostname php82-php php82-php-json php82-php-cli php82-php-mbstring php82-php-mysqlnd php82-php-gd php82-php-xml php82-php-bcmath php82-php-common php82-php-pdo php82-php-process php82-php-soap php82-syspaths php82-php-fpm; \
        dnf --disableplugin=subscription-manager clean all; rm -rf /var/cache/yum; \
	rpmconf -a -c -u use_maintainer; \
}

RUN {	mkdir /run/php-fpm && \
	chgrp -R 0 /var/log/httpd /var/run/httpd /run/php-fpm && \
	chmod -R g=u /var/log/httpd /var/run/httpd /run/php-fpm && \
	/usr/libexec/httpd-ssl-gencerts; \
	ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime; \
	systemctl enable httpd; \
}

EXPOSE  80
STOPSIGNAL SIGRTMIN+3
CMD	[ "/sbin/init" ]
