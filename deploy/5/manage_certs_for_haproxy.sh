#!/bin/bash
openssl req -x509 -nodes -days 365   -newkey rsa:2048   -keyout dashboard.key   -out dashboard.crt   -subj "/CN=dashboard.local"
cat dashboard.crt dashboard.key > dashboard.pem
sudo cp dashboard.pem /etc/haproxy/dashboard.pem

