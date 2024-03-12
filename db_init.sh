sudo apt install postgresql postgresql-contrib -y
sudo su - postgres
psql
systemctl enable postgresql
systemctl start postgresql
psql -U postgres
CREATE DATABASE prod;
CREATE DATABASE test;
CREATE DATABASE dev;
pgbench -i -s 10 prod
pgbench -i -s 10 test
pgbench -i -s 10 dev
