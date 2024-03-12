#!/bin/bash

# Настройка переменных
POSTGRES_VERSION="14" # Укажите желаемую версию PostgreSQL
POSTGRES_USER="postgres"
POSTGRES_PASSWORD="ваш_пароль"
DATABASES=("prod" "test" "dev")

# Обновление системы
echo "Обновление системы..."
sudo apt update && sudo apt upgrade -y

# Установка PostgreSQL
if ! dpkg -l | grep -q "postgresql-$POSTGRES_VERSION"; then
  echo "Установка PostgreSQL $POSTGRES_VERSION..."
  sudo apt install postgresql-$POSTGRES_VERSION postgresql-$POSTGRES_VERSION-contrib -y
else
  echo "PostgreSQL $POSTGRES_VERSION уже установлен."
fi

# Настройка PostgreSQL
echo "Настройка PostgreSQL..."
sudo systemctl enable postgresql
sudo systemctl start postgresql

# Создание пользователя и настройка pgbench
echo "Создание пользователя и настройка pgbench..."
sudo su - $POSTGRES_USER -c "psql -U $POSTGRES_USER << EOF
    CREATE USER $POSTGRES_USER WITH PASSWORD '$POSTGRES_PASSWORD';
    ALTER USER <span class="math-inline">POSTGRES\_USER WITH SUPERUSER;
CREATE DATABASE template1;
UPDATE pg\_database SET encoding \= 'UTF8' WHERE datname \= 'template1';
UPDATE pg\_database SET lc\_collate \= 'en\_US\.UTF8' WHERE datname \= 'template1';
UPDATE pg\_database SET lc\_ctype \= 'en\_US\.UTF8' WHERE datname \= 'template1';
CREATE TEMPLATE template0;
LINK TEMPLATE template0 TO template1;
EOF"
\# Создание баз данных
for DATABASE in "</span>{DATABASES[@]}"; do
  echo "Создание базы данных: $DATABASE"
  sudo su - $POSTGRES_USER -c "psql -U $POSTGRES_USER << EOF
    CREATE DATABASE <span class="math-inline">DATABASE;
EOF"
done
\# Заполнение тестовыми данными
for DATABASE in "</span>{DATABASES[@]}"; do
  echo "Заполнение базы данных $DATABASE тестовыми данными..."
  pgbench -i -s 10 <span class="math-inline">DATABASE
done
\# Создание файла pgbench\_init\.sql
echo "Создание файла pgbench\_init\.sql\.\.\."
cat << EOF \> pgbench\_init\.sql
CREATE TABLE pg\_bench\_accounts \(
aid SERIAL PRIMARY KEY,
acctid INTEGER NOT NULL,
custname VARCHAR\(20\) NOT NULL,
balance NUMERIC\(10, 2\) NOT NULL,
address VARCHAR\(40\) NOT NULL,
zipcode VARCHAR\(10\) NOT NULL,
city VARCHAR\(20\) NOT NULL,
state CHAR\(2\) NOT NULL,
country CHAR\(2\) NOT NULL,
phone VARCHAR\(15\) NOT NULL,
email VARCHAR\(50\) NOT NULL,
creditlim NUMERIC\(10, 2\) NOT NULL
\);
CREATE TABLE pg\_bench\_tellers \(
tid SERIAL PRIMARY KEY,
tname VARCHAR\(20\) NOT NULL,
taddr VARCHAR\(40\) NOT NULL,
zipcode VARCHAR\(10\) NOT NULL,
city VARCHAR\(20\) NOT NULL,
state CHAR\(2\) NOT NULL,
country CHAR\(2\) NOT NULL,
phone VARCHAR\(15\) NOT NULL,
manager INTEGER NOT NULL,
branch INTEGER NOT NULL
\);
CREATE TABLE pg\_bench\_branches \(
bid SERIAL PRIMARY KEY,
bname VARCHAR\(20\) NOT NULL,
addr VARCHAR\(40\) NOT NULL,
zipcode VARCHAR\(10\) NOT NULL,
city VARCHAR\(20\) NOT NULL,
state CHAR\(2\) NOT NULL,
country CHAR\(2\) NOT NULL,
assets NUMERIC\(10, 2\) NOT NULL
\);
CREATE TABLE pg\_bench\_history \(
hid SERIAL PRIMARY KEY,
aid INTEGER NOT NULL,
tid INTEGER NOT NULL,
bid INTEGER NOT NULL,
datetime TIMESTAMP NOT NULL,
amount NUMERIC\(10, 2\) NOT NULL,
deposit INTEGER NOT NULL
\);
EOF
\# Создание и заполнение тестовых данных с помощью pgbench\_init\.sql
echo "Создание и заполнение тестовых данных с помощью pgbench\_init\.sql\.\.\."
for DATABASE in "</span>{DATABASES[@]}"; do
  psql -U $POST

