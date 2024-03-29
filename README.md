NextCloud App für die Fraktionsarbeit im Winterthurer Gemeinderat
=================================================================

Organisiere Deine Fraktion in Nextcloud: Füge Deine Gemeinderäte als Mitglied hinzu, definiere eine Gruppe, dann weise die Geschäfte den Personen zu und dokumentiere die Entscheidungen. Teile einen Pfad und lade Berichte zu den Geschäften hoch, indem Du die Geschäftsnummer im Dateinamen verwendest.

Überprüft täglich die [Webseite des Gemeinderats Winterthur](http://parlament.winterthur.ch) und gleicht [Geschäfte](https://parlament.winterthur.ch/politbusiness) und [Sitzungen](https://parlament.winterthur.ch/sitzung) in der lokalen Datenbank ab.

Configuration
-------------

See [mwaeckerlin/nextcloud](https://github.com/mwaeckerlin/nextcloud).

Developers
----------

For testing purposes, start docker containers, e.g.:

    docker pull mwaeckerlin/ggrwinti
    git pull https://github.com/mwaeckerlin/ggrwinti
    cd ggrwinti
    docker build --rm --force-rm -t mwaeckerlin/ggrwinti docker
    ./bootstrap.sh -a
    docker rm -f ggrwinti-mysql
    docker run -d --name ggrwinti-mysql \
               -e MYSQL_DATABASE=nextcloud \
               -e MYSQL_USER=nextcloud \
               -e MYSQL_PASSWORD=ert456 \
               -e MYSQL_RANDOM_ROOT_PASSWORD=1 \
               mysql
    docker rm -f ggrwinti
    docker run -d --name ggrwinti \
               -p 9999:80 \
               -e ADMIN_PWD=ert456 \
               --link ggrwinti-mysql:mysql \
               -v $(pwd)/html:/var/www/nextcloud/apps/ggrwinti:ro \
               -v $(pwd):/workdir:ro \
               mwaeckerlin/ggrwinti

Go to http://localhost:9999 and login with user `admin` and password `ert456`. Local changes in html will immediately appear on the web. If you change in `scripts` or somewhere else, you need to copy the changed files manually from `/workdir`.

### More Commands ###

Fillup database, type:

    docker exec -it ggrwinti /etc/cron.daily/update-db

Enter the virtual machine as `root` (use `sudo -u www-data` for accessing webserver data; emacs is available):

    docker exec -it ggrwinti bash

Access the database:

    docker exec -it ggrwinti mysql -h mysql -u nextcloud -pert456 nextcloud

Test a locally changed `script/update-database.sh`:

    docker exec -it ggrwinti bash
    /workdir/scripts/update-db.sh --help
    /workdir/scripts/update-db.sh -m \
      | mysql -h mysql -u nextcloud -pert456 nextcloud

Activate a locally changed `script/update-database.sh`:

    docker exec -it ggrwinti cp /workdir/scripts/update-db.sh /usr/sbin/


Run in Production
-----------------

    docker run -d --restart unless-stopped \
               --name ggrwinti-mysql-volume \
               mysql sleep infinity
    docker run -d --restart unless-stopped \
               --name ggrwinti-mysql \
               --volumes-from ggrwinti-mysql-volume \
               -e MYSQL_DATABASE=nextcloud \
               -e MYSQL_USER=nextcloud \
               -e MYSQL_PASSWORD=$(pwgen 20 1) \
               -e MYSQL_RANDOM_ROOT_PASSWORD=1 \
               mysql
    docker run -d --restart unless-stopped \
                  --name ggrwinti-volume \
                  mwaeckerlin/ggrwinti sleep infinity
    docker run -d --restart unless-stopped \
               --name ggrwinti \
               -e ADMIN_PWD=$(pwgen 20 1) \
               --volumes-from ggrwinti-volume \
               --link ggrwinti-mysql:mysql \
               -e URL=my.ggr.cloud \
               mwaeckerlin/ggrwinti
    docker run -d --restart unless-stopped \
                  --name reverse-proxy \
                  -p 80:80 -p 443:443 \
                  --link ggrwinti:my.ggr.cloud
                  mwaeckerlin/reverse-proxy
