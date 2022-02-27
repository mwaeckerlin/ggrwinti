FROM mwaeckerlin/nextcloud
MAINTAINER mwaeckerlin

ENV APPS "ggrwinti calendar contacts groupfolders"
ENV DEBUG "1"

RUN sed -i '/mrw.sh/d' /etc/apt/sources.list
RUN apt-get update -y
RUN apt-get install --no-install-recommends --no-install-suggests -y automake git make pandoc dpkg-dev build-essential:native debhelper fakeroot git2cl pkg-config libtool libltdl-dev lsb-release doxygen graphviz mscgen default-jre-headless

WORKDIR /tmp/build
COPY . .
RUN ./bootstrap.sh -c
RUN make deb

#RUN apt-get update -y \
# && apt-get install --no-install-recommends --no-install-suggests -y wget ggrwinti \
# && /cleanup.sh \
# && mv ${APPSDIR}/ggrwinti /${APPSDIR}.original/

#ADD cronjob.sh /etc/cron.daily/update-db
ADD start-ggrwinti.sh /start-ggrwinti.sh

CMD /start-ggrwinti.sh
