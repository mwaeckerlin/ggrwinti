#! /bin/bash

env > /tmp/cron.env
sudo -Hu env > /tmp/cron.root.env
update-db.sh | mysql -h mysql -u "${MYSQL_ENV_MYSQL_USER}" -p"${MYSQL_ENV_MYSQL_PASSWORD}" "${MYSQL_ENV_MYSQL_DATABASE}"
