#!/bin/bash

# Any subsequent commands which fail will cause the shell script to exit immediately
set -e

airflow_webserver=$(docker ps -aqf "name=airflow_webserver")
airflow_postgres=$(docker ps -aqf "name=airflow_postgres")
# defined in entrypoint.sh
postgres_username='postgres'
postgres_password='airflow'
# flag value indicates the query quit status
# with 0 means successful query
variable_query_quit_status=1
connection_query_quit_status=1

# check if variable metadata table has been initialised
# reverse exit on error for this section
set +e

while [ $variable_query_quit_status != 0 ]
do
    docker exec "$airflow_postgres" sh -c "psql --username $postgres_username --password $postgres_password --no-password --command='SELECT * FROM variable'" > /dev/null 2>&1
    variable_query_quit_status=$(echo $?)

    # wait 2 second to avoid busy checking for polling
    sleep 2
    echo "Polling to wait for Postgres to have the variable table ready..."
done

# it seems additional scripts are run towards variable table after it being created
# set sleep to wait for the additional scripts to finish
sleep 2

# import local variables
set -e
if [ -d "./variables" ]; then
    cd variables
    for f in *.json ; do
        docker cp "$f" "$airflow_webserver":/opt/airflow/variables/$f;
        echo "importing $f"
        docker exec "$airflow_webserver" sh -c "airflow variables import /opt/airflow/variables/$f"
    done
    cd ..
fi

# check if connection metadata table has been initialised
# reverse exit on error for this section
set +e

echo "Polling until connection table has been created..."
while [ $connection_query_quit_status != 0 ]
do
    docker exec "$airflow_postgres" sh -c "psql --username $postgres_username --password $postgres_password --no-password --command='SELECT * FROM connection'" > /dev/null 2>&1
    connection_query_quit_status=$(echo $?)
done

# import local connections
set -e
if [ -d "./connections" ]; then
    cd connections
    for f in *.json ; do
        docker cp "$f" "$airflow_webserver":/opt/airflow/connections/$f
        conn_base_command="airflow connections add"
        # refer to https://airflow.apache.org/docs/stable/cli-ref#connections for all arg types
        for arg in "conn-id" "conn-uri" "conn-type" "conn-host" "conn-login" "conn-password" "conn-schema" "conn-port" "conn-extra"; do
            arg_value=$(docker exec "$airflow_webserver" sh -c "jq '.\"$arg\"' /opt/airflow/connections/$f" 2> /dev/null)
            # parse json payload into string
            if [ "$arg" = "conn-extra" ]; then
                arg_value=$(echo "$arg_value" | tr -d '\r')
                arg_value="'$arg_value'"
            fi
            # if not arg value is not null
            if [ "$arg" = "conn-id" ]; then
                conn_base_command="$conn_base_command $arg_value"
            elif [ "$arg_value" != "null" ]; then
                conn_base_command="$conn_base_command --$arg $arg_value"
            fi
        done
        echo "$conn_base_command"
        docker exec "$airflow_webserver" sh -c "$conn_base_command"
    done
    cd ..
fi