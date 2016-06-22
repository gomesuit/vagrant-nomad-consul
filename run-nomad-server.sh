#!/bin/sh

NODENAME=$1
BIND_ADDRESS=$2
JOIN=$3

echo $NODENAME
echo $BIND_ADDRESS
echo $JOIN

mkdir -p /etc/nomad.d
chmod a+w /etc/nomad.d
mkdir -p /var/lib/nomad

tee /etc/consul.d/nomad.json <<-EOF
{
  "service": {
    "name": "nomad",
    "address": "$BIND_ADDRESS",
    "port": 4647,
    "checks": [
      {
        "tcp": "$BIND_ADDRESS:4647",
        "interval": "10s"
      }
    ]
  }
}
EOF

consul reload

tee /etc/nomad.d/server.hcl <<-EOF
name = "$NODENAME"
data_dir = "/var/lib/nomad"
bind_addr = "$BIND_ADDRESS"

server {
    enabled = true
    bootstrap_expect = 1
}
EOF

tee /etc/sysconfig/nomad <<-EOF
EOF

tee /etc/systemd/system/nomad.service <<-EOF
[Unit]
Description=nomad agent
Requires=network-online.target
After=network-online.target

[Service]
EnvironmentFile=-/etc/sysconfig/nomad
Environment=GOMAXPROCS=2
Restart=on-failure
ExecStart=/usr/local/bin/nomad agent -config /etc/nomad.d
ExecReload=/bin/kill -HUP \$MAINPID
KillSignal=SIGINT

[Install]
WantedBy=multi-user.target

EOF

systemctl daemon-reload
systemctl enable nomad
systemctl start nomad

tee /etc/profile.d/nomad.sh <<- EOF
export NOMAD_ADDR=http://$BIND_ADDRESS:4646
EOF
