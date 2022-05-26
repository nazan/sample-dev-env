FROM nginx:1.19

RUN mkdir -p /usr/src/aidock/build

RUN touch /var/log/nginx/app-error.log
RUN touch /var/log/nginx/app-access.log

RUN chown -R :www-data /usr/src/aidock/build && \
    chmod -R g=r /usr/src/aidock/build && \
    find /usr/src/aidock/build -type d | xargs chmod g+x && \
    chown -R :www-data /var/log/nginx && \
    chmod -R g=r /var/log/nginx && \
    find /var/log/nginx -type d | xargs chmod g+x && \
    find /var/log/nginx -type f | xargs chmod g+w

WORKDIR /var/www/html