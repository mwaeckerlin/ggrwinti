FROM mwaeckerlin/nextcloud
MAINTAINER mwaeckerlin

ENV APPS "ggrwinti"
ENV DEBUG "1"

RUN apt-get update -y && apt-get install -y ggrwinti
ADD cronjob.sh /etc/cron.daily/update-db
ADD start-ggrwinti.sh /start-ggrwinti.sh

CMD /start-ggrwinti.sh