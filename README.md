NextCloud App für die Fraktionsarbeit im Winterthurer Gemeinderat
=================================================================

Organisiere Deine Fraktion in Nextcloud: Füge Deine Gemeinderäte als Mitglied hinzu, definiere eine Gruppe, dann weise die Geschäfte den Personen zu und dokumentiere die Entscheidungen. Teile einen Pfad und lade Berichte zu den Geschäften hoch, indem Du die Geschäftsnummer im Dateinamen verwendest.

Überprüft täglich die [Webseite des Gemeinderats Winterthur](http://gemeinderat.winterthur.ch) und gleicht [Geschäfte](http://gemeinderat.winterthur.ch/de/politbusiness) und [Sitzungen](http://gemeinderat.winterthur.ch/de/sitzung/) in der lokalen Datenbank ab.

Entwickelt vom Gemeinderat der Piratenpartei Marc Wäckerlin für die grünliberale-/Piratenpartei-Fraktion.

Developers
----------

For testing purposes, start docker containers, e.g.:

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
    docker run -it --name ggrwinti \
               --rm \
               -p 9999:80 \
               -e ADMIN_PWD=ert456 \
               --link ggrwinti-mysql:mysql \
               -v $(pwd)/html:/var/www/nextcloud/apps/ggrwinti \
               mwaeckerlin/ggrwinti bash

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
               mwaeckerlin/ggrwinti
    docker run -d --restart unless-stopped \
                  --name reverse-proxy \
                  -p 80:80 -p 443:443 \
                  --link ggrwinti:my.ggr.cloud
                  mwaeckerlin/reverse-proxy

Problem
-------

```
Error	index	OCP\AppFramework\QueryException: Could not resolve AppName! Class AppName does not exist

    /var/www/nextcloud/lib/private/AppFramework/Utility/SimpleContainer.php - line 117: OC\AppFramework\Utility\SimpleContainer->resolve('AppName')
    /var/www/nextcloud/lib/private/ServerContainer.php - line 132: OC\AppFramework\Utility\SimpleContainer->query('AppName')
    /var/www/nextcloud/lib/private/AppFramework/Utility/SimpleContainer.php - line 66: OC\ServerContainer->query('AppName')
    /var/www/nextcloud/lib/private/AppFramework/Utility/SimpleContainer.php - line 96: OC\AppFramework\Utility\SimpleContainer->buildClass(Object(ReflectionClass))
    /var/www/nextcloud/lib/private/AppFramework/Utility/SimpleContainer.php - line 117: OC\AppFramework\Utility\SimpleContainer->resolve('OCA\\GgrWinti\\Co...')
    /var/www/nextcloud/lib/private/ServerContainer.php - line 132: OC\AppFramework\Utility\SimpleContainer->query('OCA\\GgrWinti\\Co...')
    /var/www/nextcloud/lib/private/AppFramework/DependencyInjection/DIContainer.php - line 410: OC\ServerContainer->query('OCA\\GgrWinti\\Co...')
    /var/www/nextcloud/lib/private/AppFramework/App.php - line 101: OC\AppFramework\DependencyInjection\DIContainer->query('OCA\\GgrWinti\\Co...')
    /var/www/nextcloud/lib/private/AppFramework/Routing/RouteActionHandler.php - line 47: OC\AppFramework\App main('OCA\\GgrWinti\\Co...', 'index', Object(OC\AppFramework\DependencyInjection\DIContainer), Array)
    [internal function] OC\AppFramework\Routing\RouteActionHandler->__invoke(Array)
    /var/www/nextcloud/lib/private/Route/Router.php - line 299: call_user_func(Object(OC\AppFramework\Routing\RouteActionHandler), Array)
    /var/www/nextcloud/lib/base.php - line 1000: OC\Route\Router->match('/apps/ggrwinti/')
    /var/www/nextcloud/index.php - line 40: OC handleRequest()
    {main}
```

simple logging:

    file_put_contents("/tmp/log", "...\n", FILE_APPEND);
