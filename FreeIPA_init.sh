#!/bin/bash

# Настройка переменных
SRV_HQ_HOSTNAME="SRV-HQ"
SRV_ALT_HOSTNAME="SRV-ALT"
DOMAIN_NAME="hq.example.com"
ADMIN_PASSWORD="<ПАРОЛЬ_АДМИНИСТРАТОРА>"

# 1. Подготовка серверов

# Установка необходимых пакетов
for SERVER_HOSTNAME in $SRV_HQ_HOSTNAME $SRV_ALT_HOSTNAME; do
  ssh $SERVER_HOSTNAME yum install -y ipa-server bind-utils zip;
done

# 2. Настройка FreeIPA на SRV-HQ

# Инициализация FreeIPA
ssh $SRV_HQ_HOSTNAME ipa-server-install --hostname=$SRV_HQ_HOSTNAME --domain=$DOMAIN_NAME --admin-password=$ADMIN_PASSWORD

# Проверка работоспособности
ssh $SRV_HQ_HOSTNAME ipa-admin-show --host-fqdn=$SRV_HQ_HOSTNAME

# 3. Настройка FreeIPA на SRV-ALT

# Инициализация FreeIPA
ssh $SRV_ALT_HOSTNAME ipa-server-install --hostname=$SRV_ALT_HOSTNAME --domain=$DOMAIN_NAME --admin-password=$ADMIN_PASSWORD --replica

# 4. Создание пользователей

# Создание пользователей user1-user30
for i in {1..30}; do
  ipa user add user$i --password=$ADMIN_PASSWORD --gecosid $i --shell /bin/bash;
done

# 5. Создание групп

# Создание групп group1, group2, group3
ipa group add group1
ipa group add group2
ipa group add group3

# 6. Добавление пользователей в группы

# Добавление user1-user10 в group1
for i in {1..10}; do
  ipa groupaddmember group1 user$i;
done

# Добавление user11-user20 в group2
for i in {11..20}; do
  ipa groupaddmember group2 user$i;
done

# Добавление user21-user30 в group3
for i in {21..30}; do
  ipa groupaddmember group3 user$i;
done

# 7. Настройка аутентификации на CLI-HQ

# Установка клиента FreeIPA
ssh CLI-HQ yum install -y ipa-client

# Присоединение к домену
ssh CLI-HQ ipa-client-install --hostname=CLI-HQ --domain=$DOMAIN_NAME --principal=$ADMIN_PASSWORD@$DOMAIN_NAME

# 8. Установка сертификата CA FreeIPA

# Экспорт сертификата CA FreeIPA
ssh $SRV_HQ_HOSTNAME ipa-admin export cert > ca.crt

# Копирование сертификата на CLI-HQ
scp $SRV_HQ_HOSTNAME:/etc/pki/ca-trust/extracted/certs/ca.crt CLI-HQ:/etc/pki/ca-trust/extracted/certs

# Установка сертификата на CLI-HQ
ssh CLI-HQ sudo update-ca-certificates
