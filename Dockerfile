FROM ubuntu:14.04
MAINTAINER David Pelaez <david@vlipco.co>

# install dependencies
RUN apt-get update && apt-get -y install git build-essential zlib1g-dev libpcre3 libpcre3-dev curl

#Download and install nginx, ngx_pagespeed and psol, then file structure & shoreman
RUN export NPS_VERSION=1.8.31.4 && export NGINX=nginx-1.6.1 && \
	cd /tmp && curl -Ls "https://github.com/pagespeed/ngx_pagespeed/archive/release-${NPS_VERSION}-beta.tar.gz" | tar -xzo && \
 	curl -Ls "https://dl.google.com/dl/page-speed/psol/$NPS_VERSION.tar.gz" \
	| tar -xzo -C ngx_pagespeed-release-${NPS_VERSION}-beta && \
 	curl -Ls "http://nginx.org/download/$NGINX.tar.gz" \
	| tar -xzo && \
 	cd $NGINX && ./configure --add-module=/tmp/ngx_pagespeed-release-${NPS_VERSION}-beta && \
 	make && make install && apt-get clean all && \
 	mkdir -p /nginx/logs && touch /nginx/logs/error /nginx/logs/access && cd /usr/local/bin && \
	curl -Ls https://github.com/davidpelaez/shoreman/raw/dpt-additions/shoreman.sh > shoreman && \
	chmod +rx /usr/local/bin/shoreman

# verify gpg and sha256: http://nodejs.org/dist/v0.10.31/SHASUMS256.txt.asc
# gpg: aka "Timothy J Fontaine (Work) <tj.fontaine@joyent.com>"

RUN gpg --keyserver pgp.mit.edu --recv-keys 7937DFD2AB06298B2293C3187D33FF9D0246406D

ENV NODE_VERSION 0.10.33
ENV NPM_VERSION 2.1.6

RUN curl -SLO "http://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.gz" \
  && curl -SLO "http://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" \
  && gpg --verify SHASUMS256.txt.asc \
  && grep " node-v$NODE_VERSION-linux-x64.tar.gz\$" SHASUMS256.txt.asc | sha256sum -c - \
  && tar -xzf "node-v$NODE_VERSION-linux-x64.tar.gz" -C /usr/local --strip-components=1 \
  && rm "node-v$NODE_VERSION-linux-x64.tar.gz" SHASUMS256.txt.asc \
  && npm install -g npm@"$NPM_VERSION" && npm install -g broccoli-cli node-sass bower \
  && npm cache clear

WORKDIR /app
EXPOSE 5000
ADD conf /nginx/conf
COPY bin /nginx/bin

ONBUILD COPY package.json /app/
ONBUILD RUN npm install
ONBUILD COPY . /app

CMD ["/nginx/bin/init"]