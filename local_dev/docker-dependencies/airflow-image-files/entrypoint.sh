#!/bin/bash

# Redis - task queue broker
export REDIS_HOST="172.18.0.3"
export REDIS_PORT="6379"
# Postgres - metadata store
export POSTGRES_DB="airflow"
export POSTGRES_USER="postgres"
export POSTGRES_HOST="172.18.0.2"
export POSTGRES_PORT="5432"
export POSTGRES_PASSWORD="airflow"
# Error email from
export AIRFLOW_SMTP_MAIL_FROM="email_address@domain_name.com"
# Secrets - base 64 encoded
export SECRET_KEY="YWlyZmxvd2FpcmZsb3dhaXJmbG93"
export AIRFLOW_HOME=/opt/airflow

# Dockerize template into config (replace all template variables with real values)
# Dockerrize uses {{:}} for template variables by default, but airflow.cfg also uses {{ and }}
# within its config file, hence change to <%:%>
dockerize -delims "<%:%>" -template ${AIRFLOW_HOME}/airflow.cfg.tmpl:${AIRFLOW_HOME}/airflow.cfg

# Initialize db when running as web server
if [ "$1" = "webserver" ]; then
    # init postgres
    airflow db init
    # airflow 2.0 requires a created admin user, we set both username and password to airflow
    airflow users create --username airflow --password airflow --firstname Airflow --lastname Local --role Admin --email ${AIRFLOW_SMTP_MAIL_FROM}
    # start airflow process
    exec airflow "$@"
elif [ "$1" = "scheduler" ]; then
    exec airflow "$@"
elif [ "$1" = "worker" ]; then
    exec airflow celery "$@"
elif [ "$1" = "flower" ]; then
    exec airflow celery "$@"
fi