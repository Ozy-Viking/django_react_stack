#! /bin/bash
### BEGIN INIT INFO
# Provides:          gunicorn
# Required-Start:    nginx
# Required-Stop:     
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: The main django process
# Description:       The gunicorn process that receives HTTP requests
#                    from nginx
#
### END INIT INFO
#
# Author:       Zack Hankin <admin@hankin.io>
#
APPNAME=django_react_stack

if [ -e "/etc/default/gunicorn" ]
then
    . /etc/default/gunicorn
fi

export PROJECTPATH=/home/www-data/app
export USER=www-data
export APPMODULE=${APPNAME}.wsgi
export LOGFILE=/var/log/gunicorn.log
export PYTHONPATH=${PROJECTPATH}/.venv/bin

DESC=${DESC:-gunicorn}
NAME=${NAME:-gunicorn}
CONFFILE=${CONFFILE:-/etc/gunicorn/gunicorn.conf.py}
DAEMON=${DAEMON:-${PYTHONPATH}/gunicorn}
PIDFILE=${PIDFILE:-/var/run/gunicorn.pid}
SLEEPSEC=${SLEEPSEC:-1}
UPGRADEWAITLOOPS=${UPGRADEWAITLOOPS:-5}
CHECKSLEEP=${CHECKSLEEP:-3}

. /lib/lsb/init-functions
. /lib/init/vars.sh

DAEMON_ARGS="-c $CONFFILE --log-file $LOGFILE $APPMODULE --pythonpath $PYTHONPATH"

case "$1" in
  start)
        log_daemon_msg "Starting $NAME daemon" "$APPNAME"
        start-stop-daemon --start --quiet --chdir $PROJECTPATH --pidfile $PIDFILE --exec $DAEMON -- $DAEMON_ARGS
        log_end_msg $?
    ;;
  stop)
        log_daemon_msg "Stopping $NAME daemon" "$APPNAME"
        killproc -p $PIDFILE $DAEMON
        log_end_msg $?
    ;;
  force-reload|restart|reload)
    $0 stop
    $0 start
    ;;
  status)
    status_of_proc -p $PIDFILE "$DAEMON" "$NAME" && exit 0 || exit $?
    ;;
  *)
    echo "Usage: /etc/init.d/$APPNAME {start|stop|restart|reload|force-reload|status}" >&2
    exit 1
    ;;
esac
