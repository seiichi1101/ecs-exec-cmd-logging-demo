FROM php:8.1-fpm-alpine
RUN apk add --no-cache \
    bash util-linux
