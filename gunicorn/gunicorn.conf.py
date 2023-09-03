bind = ["127.0.0.1:8000"]
workers = 4
daemon = True
pidfile = "/var/run/gunicorn.pid"
errorlog = "/var/log/gunicorn.log"
loglevel = "info"
capture_output = True
accesslog = "-"
