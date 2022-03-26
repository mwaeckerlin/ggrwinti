FROM mwaeckerlin/nextcloud:18

ENV APPS "ggrwinti calendar contacts groupfolders"
ENV DEBUG "1"

COPY . /var/www/nextcloud/apps/ggrwinti
