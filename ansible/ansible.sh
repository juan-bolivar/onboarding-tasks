#!/bin/bash

sudo apt-get update --force-yes
sudo apt-get upgrade --force-yes
sudo apt install software-properties-common -y
sudo apt-add-repository ppa:ansible/ansible
sudo apt-get install ansible -y
