FROM debian:bookworm
RUN apt-get -q update &&   \
	apt-get -y upgrade &&  \
	apt-get -y install     \
        apache2            \
        git                \
        make               \
        tar                \
        php-sqlite3        \
        php-mysql          \
        curl               \
        composer           \
        php-curl           \
        php-intl           \
        libapache2-mod-php \
        sqlite3            \
        php                \
        gzip               \
        php8.2-xml         \
        && rm -rf /var/lib/apt/lists/*

RUN a2enmod ssl headers

# Output to stderr/stdout for better handling in a container environment
RUN sed -i 's#ErrorLog ${APACHE_LOG_DIR}/error.log#ErrorLog /dev/stderr#g' /etc/apache2/apache2.conf
RUN echo 'TransferLog /dev/stdout'  >> /etc/apache2/apache2.conf

RUN a2dissite 000-default
#RUN a2disconf other-vhosts-access-log
RUN echo "Listen 443" > /etc/apache2/ports.conf
COPY geteduroam.conf /etc/apache2/sites-available/geteduroam.conf
RUN a2ensite geteduroam

RUN git clone https://github.com/geteduroam/letswifi-portal.git
COPY *.patch /letswifi-portal/
COPY *.png /letswifi-portal/www/assets/mac/
COPY sunet.css /letswifi-portal/www/assets/
WORKDIR /letswifi-portal
RUN git checkout 661792f9558119bdb87a981bc31478b03a841048
RUN git apply *.patch
RUN composer install && make SIMPLESAMLPHP_VERSION=2.3.7 simplesamlphp

WORKDIR /var/www/
RUN rm html/index.html && mv /letswifi-portal/www/* html/ && rm -r /letswifi-portal/www/ && mv /letswifi-portal/* . && rm -r /letswifi-portal


WORKDIR /

COPY start.sh /start.sh

ENTRYPOINT ["/start.sh"]
