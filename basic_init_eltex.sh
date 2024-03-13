#!/bin/bash

# Настройка переменных
HQ_VLAN_10_NAME="HQ_Management"
HQ_VLAN_10_IP="10.0.10.1"
HQ_VLAN_10_NETMASK="255.255.255.0"

HQ_VLAN_20_NAME="HQ_Workstations"
HQ_VLAN_20_IP="10.0.10.100"
HQ_VLAN_20_NETMASK="255.255.255.0"

BR_VLAN_30_NAME="BR_Management"
BR_VLAN_30_IP="10.0.20.1"
BR_VLAN_30_NETMASK="255.255.255.0"

BR_VLAN_40_NAME="BR_Workstations"
BR_VLAN_40_IP="10.0.20.100"
BR_VLAN_40_NETMASK="255.255.255.0"

# Проверка наличия утилиты `expect`
if ! command -v expect >/dev/null; then
  echo "Утилита 'expect' не найдена. Установите ее перед запуском скрипта."
  exit 1
fi

# Подключение к маршрутизатору
expect << EOF
spawn telnet <ВАШ_IP_МАРШРУТИЗАТОРА>
username
stty echo
password
EOF

# Создание VLAN 10
echo "Создание VLAN 10..."
send "vlan 10 $HQ_VLAN_10_NAME\r"
send "exit\r"

# Создание VLAN 20
echo "Создание VLAN 20..."
send "vlan 20 $HQ_VLAN_20_NAME\r"
send "exit\r"

# Создание VLAN 30
echo "Создание VLAN 30..."
send "vlan 30 $BR_VLAN_30_NAME\r"
send "exit\r"

# Создание VLAN 40
echo "Создание VLAN 40..."
send "vlan 40 $BR_VLAN_40_NAME\r"
send "exit\r"

# Настройка интерфейса VLAN 10
echo "Настройка интерфейса VLAN 10..."
send "interface vlan 10\r"
send "ip address $HQ_VLAN_10_IP $HQ_VLAN_10_NETMASK\r"
send "no shutdown\r"
send "exit\r"

# Настройка интерфейса VLAN 20
echo "Настройка интерфейса VLAN 20..."
send "interface vlan 20\r"
send "ip address $HQ_VLAN_20_IP $HQ_VLAN_20_NETMASK\r"
send "no shutdown\r"
send "exit\r"

# Настройка интерфейса VLAN 30
echo "Настройка интерфейса VLAN 30..."
send "interface vlan 30\r"
send "ip address $BR_VLAN_30_IP $BR_VLAN_30_NETMASK\r"
send "no shutdown\r"
send "exit\r"

# Настройка интерфейса VLAN 40
echo "Настройка интерфейса VLAN 40..."
send "interface vlan 40\r"
send "ip address $BR_VLAN_40_IP $BR_VLAN_40_NETMASK\r"
send "no shutdown\r"
send "exit\r"

# Сохранение настроек
echo "Сохранение настроек..."
send "write\r"
send "y\r"

# Закрытие соединения
echo "Закрытие соединения..."
send "exit\r"
EOF

echo "Настройка VLAN завершена."
