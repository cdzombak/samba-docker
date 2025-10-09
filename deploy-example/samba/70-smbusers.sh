#!/bin/sh -e

usernm="mysystemuser"
pass="mysmbpasswd"
(echo "$pass"; echo "$pass") | smbpasswd -s -a "$usernm"
