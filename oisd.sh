while true; do
    curl -sL -o /etc/bind/oisd.rpz.tmp https://rpz.oisd.nl/
    if [ $? -eq 0 ]; then
        echo "OISD download successful at $(date)"
        break
    else
        echo "OISD download failed, retrying in 3 seconds..."
        sleep 3
    fi
done

named-checkzone oisd.rpz /etc/bind/oisd.rpz.tmp && \
rndc freeze oisd.rpz && \
mv /etc/bind/oisd.rpz.tmp /etc/bind/oisd.rpz && \
rndc thaw oisd.rpz