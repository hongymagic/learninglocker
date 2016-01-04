FROM php:5.6-apache
MAINTAINER David Hong <david.hong@peopleplan.com.au>

# Enable Apache rewrite and expires mods
RUN a2enmod rewrite expires

# Update and install system/php packages
RUN apt-get update
RUN DEBIAN_FRONTEND=noninterative apt-get install -yq \
		curl \
		git \
		libmcrypt-dev \
		libssl-dev \
		libpng12-dev \
		zlib1g-dev \
		libjpeg-dev && \
	rm -rf /var/lib/apt/lists/*

# Install the PHP extensions we need
RUN docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr
RUN docker-php-ext-install gd opcache zip mcrypt mbstring

# Install PHP pecl mongo
COPY bin/* /usr/local/bin/
RUN docker-php-pecl-install mongo

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Set recommended PHP.ini settings
# See https://secure.php.net/manual/en/opcache.installation.php
RUN { \
		echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
		echo 'opcache.revalidate_freq=60'; \
		echo 'opcache.fast_shutdown=1'; \
		echo 'opcache.enable_cli=1'; \
	} > /usr/local/etc/php/conf.d/opcache-recommended.ini


# Download and install Learning Locker
# Upstream tarballs include ./learninglocker-v1.11.0/ so this gives us /var/www/html
RUN mkdir -p /var/www/html
RUN curl -o learninglocker.tar.gz -SL https://github.com/LearningLocker/learninglocker/archive/v1.11.0.tar.gz \
	&& tar -xzf learninglocker.tar.gz -C /var/www/html --strip-components=1 \
	&& rm learninglocker.tar.gz \
	&& chown -R www-data:www-data /var/www/html
RUN composer install

# Setup apache to point to public/ under learning locker dir
RUN sed -i "s/^DocumentRoot.*/DocumentRoot \'\/var\/www\/html\/public\/\'/g" /etc/apache2/apache2.conf

COPY docker-entrypoint.sh /entrypoint.sh

# grr, ENTRYPOINT resets CMD now
EXPOSE 80
ENTRYPOINT ["/entrypoint.sh"]
CMD ["apache2-foreground"]
