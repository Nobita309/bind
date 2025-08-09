FROM alpine:latest

# Install all necessary packages
RUN apk add --no-cache bind wget cronie

# Download initial blocklists
RUN wget -qO /etc/bind/oisd.rpz https://big.oisd.nl/rpz && \
    wget -qO /etc/bind/hagezi.pro.plus.rpz https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@main/rpz/pro.plus.txt && \
    wget -qO /etc/bind/hagezi.tif.rpz https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@main/rpz/tif.txt

COPY named.conf /etc/bind/named.conf

# Create bind directory and set permissions for user 'named'
RUN chown -R named:named /etc/bind /var/bind

# Setup cron jobs
RUN echo "0 * * * * wget -qO /etc/bind/oisd.rpz https://big.oisd.nl/rpz && rndc reload oisd.rpz" >> /etc/crontabs/root && \
    echo "0 0 * * * wget -qO /etc/bind/hagezi.pro.plus.rpz https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@main/rpz/pro.plus.txt && wget -qO /etc/bind/hagezi.tif.rpz https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@main/rpz/tif.txt && rndc reload hagezi.pro.plus.rpz && rndc reload hagezi.tif.rpz" >> /etc/crontabs/root

EXPOSE 53/udp 53/tcp

# Generate rndc key and auto-configure named.conf
RUN rndc-confgen -a

# Create bind directory and set permissions for user 'named'
RUN chown -R named:named /etc/bind /var/bind

# Setup cron jobs
RUN echo "0 * * * * wget -qO /etc/bind/oisd.rpz https://big.oisd.nl/rpz && rndc reload oisd.rpz" >> /etc/crontabs/root && \
    echo "0 0 * * * wget -qO /etc/bind/hagezi.pro.plus.rpz https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@main/rpz/pro.plus.txt && wget -qO /etc/bind/hagezi.tif.rpz https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@main/rpz/tif.txt && rndc reload hagezi.pro.plus.rpz && rndc reload hagezi.tif.rpz" >> /etc/crontabs/root

CMD ["/usr/sbin/named", "-c", "/etc/bind/named.conf", "-f", "-g", "-u", "named"]