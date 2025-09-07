FROM alpine:latest

# Install all necessary packages
RUN apk add --no-cache bind cronie

# Download initial blocklists
RUN chown -R named:named /etc/bind /var/bind && \
    chmod -R 750 /etc/bind /var/bind

# Download initial blocklists with error checking
RUN curl -s -o /var/bind/oisd.rpz https://big.oisd.nl/rpz || { echo "Failed to download oisd.rpz"; exit 1; } && \
    curl -s -o /var/bind/hagezi.pro.plus.rpz https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@main/rpz/pro.plus.txt || { echo "Failed to download hagezi.pro.plus.rpz"; exit 1; } && \
    curl -s -o /var/bind/hagezi.tif.rpz https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@main/rpz/tif.txt || { echo "Failed to download hagezi.tif.rpz"; exit 1; }

# Setup cron jobs
RUN echo "0 * * * * curl --retry 7 -fs -o /var/bind/oisd.rpz.tmp https://big.oisd.nl/rpz && named-checkzone oisd.rpz /var/bind/oisd.rpz.tmp && mv /var/bind/oisd.rpz.tmp /var/bind/oisd.rpz && rndc sync oisd.rpz" >> /etc/crontabs/root && \
    echo "0 0 * * * curl --retry 7 -fs -o /var/bind/hagezi.pro.plus.rpz.tmp https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@main/rpz/pro.plus.txt && named-checkzone hagezi.pro.plus.rpz /var/bind/hagezi.pro.plus.rpz.tmp && mv /var/bind/hagezi.pro.plus.rpz.tmp /var/bind/hagezi.pro.plus.rpz && rndc sync hagezi.pro.plus.rpz \
    curl --retry 7 -fs -o /var/bind/hagezi.tif.rpz.tmp https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@main/rpz/tif.txt && named-checkzone hagezi.tif.rpz /var/bind/hagezi.tif.rpz.tmp && mv /var/bind/hagezi.tif.rpz.tmp /var/bind/hagezi.tif.rpz && rndc sync hagezi.tif" >> /etc/crontabs/root

EXPOSE 53/udp 53/tcp

CMD ["/bin/sh", "-c", "if [ ! -f /etc/bind/rndc.key ]; then rndc-confgen -a -u named; fi; crond && exec /usr/sbin/named -c /etc/bind/named.conf -f -g -u named"]