FROM mwaeckerlin/owncloud
MAINTAINER mwaeckerlin

ENV APPS "ggrwinti"

RUN apt-get update -y && apt-get install -y ggrwinti
ADD cronjob.sh /etc/cron.hourly/update-db
