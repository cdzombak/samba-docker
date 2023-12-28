#!/bin/sh -e

un="mysystemuser"
pass="mysmbpasswd"
(echo "$pass"; echo "$pass") | smbpasswd -s -a "$un"
