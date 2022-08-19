#!/bin/bash
/usr/libexec/httpd-ssl-gencerts
exec "$@"

