FROM ubuntu:14.04
MAINTAINER David Pelaez <david@vlipco.co>

# install dependencies
RUN apt-get update && apt-get -y install build-essential zlib1g-dev libpcre3 libpcre3-dev curl

ENV NPS_VERSION 1.8.31.4
ENV NGINX nginx-1.6.1

#Download and install nginx, ngx_pagespeed and psol.
RUN cd /tmp && \
	curl -Ls "https://github.com/pagespeed/ngx_pagespeed/archive/release-${NPS_VERSION}-beta.tar.gz" \
	| tar xfz - && \
 	curl -Ls "https://dl.google.com/dl/page-speed/psol/$NPS_VERSION.tar.gz" \
	| tar xzf - -C ngx_pagespeed-release-${NPS_VERSION}-beta && \
 	curl -Ls "http://nginx.org/download/$NGINX.tar.gz" \
	| tar xzf - && \
 	cd $NGINX && ./configure --add-module=/tmp/ngx_pagespeed-release-${NPS_VERSION}-beta && \
 	make && make install && apt-get clean all

# install shoreman
RUN cd /usr/local/bin && curl -Ls https://github.com/davidpelaez/shoreman/raw/dpt-additions/shoreman.sh > shoreman && chmod +rx /usr/local/bin/shoreman

# file structure
ADD conf /nginx/conf
RUN mkdir -p /nginx/logs && touch /nginx/logs/error /nginx/logs/access 

ONBUILD ADD . /app

WORKDIR /app
EXPOSE 5000
CMD ["/usr/local/bin/shoreman", "/nginx/conf/Procfile"]