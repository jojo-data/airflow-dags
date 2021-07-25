# Project Structure
All local cluster setup files are under `local_dev` directory, the airflow development falls under `src` directory

```
├── README.md
├── local_dev
│   ├── Dockerfile
│   ├── connections
│   │   └── example_api.json
│   ├── docker-compose.yaml
│   ├── docker-dependencies
│   │   ├── airflow-image-files
│   │   │   ├── airflow.cfg.tmpl
│   │   │   └── entrypoint.sh
│   │   └── postgres-script
│   │       └── init.sql
│   ├── import-variable-and-conn.sh
│   ├── main.sh
│   ├── requirements.txt
│   └── variables
│       └── example_variable.json
└── src
    ├── dags
    │   └── example_dag.py
    ├── hooks
    ├── operators
    └── tests
```
# Init Steps
Spin up the local airflow cluster with celery executor
```bash
cd local_dev
sh main.sh
```
Tear down the local airflow cluster
```bash
docker-compose down
```