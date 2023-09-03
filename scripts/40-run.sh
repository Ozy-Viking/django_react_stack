#!/bin/sh

set -xe

service gunicorn start
nginx -g 'daemon off;'
