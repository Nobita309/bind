download_until_success() {
    url="$1"
    output="$2"
    while true; do
        curl -sL -o "$output" "$url" && break
        echo "Download failed. Retrying in 3 seconds..."
        sleep 3
    done
}

download_until_success "https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@main/rpz/pro.txt" "/var/bind/hagezi.pro.rpz.tmp" && \
named-checkzone hagezi.pro.rpz /var/bind/hagezi.pro.rpz.tmp && \
rndc freeze hagezi.pro.rpz && \
mv /var/bind/hagezi.pro.rpz.tmp /var/bind/hagezi.pro.rpz && \
rndc thaw hagezi.pro.rpz

download_until_success "https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@main/rpz/tif.txt" "/var/bind/hagezi.tif.rpz.tmp" && \
named-checkzone hagezi.tif.rpz /var/bind/hagezi.tif.rpz.tmp && \
rndc freeze hagezi.tif.rpz && \
mv /var/bind/hagezi.tif.rpz.tmp /var/bind/hagezi.tif.rpz && \
rndc thaw hagezi.tif.rpz