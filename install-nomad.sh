#!/bin/sh

yum install -y wget unzip
wget https://releases.hashicorp.com/nomad/0.3.2/nomad_0.3.2_linux_amd64.zip
unzip -o nomad_0.3.2_linux_amd64.zip
cp -f nomad /usr/local/bin/
