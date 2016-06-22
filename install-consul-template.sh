#!/bin/sh

yum install -y wget unzip
wget https://releases.hashicorp.com/consul-template/0.15.0/consul-template_0.15.0_linux_amd64.zip
unzip -o consul-template_0.15.0_linux_amd64.zip
cp -f consul-template /usr/local/bin/


cat <<EOF > /root/hosts-node.ctmpl
# consul nodes{{range nodes}}
{{.Address}}    {{.Node}}{{end}}
EOF
