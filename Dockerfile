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
RUN echo '0 * * * * curl -s -o /var/bind/oisd.rpz.tmp https://big.oisd.nl/rpz && named-checkzone oisd.rpz /var/bind/oisd.rpz.tmp && ( echo -e "zone oisd.rpz\nupdate delete *\nsend" | nsupdate -l && grep -v "^;" /var/bind/oisd.rpz.tmp | nsupdate -l)' >> /etc/crontabs/root && \
    echo '0 0 * * * curl -s -o /var/bind/hagezi.pro.plus.rpz.tmp https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@main/rpz/pro.plus.txt && named-checkzone hagezi.pro.plus.rpz /var/bind/hagezi.pro.plus.rpz.tmp && ( echo -e "zone hagezi.pro.plus.rpz\nupdate delete *\nsend" | nsupdate -l && grep -v "^;" /var/bind/hagezi.pro.plus.rpz.tmp | nsupdate -l) && \
    curl -s -o /var/bind/hagezi.tif.rpz.tmp https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@main/rpz/tif.txt && named-checkzone hagezi.tif.rpz /var/bind/hagezi.tif.rpz.tmp && ( echo -e "zone hagezi.tif.rpz\nupdate delete *\nsend" | nsupdate -l && grep -v "^;" /var/bind/hagezi.tif.rpz.tmp | nsupdate -l)' >> /etc/crontabs/root

EXPOSE 53/udp 53/tcp

CMD ["/bin/sh", "-c", "crond && /usr/sbin/named -c /etc/bind/named.conf -f -g -u named"]