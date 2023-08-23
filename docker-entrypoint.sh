#!/bin/bash
/usr/libexec/httpd-ssl-gencerts
if [ ! -z "$TZ" ]; then
	if [ -e "/usr/share/zoneinfo/$TZ" ]; then
		ln -snf "/usr/share/zoneinfo/$TZ" /etc/localtime
		sed -i "s|;date.timezone =|date.timezone = $TZ|g" /etc/php.ini
	fi
fi
exec "$@"
