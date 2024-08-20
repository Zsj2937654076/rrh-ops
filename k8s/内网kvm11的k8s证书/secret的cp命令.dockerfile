kubectl create secret tls hcs55tls --cert=/etc/letsencrypt/live/hcs55.com/fullchain.pem --key=/etc/letsencrypt/live/hcs55.com/privkey.pem

kubectl create secret tls tlshcs55 --cert=/etc/letsencrypt/live/hcs55.com/fullchain.pem --key=/etc/letsencrypt/live/hcs55.com/privkey.pem -n nginx-ingress --dry-run=client -o yaml | kubectl apply -f -

/etc/nginx/conf.d/xbroker-xbroker-ingress.conf

kubectl cp /etc/kubernetes/xbroker-xbroker-ingress.conf nginx-ingress-7c7d655bd5-zzlpv:/etc/nginx/conf.d/xbroker-xbroker-ingress.conf



kubectl cp /etc/letsencrypt/archive/hcs55.com-0002/fullchain1.pem    nginx-ingress-7c7d655bd5-zzlpv:/etc/letsencrypt/




644

chmod 644 fullchain1.pem