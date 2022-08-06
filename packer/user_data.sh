#!/bin/bash
sed 's/PasswordAuthentication no/PasswordAuthentication yes/' -i /etc/ssh/sshd_config
systemctl restart sshd
service sshd restart
echo 'ubuntu:temp-password' | chpasswd
