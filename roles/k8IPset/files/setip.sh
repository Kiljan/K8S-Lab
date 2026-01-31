#!/bin/bash
set -e

for mod in ip_vs ip_vs_rr ip_vs_wrr ip_vs_sh br_netfilter ip_tables nf_nat; do
    if lsmod | grep -q "^$mod"; then
        echo "Mod $mod loaded"
    else
        if modinfo $mod &>/dev/null; then
            echo "Loading module $mod"
            modprobe $mod
        else
            echo "Mod $mod dosent exist, skip"
        fi
    fi
done

cat <<EOF | sudo tee /etc/sysctl.d/99-k8s.conf > /dev/null
net.ipv4.conf.all.rp_filter=0
net.ipv4.conf.default.rp_filter=0
net.ipv4.conf.enp1s0.rp_filter=0
net.ipv4.conf.tunl0.rp_filter=0
net.ipv4.ip_forward = 1
EOF

sysctl --system

iptables -P FORWARD ACCEPT || echo "Nie udało się ustawić FORWARD, sprawdź iptables"

# Calico IPIP (bird) additional settings
firewall-cmd --permanent --add-rich-rule="rule protocol value='4' accept"


# NAT for forwarding
firewall-cmd --permanent --add-masquerade

# Add interfaces to a tunnel
firewall-cmd --permanent --add-interface=tunl0
for i in $(ls /sys/class/net | grep cali); do
    firewall-cmd --permanent --add-interface=$i
done

# Some Tests
#firewall-cmd --permanent --remove-rich-rule="rule family='ipv4' source address='172.16.104.0/24' accept"
#firewall-cmd --permanent --remove-rich-rule="rule family='ipv4' destination address='172.16.104.0/24' accept"

firewall-cmd --reload

exit 0

