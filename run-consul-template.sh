#!/bin/sh

mkdir -p /etc/consul-template/
chmod a+w /etc/consul-template/

tee /etc/consul-template/generate-front-nginx.conf <<-EOF
consul = "127.0.0.1:8500"
retry = "5s"
max_stale = "10m"
log_level = "info"
pid_file = "/var/run/consul-template.pid"
template {
  source = "/etc/consul-template/virtualhosts.tmpl"
  destination = "/etc/nginx/conf.d/virtualhosts.conf"
  command = "systemctl reload nginx"
}
EOF

tee /etc/consul-template/virtualhosts.tmpl <<-EOF
{{ range \$index , \$service := services }}
{{ if in \$service.Tags "nomad-worker" }}
upstream {{\$service.Name}} {
  {{ range service \$service.Name }}
    server {{.Address}}:{{.Port}};
  {{ end }}
}
server {
        include /etc/nginx/proxy.conf;
        server_name {{\$service.Name}}.__YOUR_DOMAIN_NAME__;
        location / {
                proxy_pass http://{{\$service.Name}};
        }
}
{{ end }}
{{ end }}
EOF

tee /etc/systemd/system/consul-template.service <<-EOF
[Unit]
Description=consul-template
Requires=network-online.target
After=network-online.target

[Service]
Restart=on-failure
ExecStart=/usr/local/bin/consul-template -config=/etc/consul-template/generate-front-nginx.conf
ExecReload=/bin/kill -HUP \$MAINPID
KillSignal=SIGINT

[Install]
WantedBy=multi-user.target

EOF

systemctl daemon-reload
systemctl enable consul-template
systemctl start consul-template
