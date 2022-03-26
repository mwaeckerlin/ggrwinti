FROM mwaeckerlin/nextcloud:19

ENV APPS "ggrwinti calendar contacts groupfolders"
ENV DEBUG "1"

COPY . /var/www/nextcloud/apps/ggrwinti
# trigger build