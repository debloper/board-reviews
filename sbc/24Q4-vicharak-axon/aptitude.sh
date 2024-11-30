#!/bin/bash

# apt upgrade packages
# 
# Out of the box, Axon comes with packages locked to specific versions.
# Following steps would let you to update the repo and upgrade packages.

mv /etc/apt/sources.list.d/vicharak.list /etc/apt/sources.list.d/vicharak.back
apt update
apt-mark unhold $(apt-mark showhold)
apt upgrade
