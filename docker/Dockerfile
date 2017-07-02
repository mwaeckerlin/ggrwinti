FROM mwaeckerlin/nextcloud
MAINTAINER mwaeckerlin

ENV APPS "ggrwinti"

RUN apt-get update -y && apt-get install -y ggrwinti
ADD cronjob.sh /etc/cron.daily/update-db
