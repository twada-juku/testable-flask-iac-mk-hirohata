#
# Gunicorn config file
#
import os

def _env_or_die(key):
    if key not in os.environ:
        raise KeyError(f'No {key} environment variable')
    return os.environ[key]

wsgi_app = 'stacks:create_app()'

# Server Socket
#========================================
bind = f'0.0.0.0:{_env_or_die("PORT")}'

# Worker Processes
#========================================
workers = 1

worker_class = 'gthread'

threads = 8

timeout = 0

# TODO: capture_output
# TODO: errorlog
