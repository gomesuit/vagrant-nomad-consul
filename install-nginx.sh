#!/bin/sh

NODENAME=$1
echo $NODENAME

yum install -y epel-release
yum install -y nginx

systemctl enable nginx
systemctl start nginx

echo $NODENAME > /usr/share/nginx/html/consul.html

tee /etc/nginx/nginx.conf <<-EOF
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;

events {
    worker_connections 1024;
}

http {
    log_format  main  '\$remote_addr - \$remote_user [\$time_local] "\$request" '
                      '\$status \$body_bytes_sent "\$http_referer" '
                      '"\$http_user_agent" "\$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile            on;
    tcp_nopush          on;
    tcp_nodelay         on;
    keepalive_timeout   65;
    types_hash_max_size 2048;

    include             /etc/nginx/mime.types;
    default_type        application/octet-stream;

    # Load modular configuration files from the /etc/nginx/conf.d directory.
    # See http://nginx.org/en/docs/ngx_core_module.html#include
    # for more information.
    include /etc/nginx/conf.d/*.conf;

    server {
        listen 80 default_server;
        listen [::]:80 default_server;
        server_name _;
        return 444;
    }
}
EOF

tee /etc/nginx/proxy.conf <<-EOF
listen       80;
listen       [::]:80;
proxy_set_header Host \$host;
satisfy any;
proxy_set_header X-Real-IP \$remote_addr;
proxy_set_header X-Forwarded-Proto \$scheme;
proxy_set_header X-Forwarded-Host \$http_host;
proxy_set_header X-Forwarded-Server \$host;
proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
EOF

