FROM ubuntu:14.04
MAINTAINER David Pelaez <david@vlipco.co>

# install dependencies
RUN apt-get update && apt-get -y install build-essential zlib1g-dev libpcre3 libpcre3-dev curl

ENV NPS_VERSION 1.8.31.4
ENV NGINX nginx-1.6.1

#Download and install nginx, ngx_pagespeed and psol, then file structure & shoreman
RUN cd /tmp && \
	curl -Ls "https://github.com/pagespeed/ngx_pagespeed/archive/release-${NPS_VERSION}-beta.tar.gz" \
	| tar xfz --no-same-permissions - && \
 	curl -Ls "https://dl.google.com/dl/page-speed/psol/$NPS_VERSION.tar.gz" \
	| tar xzf --no-same-permissions - -C ngx_pagespeed-release-${NPS_VERSION}-beta && \
 	curl -Ls "http://nginx.org/download/$NGINX.tar.gz" \
	| tar xzf --no-same-permissions - && \
 	cd $NGINX && ./configure --add-module=/tmp/ngx_pagespeed-release-${NPS_VERSION}-beta && \
 	make && make install && apt-get clean all && \
 	mkdir -p /nginx/logs && touch /nginx/logs/error /nginx/logs/access && cd /usr/local/bin && \
	curl -Ls https://github.com/davidpelaez/shoreman/raw/dpt-additions/shoreman.sh > shoreman && \
	chmod +rx /usr/local/bin/shoreman

WORKDIR /app
CMD ["/usr/local/bin/shoreman", "/nginx/conf/Procfile"]
ONBUILD ADD . /app
EXPOSE 5000
ADD conf /nginx/conf