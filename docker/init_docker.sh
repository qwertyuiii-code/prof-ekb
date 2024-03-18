# Установка Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Установка Docker Compose
sudo apt install docker-compose

# Запуск Docker Registry
docker run -d -p 5000:5000 --restart=always --name registry registry:2

echo "experts" > ~/name.txt
