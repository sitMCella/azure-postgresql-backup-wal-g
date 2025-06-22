#!/bin/bash
set -e

# Install PostgreSQL
sudo apt update
sudo apt-get install -y curl wget gnupg2 ca-certificates net-tools daemontools
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/postgresql.gpg
sudo apt update
sudo apt install -y postgresql-16 postgresql-contrib-16
sudo systemctl start postgresql
sudo systemctl enable postgresql

# Configure PostgreSQL
sudo sed -i '/^host/s/ident/md5/' /etc/postgresql/16/main/pg_hba.conf
sudo sed -i '/^local/s/peer/trust/' /etc/postgresql/16/main/pg_hba.conf
echo "host all all 0.0.0.0/0 md5" | sudo tee -a /etc/postgresql/16/main/pg_hba.conf
echo "listen_addresses = '*'" >> /etc/postgresql/16/main/postgresql.conf
sudo systemctl restart postgresql
sudo ufw allow 5432/tcp
sudo iptables -I INPUT 1 -m tcp -p tcp --dport 5432 -j ACCEPT

# Configure password for the administrator user in PostgreSQL
sudo -u postgres psql -c "ALTER USER postgres PASSWORD '<postgresql_administrator_password>';"

# Configure replication in PostgreSQL
echo "host replication all 0.0.0.0/0 md5" | sudo tee -a /etc/postgresql/16/main/pg_hba.conf
echo "wal_level = logical" >> /etc/postgresql/16/main/postgresql.conf
echo "max_replication_slots = 4" >> /etc/postgresql/16/main/postgresql.conf
echo "max_wal_senders = 5" >> /etc/postgresql/16/main/postgresql.conf
sudo systemctl restart postgresql

# Install and configure WAL-G
wget https://github.com/wal-g/wal-g/releases/download/v3.0.7/wal-g-pg-ubuntu-22.04-amd64.tar.gz
tar -zxvf wal-g-pg-ubuntu-22.04-amd64.tar.gz
mv wal-g-pg-ubuntu-22.04-amd64 /usr/local/bin/wal-g
echo "archive_mode = on" >> /etc/postgresql/16/main/postgresql.conf
echo "archive_command = 'wal-g wal-push %p'" >> /etc/postgresql/16/main/postgresql.conf
echo "archive_timeout = 60" >> /etc/postgresql/16/main/postgresql.conf
sudo systemctl restart postgresql
sudo service postgresql restart