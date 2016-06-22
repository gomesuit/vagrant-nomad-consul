#!/bin/sh

yum install -y docker-latest

systemctl enable docker-latest
systemctl start docker-latest
