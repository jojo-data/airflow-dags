# Get full list of base image from https://hub.docker.com/r/apache/airflow
FROM apache/airflow:2.1.2-python3.8

USER root

ARG AIRFLOW_HOME=/opt/airflow
ARG DOCKERIZE_VERSION=v0.6.1
ARG uid=airflow
ARG gid=root

# JQ Config
ENV JQ_VERSION='1.6'

# Install wget gpg
RUN  apt-get update \
  && apt-get install -y wget gpg \
  && rm -rf /var/lib/apt/lists/*

# Install JQ(https://github.com/stedolan/jq) - command-line JSON processor
RUN wget --no-check-certificate https://raw.githubusercontent.com/stedolan/jq/master/sig/jq-release.key -O /tmp/jq-release.key && \
    wget --no-check-certificate https://raw.githubusercontent.com/stedolan/jq/master/sig/v${JQ_VERSION}/jq-linux64.asc -O /tmp/jq-linux64.asc && \
    wget --no-check-certificate https://github.com/stedolan/jq/releases/download/jq-${JQ_VERSION}/jq-linux64 -O /tmp/jq-linux64 && \
    gpg --import /tmp/jq-release.key && \
    gpg --verify /tmp/jq-linux64.asc /tmp/jq-linux64 && \
    cp /tmp/jq-linux64 /usr/bin/jq && \
    chmod +x /usr/bin/jq && \
    rm -f /tmp/jq-release.key && \
    rm -f /tmp/jq-linux64.asc && \
    rm -f /tmp/jq-linux64

# Install dockerize(https://github.com/jwilder/dockerize) - Utility to simplify running applications in docker containers
RUN wget --no-check-certificate https://github.com/jwilder/dockerize/releases/download/${DOCKERIZE_VERSION}/dockerize-linux-amd64-${DOCKERIZE_VERSION}.tar.gz && \
    tar -C /usr/local/bin -xzvf dockerize-linux-amd64-${DOCKERIZE_VERSION}.tar.gz && \
    rm dockerize-linux-amd64-${DOCKERIZE_VERSION}.tar.gz

# Copy airflow config and entrypoint.sh
COPY --chown=${uid}:${gid}  docker-dependencies/airflow-image-files/ ${AIRFLOW_HOME}/
RUN chmod 755 ${AIRFLOW_HOME}/entrypoint.sh

USER ${uid}

# Install airflow and other needed python dependencies
COPY ./requirements.txt ${AIRFLOW_HOME}/requirements.txt
RUN pip install --upgrade pip
RUN pip install -r ${AIRFLOW_HOME}/requirements.txt

# create directories for airflow assets
RUN mkdir -p ${AIRFLOW_HOME}/plugins ${AIRFLOW_HOME}/variables ${AIRFLOW_HOME}/connections ${AIRFLOW_HOME}/tests && \
    mkdir -p ${AIRFLOW_HOME}/plugins/operators ${AIRFLOW_HOME}/plugins/hooks ${AIRFLOW_HOME}/plugins/utils

WORKDIR ${AIRFLOW_HOME}

ENTRYPOINT ["./entrypoint.sh"]