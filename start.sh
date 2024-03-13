#!/usr/bin/env bash

if [ ! -f /var/www/var/letswifi-dev.sqlite ]; then
    sqlite3 /var/www/var/letswifi-dev.sqlite < /var/www/sql/letswifi.sqlite.sql
fi

mkdir -p /var/simplesamlphp/mdq-cache

chown www-data:www-data /var/simplesamlphp/mdq-cache

env APACHE_LOCK_DIR=/var/lock/apache2 APACHE_RUN_DIR=/var/run/apache2 APACHE_PID_FILE=/var/run/apache2/apache2.pid APACHE_RUN_USER=www-data APACHE_RUN_GROUP=www-data APACHE_LOG_DIR=/var/log/apache2 apache2 -DFOREGROUND
