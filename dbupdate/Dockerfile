FROM mwaeckerlin/cron AS cron
#RUN $PKG_INSTALL 


# wget -qO- https://parlament.winterthur.ch/_rtr/politbusiness | sed -n ':a;$!N;$!ba;s/.*data-entities="\([^"]*\)".*/\1/p' | recode html..ascii | ascii2uni -Z '\u%04X' -q


FROM mwaeckerlin/nodejs-build AS build
RUN $PKG_INSTALL wget recode make gcc build-base jq
RUN wget -qO- http://billposer.org/Software/Downloads/uni2ascii-4.18.tar.bz2 | tar xjC /tmp
WORKDIR /tmp/uni2ascii-4.18
#RUN aclocal
#RUN automake --add-missing
#RUN automake
#RUN autoconf
RUN ./configure --prefix=/usr
RUN make
RUN make install
WORKDIR /srv
COPY dbupdate.js dbupdate.sh /srv/
CMD /srv/dbupdate.sh