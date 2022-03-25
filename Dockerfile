FROM mwaeckerlin/nextcloud:22

ENV APPS "ggrwinti calendar contacts groupfolders"
ENV DEBUG "1"

COPY . /var/www/nextcloud/apps/ggrwinti
