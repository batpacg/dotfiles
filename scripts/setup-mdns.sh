#!/usr/bin/env bash

sudo pacman -S --needed --noconfirm nss-mdns

sudo cp /etc/nsswitch.conf /etc/nsswitch.conf.bak

rep="/^hosts:/c\hosts: mymachines mdns_minimal [NOTFOUND=return] resolve [!UNAVAIL=return] files myhostname dns"
sudo sed -i "$rep" /etc/nsswitch.conf
