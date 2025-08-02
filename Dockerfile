FROM alpine:latest

# Install all necessary packages
RUN apk add --no-cache bind bind-tools wget cronie

# Download initial blocklists
RUN wget -qO /etc/bind/oisd.rpz https://big.oisd.nl/rpz && \
    wget -qO /etc/bind/hagezi.pro.plus.rpz https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@main/rpz/pro.plus.txt && \
    wget -qO /etc/bind/hagezi.tif.rpz https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@main/rpz/tif.txt

COPY named.conf /etc/bind/named.conf

# Generate rndc key and auto-configure named.conf
RUN rndc-confgen -a

# Setup cron jobs
RUN echo "0 * * * * wget -qO /etc/bind/oisd.rpz https://big.oisd.nl/rpz && rndc reload oisd.rpz" >> /etc/crontabs/root && \
    echo "0 0 * * * wget -qO /etc/bind/hagezi.pro.plus.rpz https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@main/rpz/pro.plus.txt && wget -qO /etc/bind/hagezi.tif.rpz https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@main/rpz/tif.txt && rndc reload hagezi.pro.plus.rpz && rndc reload hagezi.tif.rpz" >> /etc/crontabs/root

CMD ["/usr/sbin/named", "-c", "/etc/bind/named.conf", "-f", "-g"]