FROM alpine:latest

# Install all necessary packages
RUN apk add --no-cache bind cronie

# Download initial blocklists
RUN chown -R named:named /etc/bind /var/bind && \
    chmod 777 /etc/bind /var/bind

# Download initial blocklists with error checking
RUN curl -s -o /var/bind/oisd.rpz https://big.oisd.nl/rpz || { echo "Failed to download oisd.rpz"; exit 1; } && \
    curl -s -o /var/bind/hagezi.pro.rpz https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@main/rpz/pro.txt || { echo "Failed to download hagezi.pro.plus.rpz"; exit 1; } && \
    curl -s -o /var/bind/hagezi.tif.rpz https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@main/rpz/tif.txt || { echo "Failed to download hagezi.tif.rpz"; exit 1; }

# Setup cron jobs
COPY oisd.sh /var/bind/oisd.sh
COPY hagezi.sh /var/bind/hagezi.sh

RUN chmod +x /var/bind/oisd.sh /var/bind/hagezi.sh

RUN echo "0 */1 * * * /var/bind/oisd.sh" >> /etc/crontabs/root && \
    echo "0 0 * * * /var/bind/hagezi.sh" >> /etc/crontabs/root

EXPOSE 53/udp 53/tcp

CMD ["/bin/sh", "-c", "if [ ! -f /etc/bind/rndc.key ]; then rndc-confgen -a -u named; fi; crond && exec /usr/sbin/named -c /etc/bind/named.conf -f -g -u named"]