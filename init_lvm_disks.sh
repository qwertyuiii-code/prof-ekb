#!/bin/bash

# Настройка переменных
VG_NAME="data"
LV_NAME="data-lv"
FS_TYPE="ext4"
MOUNT_POINT="/opt/data"

# Проверка наличия lvm2
if ! command -v lvm >/dev/null; then
  echo "LVM2 не установлен. Установите пакет 'lvm2' перед запуском скрипта."
  exit 1
fi

# Проверка наличия cryptsetup (только для шифрования)
if [[ $ENCRYPTION == "yes" ]]; then
  if ! command -v cryptsetup >/dev/null; then
    echo "Cryptsetup не установлен. Установите пакет 'cryptsetup' перед запуском скрипта."
    exit 1
  fi
fi

# 1. Подготовка

# 1.1 Определение устройств
echo "Определение доступных устройств..."
DISKS=$(lsblk -d -o name)

# 1.2 Проверка наличия свободных устройств
if [[ -z $DISKS ]]; then
  echo "Не найдено ни одного свободного устройства."
  exit 1
fi

# 1.3 Выбор устройств
echo "Выберите два устройства для создания LVM тома:"
echo $DISKS
read -r -p "Устройство 1: " DEVICE1
read -r -p "Устройство 2: " DEVICE2

# 1.4 Проверка выбранных устройств
if [[ -z $DEVICE1 || -z $DEVICE2 ]]; then
  echo "Необходимо выбрать два устройства."
  exit 1
fi

if [[ $DEVICE1 == $DEVICE2 ]]; then
  echo "Выберите два разных устройства."
  exit 1
fi

# 2. Создание LVM тома

# 2.1 Создание физических томов
echo "Создание физических томов..."
sudo pvcreate $DEVICE1 $DEVICE2

# 2.2 Создание группы томов
echo "Создание группы томов..."
sudo vgcreate $VG_NAME $DEVICE1 $DEVICE2

# 2.3 Создание логического тома
echo "Создание логического тома..."
sudo lvcreate -n $LV_NAME -L 100G $VG_NAME

# 3. Шифрование (опционально)

if [[ $ENCRYPTION == "yes" ]]; then
  # 3.1 Создание шифрованного устройства
  echo "Создание шифрованного устройства..."
  sudo cryptsetup luksFormat /dev/$VG_NAME/$LV_NAME
  
  # 3.2 Ввод пароля для шифрования
  echo "Введите и подтвердите пароль для шифрования:"
  sudo cryptsetup luksOpen /dev/$VG_NAME/$LV_NAME data-lv
fi

# 4. Файловая система

# 4.1 Создание файловой системы
echo "Создание файловой системы..."
sudo mkfs.$FS_TYPE /dev/mapper/data-lv

# 5. Монтирование

# 5.1 Точка монтирования
echo "Монтирование логического тома..."
sudo mkdir -p $MOUNT_POINT

# 5.2 Автоматическое монтирование
echo "Настройка автоматического монтирования..."
echo "/dev/mapper/data-lv $MOUNT_POINT $FS_TYPE defaults 0 0" | sudo tee -a /etc/fstab

# 6. Завершение

echo "Настройка LVM завершена."

if [[ $ENCRYPTION == "yes" ]]; then
  echo "**Внимание!**"
  echo "Для автоматического открытия шифрованного устройства при загрузке необходимо добавить запись в файл '/etc/initcpio.conf'."
  echo "**Пример:**"
  echo "/dev/$VG_NAME/$LV_NAME {
    luks: luksOpen /dev/$VG_NAME/$LV_NAME data-lv
    block {
      device = /dev/mapper/data-lv
      mountpoint = $MOUNT_POINT
    }
  }"
  echo "**Не забудьте обновить файл '/etc/initcpio.conf' и перезагрузить сервер!**"
fi
