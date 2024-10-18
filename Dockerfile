FROM ubuntu:latest

RUN apt update -y

# Tools
RUN apt install -y git gnupg gosu curl ca-certificates zip unzip git
RUN apt install -y supervisor sqlite3 libcap2-bin libpng-dev python3 
RUN apt install -y dnsutils librsvg2-bin fswatch ffmpeg nano iputils-ping wget

# PHP
RUN apt install -y python3-launchpadlib software-properties-common
RUN LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php
RUN apt update -y
RUN apt install -y php8.4-cli php8.4-fpm php8.4-dev \
                   php8.4-pgsql php8.4-sqlite3 php8.4-mysql \
                   php8.4-curl php8.4-gd php8.4-mbstring php8.4-xml php8.4-zip php8.4-bcmath  \
                   php8.4-intl php8.4-redis php8.4-memcached php8.4-xdebug
RUN wget http://pear.php.net/go-pear.phar
RUN php go-pear.phar -y

COPY php/php.ini /etc/php/8.4/cli/php.ini
COPY php/xdebug.ini /etc/php/8.4/cli/conf.d/20-xdebug.ini

# Webserver
RUN apt install -y nginx
RUN rm /etc/nginx/sites-enabled/default
COPY nginx/laravel.conf /etc/nginx/sites-enabled/default.conf

# Forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
	&& ln -sf /dev/stderr /var/log/nginx/error.log \
	&& ln -sf /dev/stderr /var/log/php8.4-fpm.log

# 
RUN mkdir -p /var/www/html
WORKDIR /var/www/html

# run config
RUN mkdir -p /etc/supervisor/conf.d
RUN mkdir -p /var/log/supervisor
ADD supervisord.conf /etc/supervisor/
CMD /usr/bin/supervisord