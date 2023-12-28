#!/bin/sh -e

ln -fs /usr/share/zoneinfo/America/Detroit /etc/localtime
dpkg-reconfigure -f noninteractive tzdata
export TZ
