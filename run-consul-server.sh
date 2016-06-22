#!/bin/sh

NODENAME=$1
BIND_ADDRESS=$2
JOIN=$3

echo $NODENAME
echo $BIND_ADDRESS
echo $JOIN

mkdir -p /etc/consul.d
chmod a+w /etc/consul.d
mkdir -p /var/lib/consul

cat <<EOF > /etc/consul.d/agent.json
{
	"ports": {
		"dns": 53
	},
	"recursor": "8.8.8.8"
}
EOF

EXPECT_COUNT=1
OPTIONS="-server -bootstrap-expect $EXPECT_COUNT -data-dir /var/lib/consul -node=$NODENAME -dc=local -bind=$BIND_ADDRESS"

# create defautl config
tee /etc/sysconfig/consul <<- EOF
GOMAXPROCS=2
OPTIONS=$OPTIONS
EOF

tee /etc/systemd/system/consul.service <<- EOF
[Unit]
Description=consul agent
Requires=network-online.target
After=network-online.target

[Service]
EnvironmentFile=-/etc/sysconfig/consul
Environment=GOMAXPROCS=2
Restart=on-failure
ExecStart=/usr/local/bin/consul agent \$OPTIONS  -config-dir /etc/consul.d
ExecReload=/bin/kill -HUP \$MAINPID
KillSignal=SIGINT

[Install]
WantedBy=multi-user.target

EOF

systemctl daemon-reload
systemctl enable consul
systemctl start consul

