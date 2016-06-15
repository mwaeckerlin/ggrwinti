# ggrwinti
OwnCloud App für die Fraktionsarbet im Winterthurer Gemeinderat

For testing purposes, start docker containers, e.g.:

    LOCAL_GIT=~/git/ggrwinti/html
    docker run -d --name ggrwinti-mysql-volume mysql sleep infinity
    docker run -d --name ggrwinti-mysql --volumes-from ggrwinti-mysql-volume -e MYSQL_DATABASE=owncloud -e MYSQL_USER=owncloud -e MYSQL_PASSWORD=ert456 -e MYSQL_RANDOM_ROOT_PASSWORD=1 mysql
    docker run -d --name ggrwinti-volume mwaeckerlin/ggrwinti sleep infinity
    docker run -d -p 7777:80 --name ggrwinti --volumes-from ggrwinti-volume -v ${LOCAL_GIT}:/var/www/owncloud/apps/ggrwinti:ro --link ggrwinti-mysql:mysql mwaeckerlin/ggrwinti

Fillup the MySQL database:

    docker exec -it ggrwinti bash
    update-db.sh | mysql -h mysql -u${MYSQL_ENV_MYSQL_USER} -p${MYSQL_ENV_MYSQL_PASSWORD} ${MYSQL_ENV_MYSQL_DATABASE}

If you want to see the values interactively, use:

    docker exec -it ggrwinti bash
    update-db.sh | tee | mysql -h mysql -u${MYSQL_ENV_MYSQL_USER} -p${MYSQL_ENV_MYSQL_PASSWORD} ${MYSQL_ENV_MYSQL_DATABASE}
