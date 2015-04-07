#!/bin/sh -e

exec /sbin/setuser logshipper /usr/sbin/logshipper -n /var/run/logshipper >> /var/log/logshipper.log 2>&1
