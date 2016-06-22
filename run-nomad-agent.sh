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

tee /etc/nomad.d/server.hcl <<-EOF
name = "$NODENAME"
data_dir = "/var/lib/nomad"
bind_addr = "$BIND_ADDRESS"
client {
    enabled = true
    servers = ["nomad.service.consul:4647"]
    network_interface = "eth1"
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

tee /etc/profile.d/nomad.sh <<-EOF
export NOMAD_ADDR=http://$BIND_ADDRESS:4646
EOF
