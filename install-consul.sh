#!/bin/sh

yum install -y wget unzip
wget https://releases.hashicorp.com/consul/0.6.4/consul_0.6.4_linux_amd64.zip
unzip -o consul_0.6.4_linux_amd64.zip
cp -f consul /usr/local/bin/
