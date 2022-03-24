FROM mwaeckerlin/nodejs-build AS build
ARG UNI2ASCII_VERSION=4.18
ARG UPDATE_FREQUENCY=daily
RUN $PKG_INSTALL wget recode make gcc build-base jq pkgconf libxml2-dev libxml2-utils
RUN wget -qO- http://billposer.org/Software/Downloads/uni2ascii-${UNI2ASCII_VERSION}.tar.bz2 | tar xjC /tmp
WORKDIR /tmp/uni2ascii-${UNI2ASCII_VERSION}
RUN ./configure --prefix=/usr
RUN make
RUN make install
WORKDIR /tmp
RUN git clone https://github.com/clone/xml2
WORKDIR /tmp/xml2
RUN chmod +x install-sh configure
RUN ./configure --prefix=/usr
RUN make
RUN make install
WORKDIR /tmp/root/srv
RUN npm install mysql2 fs
COPY geschaefteupdate.js sitzungenupdate.js traktandenupdate.js dbupdate.sh /tmp/root/srv/
ENV files "/usr/bin/wget /usr/bin/recode /usr/bin/ascii2uni /usr/bin/node /usr/bin/xmllint /usr/bin/xml2 /usr/bin/printf"
RUN for file in $files \
                $(for file2 in $files; do \
                    ldd $file2 | sed -n 's,.* \([^ ]*/lib/[^ ]*\) .*,\1,p'; \
                done); do \
        path=${file%/*}; \
        test -d /tmp/root/$path || mkdir -p /tmp/root/$path; \
        cp -L $file /tmp/root/$file; \
    done
RUN mkdir -p /tmp/root/etc/periodic/${UPDATE_FREQUENCY}
RUN ln -s /srv/dbupdate.sh /tmp/root/etc/periodic/${UPDATE_FREQUENCY}/dbupdate
RUN tar c /etc/ssl /etc/ssl1.1 /usr/lib/engines-1.1 | tar xC /tmp/root

# enable for debugging:
# RUN $PKG_INSTALL mysql-client mariadb-connector-c

FROM mwaeckerlin/cron
COPY --from=build /tmp/root /
