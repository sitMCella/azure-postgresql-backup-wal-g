# Backup for Azure PostgreSQL Flexible Server using WAL-G

## Table of contents

* [Introduction](#introduction)
* [Requirements](#requirements)
* [Terraform](#terraform)
* [PostgreSQL Replication](#postgresql-replication)
* [WAL-G](#wal-g)

## Introduction

The following projects uses WAL-G to take backups of one Azure Database for PostgreSQL Flexible Server.

## Requirements

- Terraform
- Azure CLI
- Psql client or PgAdmin

## Terraform

### Configuration

Assign the RBAC roles "Contributor", "User Access Administrator" to the User account on the Subscription level.

Create the file terraform.tfvars and provide the values for the following Terraform variables:

```sh
subscription_id="<subscription_id>"
location="<azure_region>" # e.g. "westeurope"
location_abbreviation="<azure_region_abbreviation>" # e.g. "weu"
environment="<environment_name>" # e.g. "test"
workload_name="<workload_name>"
postgresql_administrator_login="<postgresql_administrator_name>"
postgresql_administrator_password="<postgresql_administrator_password>"
vm_admin_username="<virtual_machine_administrator_name>"
vm_admin_password="<virtual_machine_administrator_password>"
allowed_public_ip_address_ranges=[<list_of_allowed_ip_address_ranges>] # Public IP Address ranges allowed to access the Azure resources e.g. "1.2.3.4/32"
allowed_public_ip_addresses=<[<list_of_allowed_ip_addresses>] # Public IP Addresses allowed to access the Azure resources  e.g. "1.2.3.4"
```

Before proceeding with the next sections, open a terminal and login in Azure with Azure CLI using the User account.

### Terraform Project Initialization

```sh
terraform init -reconfigure
```

### Verify the Updates in the Terraform Code

```sh
terraform plan
```

### Apply the Updates from the Terraform Code

```sh
terraform apply -auto-approve
```

### Format Terraform Code

```sh
find . -not -path "*/.terraform/*" -type f -name '*.tf' -print | uniq | xargs -n1 terraform fmt
```

### Check the Initialization of the Azure Virtual Machine

SSH into the Azure Virtual Machine and check the initialization status of the Azure Virtual Machine:

```sh
cat /var/log/cloud-init-output.log
```

## PostgreSQL Replication

The Azure Database for PostgreSQL Flexible Server resources support the logical replication for the databases using the PostgreSQL native logical replication: https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/concepts-logical.

The PostgreSQL native logical replication does not replicate schema changes (DDL), so these changes must be applied manually on the target PostgreSQL database.

This section describes the configurations to apply in order to allow the database replication.

### Azure Database for PostgreSQL Flexible Server

Create data in the PostgreSQL database "database1":

```sh
CREATE TABLE public.table1(id INT PRIMARY KEY, name VARCHAR(255) NOT NULL, type VARCHAR(255));
INSERT INTO public.table1(id, name, type) VALUES (1, 'name1', 'type1');
INSERT INTO public.table1(id, name, type) VALUES (2, 'name2', 'type1');
SELECT * FROM public.table1;
```

Configure the following server parameters in the Azure Database for PostgreSQL Flexible Server resource:

```sh
wal_level = logical
max_replication_slots = 4
max_wal_senders = 5
```

Restart the Azure Database for PostgreSQL Flexible Server instance.

Create a replicator user in the PostgreSQL Flexible Server instance:

```sh
CREATE ROLE replicator WITH REPLICATION LOGIN PASSWORD '<replicator_password>';
GRANT CONNECT ON DATABASE database1 TO replicator;
GRANT azure_pg_admin TO replicator;
ALTER ROLE replicator REPLICATION LOGIN;
```

Create a publication on database1:

```sh
CREATE PUBLICATION dbpub FOR ALL TABLES;
```

Verify the replication status:

```sh
SELECT * FROM pg_stat_replication;
```

### PostgreSQL in Azure Virtual Machine

Create the database and the table in PostgreSQL:

```sh
sudo -u postgres psql
CREATE DATABASE database1;
\l
CREATE TABLE public.table1(id INT PRIMARY KEY, name VARCHAR(255) NOT NULL, type VARCHAR(255));
\dt
SELECT * FROM public.table1;
\q
```

Create subscription:

```sh
CREATE SUBSCRIPTION dbsub CONNECTION 'host=psql-example-<environment>-<location_abbreviation>-001.postgres.database.azure.com port=5432 dbname=database1 user=replicator password=<replicator_password> sslmode=require' PUBLICATION dbpub;
```

## WAL-G

### PostgreSQL Backup

SSH into the Azure Virtual Machine and execute the following commands:

```sh
sudo su
echo 'localhost' > /etc/wal-g.d/env/PGHOST
echo '5432' > /etc/wal-g.d/env/PGPORT
echo 'postgres' > /etc/wal-g.d/env/PGUSER
echo '<postgresql_administrator_password>' > /etc/wal-g.d/env/PGPASSWORD
echo 'database1' > /etc/wal-g.d/env/PGDATABASE
echo 'azure://backups/walg' > /etc/wal-g.d/env/WALG_AZ_PREFIX
echo 'stgzrpw<environment><location_abbreviation>001' > /etc/wal-g.d/env/AZURE_STORAGE_ACCOUNT
echo '67108864' > /etc/wal-g.d/env/WALG_AZURE_BUFFER_SIZE
echo '4' > /etc/wal-g.d/env/WALG_AZURE_MAX_BUFFERS
chown -R postgres:postgres /etc/wal-g.d
chmod 755 -R /etc/wal-g.d
```

Start the backup of the database:

```sh
cd /tmp
export PGDATA=/var/lib/postgresql/16/main
sudo -u postgres envdir /etc/wal-g.d/env wal-g backup-push $PGDATA
```

List backups:

```sh
cd /tmp
sudo -u postgres envdir /etc/wal-g.d/env wal-g backup-list
```

### PostgreSQL Restore

The following commands can be used to restore the PostgreSQL database to the latest backup.

```sh
cd /tmp
export PGDATA=/var/lib/postgresql/16/main
sudo systemctl stop postgresql
sudo rm -rf /var/lib/postgresql/16/main/*
sudo -u postgres envdir /etc/wal-g.d/env wal-g backup-fetch $PGDATA LATEST
sudo systemctl start postgresql
```
