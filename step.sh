#!/bin/bash
set -eu

case "$OSTYPE" in
  linux*)
    echo "Configuring for Ubuntu"

    echo ${client_config} | base64 -d > /etc/openvpn/client.ovpn
    echo ${username} | base64 -d > /etc/openvpn/auth.txt
    echo ${password} | base64 -d >> /etc/openvpn/auth.txt

    sed -i '.bak' 's/auth-user-pass/auth-user-pass auth.txt/' /etc/openvpn/client.ovpn
    service openvpn start client > /dev/null 2>&1
    sleep 10

    if ifconfig | grep tun0 > /dev/null
    then
      echo "VPN connection succeeded"
    else
      echo "VPN connection failed!"
      exit 1
    fi
    ;;
  darwin*)
    echo "Configuring for Mac OS"

    echo ${client_config} | base64 -D -o client.ovpn > /dev/null 2>&1
    echo ${username} | base64 -D > auth.txt
    echo ${password} | base64 -D >> auth.txt

    sed -i '.bak' 's/auth-user-pass/auth-user-pass auth.txt/' client.ovpn
    sudo openvpn --config client.opvn > /dev/null 2>&1 &
    sleep 10

    if ifconfig -l | grep utun0 > /dev/null
    then
      echo "VPN connection succeeded"
    else
      echo "VPN connection failed!"
      exit 1
    fi
    ;;
  *)
    echo "Unknown operative system: $OSTYPE, exiting"
    exit 1
    ;;
esac
