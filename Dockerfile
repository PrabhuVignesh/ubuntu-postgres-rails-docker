
FROM ubuntu:12.04
RUN apt-get update
RUN apt-get -y upgrade
RUN apt-get install -y byobu curl git htop man unzip vim wget 
RUN  apt-get install -y build-essential 
RUN apt-get install -y software-properties-common
RUN apt-get install -y openjdk-7-jdk
RUN apt-get install -y openjdk-7-jre
RUN apt-get install -y ruby1.9.3

ENV PG_APP_HOME="/etc/docker-postgresql"\
    PG_VERSION=9.4 \
    PG_USER=postgres \
    PG_HOME=/var/lib/postgresql \
    PG_RUNDIR=/run/postgresql \
    PG_LOGDIR=/var/log/postgresql \
    PG_CERTDIR=/etc/postgresql/certs

ENV PG_BINDIR=/usr/lib/postgresql/${PG_VERSION}/bin \
    PG_DATADIR=${PG_HOME}/${PG_VERSION}/main

RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
 && echo 'deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main' > /etc/apt/sources.list.d/pgdg.list \
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y acl \
      postgresql-${PG_VERSION} postgresql-client-${PG_VERSION} postgresql-contrib-${PG_VERSION} \
 && ln -sf ${PG_DATADIR}/postgresql.conf /etc/postgresql/${PG_VERSION}/main/postgresql.conf \
 && ln -sf ${PG_DATADIR}/pg_hba.conf /etc/postgresql/${PG_VERSION}/main/pg_hba.conf \
 && ln -sf ${PG_DATADIR}/pg_ident.conf /etc/postgresql/${PG_VERSION}/main/pg_ident.conf \
 && rm -rf ${PG_HOME} \
 && rm -rf /var/lib/apt/lists/*

COPY runtime/ ${PG_APP_HOME}/
COPY entrypoint.sh /sbin/entrypoint.sh
RUN chmod 755 /sbin/entrypoint.sh

EXPOSE 5432/tcp
VOLUME ["${PG_HOME}", "${PG_RUNDIR}"]
RUN apt-get install -y mysql-client mysql-server libmysql-ruby libmysqlclient-dev
RUN rm -rf /var/lib/apt/lists/*
RUN ls 
ADD root/.bashrc /root/.bashrc
ADD root/.scripts /root/.scripts
ENV JAVA_HOME /usr/lib/jvm/java-7-openjdk-amd64
ADD . home/myapp
RUN mkdir -p /app 
COPY . /app
WORKDIR /app
CMD ["bash"]