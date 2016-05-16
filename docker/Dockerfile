FROM mwaeckerlin/owncloud
MAINTAINER mwaeckerlin

RUN apt-get install -y wget software-properties-common apt-transport-https
RUN apt-add-repository https://dev.marc.waeckerlin.org/repository
RUN wget -O- https://dev.marc.waeckerlin.org/repository/PublicKey \
      | apt-key add -
RUN apt-get update -y
RUN apt-get install -y ggrwinti
