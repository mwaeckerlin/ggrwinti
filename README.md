# ggrwinti
OwnCloud App für die Fraktionsarbet im Winterthurer Gemeinderat

For testing purposes, start docker containers, e.g.:

    docker run -d --name ggrwinti-mysql -e MYSQL_DATABASE=owncloud -e MYSQL_USER=owncloud -e MYSQL_PASSWORD=ert456 -e MYSQL_RANDOM_ROOT_PASSWORD=1 mysql
    docker run -d -p 7777:80 --name ggrwinti -v ~/git/ggrwinti/html:/var/www/owncloud/apps/ggrwinti:ro --link ggrwinti-mysql:mysql mwaeckerlin/ggrwinti
    