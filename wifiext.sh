#!/bin/sh

# install dependencies
sudo apt install build-essential autoconf automake libtool pkg-config libnl-3-dev libnl-genl-3-dev libssl-dev ethtool shtool rfkill zlib1g-dev libpcap-dev libsqlite3-dev libpcre2-dev libhwloc-dev libcmocka-dev hostapd wpasupplicant tcpdump screen iw usbutils expect

# Shell script to set up drivers for Alfa AWUS036ACH
# You must have an internet connection.

# update your repositories
apt-get update

# install dkms if it isn't already
apt-get install dkms

# change directory to /usr/src
cd /usr/src

# if you have any other drivers installed,remove them like so:
rm -r rtl8812AU

# get latest driver from github
# used to be: git clone https://github.com/aircrack-ng/rtl8812au
git clone https://github.com/gordboy/rtl8812au.git

# move into downloaded driver folder
cd rtl8812au/

# update files in working tree to match files in the index 
# this step doesn't seem to be necessary anymore, commented out
# git checkout --track remotes/origin/v5.2.20

# make drivers
make

# move into parent directory
cd ..

# debugging
dkms status

# rename file for use with dkms
mv rtl8812au/ rtl8812au

# dkms add driver
dkms add -m rtl8812au 

# build drivers
dkms build -m rtl8812au 
install drivers
dkms install -m rtl8812au 

# debugging
lsmod

# summon new interface from the depths of the kernel
modprobe 8812au

# wifi interface should now appear.
ip link
