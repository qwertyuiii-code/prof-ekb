#!/bin/bash

# Настройка переменных
SSH_USER="sshuser"
SSH_PASSWORD="P@ssw0rd"

# 1. Настройка SRV-HQ и SRV-BR

### 1.1 Создание пользователя SSH
for SERVER_HOSTNAME in SRV-HQ SRV-BR; do
  ssh $SERVER_HOSTNAME << EOF
  useradd -m -s /bin/bash $SSH_USER
  echo "$SSH_PASSWORD" | passwd -c $SSH_USER
  EOF
done

### 1.2 Настройка sudo без пароля
for SERVER_HOSTNAME in SRV-HQ SRV-BR; do
  ssh $SERVER_HOSTNAME << EOF
  echo "$SSH_USER ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
  visudo
  EOF
done

### 1.3 Отключение парольной аутентификации SSH
for SERVER_HOSTNAME in SRV-HQ SRV-BR; do
  ssh $SERVER_HOSTNAME << EOF
  sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
  systemctl restart sshd
  EOF
done

### 1.4 Генерация ключей SSH
ssh SRV-HQ << EOF
  ssh-keygen
  echo "Скопируйте ваш публичный ключ SSH на CLI-HQ."
EOF

# 2. Настройка CLI-HQ

### 2.1 Создание пользователя SSH
ssh CLI-HQ << EOF
  useradd -m -s /bin/bash $SSH_USER
  echo "$SSH_PASSWORD" | passwd -c $SSH_USER
  EOF

### 2.2 Настройка SSH-клиента
ssh CLI-HQ << EOF
  mkdir ~/.ssh
  echo "<Вставьте ваш скопированный публичный ключ SSH>" >> ~/.ssh/id_rsa.pub
  chmod 600 ~/.ssh/id_rsa.pub
  ssh-keyscan SRV-HQ SRV-BR >> ~/.ssh/known_hosts

  cat << EOF > ~/.ssh/config
  Host SRV-HQ
    User $SSH_USER
    HostName <IP_адрес_SRV_HQ>
    Port 2023
    IdentityFile ~/.ssh/id_rsa

  Host SRV-BR
    User $SSH_USER
    HostName <IP_адрес_SRV_BR>
    Port 2023
    IdentityFile ~/.ssh/id_rsa
  EOF

  chmod 600 ~/.ssh/config
  EOF

## Примечания:

- Замените `<IP_адрес_SRV_HQ>` и `<IP_адрес_SRV_BR>` на IP-адреса ваших серверов SRV-HQ и SRV-BR.
- Вставьте ваш скопированный публичный ключ SSH вместо `<Вставьте ваш скопированный публичный ключ SSH>`.
- Убедитесь, что у вас есть доступ к серверам через SSH.
- 
