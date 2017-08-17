#! /bin/bash

#HERE#

if test -n "$MYSQL_ENV_MYSQL_PASSWORD"; then
    update-db.sh -m | mysql -h mysql -u "${MYSQL_ENV_MYSQL_USER}" -p"${MYSQL_ENV_MYSQL_PASSWORD}" "${MYSQL_ENV_MYSQL_DATABASE}"
else
    update-db.sh -s | sudo -u www-data sqlite3 /var/www/nextcloud/data/nextcloud.db
fi
