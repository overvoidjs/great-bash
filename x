#!/usr/bin/env bash

# имя функции для запуска
FUNCTION=
if [ ! -z $1 ]; then
    FUNCTION="$1"
fi

showHelp(){
  echo -e "Не забываем sudo ./x для норм. работы: "
  echo -e "givemesoft - для новой ОС"
  echo -e "dockerinst/dockerdel - установка/удаление docker"
  echo -e "dockerapp - развертывание докер среды разработки"
  echo -e "torbuild/torstart/torstop - установка/включение/выключение TOR"
  echo -e "filekiller - найти и удалить файл/файлы по маске"
  echo -e "prockiller - убить процесс по имени"
  echo -e "zipkey - создать зашифрованный архив и удалить исходник"
  echo -e "cod - проверка статуса ответа сайта из консоли"
  echo -e "makeliveos - создание загрузочной флешки с постоянным шифрованным хранилищем"
  echo -e ""
}

filekiller(){
  echo -e "Enter file name(file.txt or *.txt): "
read filetokill
echo -e "Enter dir path(from ~ to dir './Documents/dir'): "
read dptofile
echo -e "1-Find and dell files only in dir;
2-Find and dell files in dir recursively(-r)"
read killmodx

if [ $killmodx -eq 1 ]; then
cd ~
find $dptofile -type f -eame "$filetokill" -delete
fi

if [ $killmodx -eq 2 ]; then
cd ~
find $dptofile -eame $filetokill | xargs rm -rf
fi
}

cod(){
echo -e "Wait the URL: "
read urltotestcod
echo -e ""
while true; do curl -Is $urltotestcod | head -n 1; sleep 2; done
}

prockiller(){
  echo -e "Enter proc name: "
read dirx
kill `ps aux|grep $dirx|sed "s/root *\([0-9]*\) .*/\1/"`. 2>/dev/null
echo "Die".$dirx
}

zipkey(){
  echo -e "Enter Dir or Zip(без .zip) name: "
read dirx
if [ -d ./$dirx/ ]; then
echo -e "New Pass: "
read spx

zip --password $spx -r $dirx.zip $dirx
rm -rf $dirx/
else
unzip $dirx.zip
rm -rf $dirx.zip
fi
}

givemesoft(){
sudo apt-get install git -y
sudo apt-get install curl -y
sudo add-apt-repository ppa:webupd8team/atom -y
sudo apt-get update -y
sudo apt-get install atom -y
sudo apt-get install gimp -y
sudo apt-get install terminator -y
wget https://release.gitkraken.com/linux/gitkraken-amd64.deb
sudo dpkg -i gitkraken-amd64.deb -y
sudo add-apt-repository ppa:atareao/telegram -y
sudo apt-get update -y
sudo apt-get install telegram -y
sudo apt-get install php
}

dockerinst(){
  sudo apt-get install curl
  sudo apt-get update
  sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
  echo "deb https://apt.dockerproject.org/repo ubuntu-xenial main" | sudo tee /etc/apt/sources.list.d/docker.list
  sudo apt-get update
  apt-cache policy docker-engine
  sudo apt-get install -y docker-engine
  sudo usermod -aG docker $(whoami)
  sudo curl -L https://github.com/docker/compose/releases/download/1.21.0/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
  docker -v
  docker-compose -v
}

dockerdel(){
  sudo apt purge *docker*
sudo apt autoremove -y --purge *docker*
sudo autoclean
sudo groupdel docker
}

dockerapp(){
  cd ~
  echo "Starting full install..."
  sudo apt-get install git
  echo "Git installed +"
  git clone https://github.com/loisoj/yupe-docker.git
  echo "git clone end +"
  chmod +x ./yupe-docker/yupe
  cd yupe-docker
  ./yupe set-env dev
  ./yupe alive
  echo "yupe docker installed +"
  echo "Base Started! +"
  echo " "
  echo "Starting installing Monitor System..."
  git clone https://github.com/loisoj/dockermonitoring
  cd dockermonitoring
  docker-compose up -d
  docker ps
  echo " "
  echo "Done!"
}

imageweserv(){
  git clone https://github.com/weserv/images.git
  cp app/config.example.lua app/config.lua
  docker build . -t imagesweserv
  docker run \
    -v $(pwd):/var/www/imagesweserv \
    -v $(pwd)/config/nginx/conf.d:/usr/local/openresty/nginx/conf/conf.d/ \
    -v $(pwd)/logs/supervisor:/var/log/supervisor \
    -v /dev/shm:/dev/shm \
    -p 80:80 \
    -d \
    --name=imagesweserv \
    imagesweserv
}

torbuild(){
sudo apt-get install tor privoxy
}


torstart() {
sudo ./src/torer.py -l
}

torstop() {
sudo ./src/torer.py -f
}

makeliveos(){
  echo -e "Создание загрузочной флешки."
  echo -e "Для начала выберем флешку:"
  echo -e
  sudo fdisk -l
  echo -e
  echo -e "Введите имя флешки, без # , пример:"
  echo -e "sdb"
  echo -e
  read loflash
    echo -e
  echo -e "Введите имя образа(должно находиться в дирректории скрипта):"
  echo -e "kali.iso"
  echo -e
  read loiso
  sudo dd if=$loiso of=/dev/$loflash bs=512k
    echo -e
  echo -e "Введите последнее свободное место Start/Начало, пример:"
  echo -e "2794MB"
  echo -e
  sudo parted /dev/$loflash unit MB print free
  read lomb
    echo -e
  echo -e "Введите последнее имя раздела, пример:"
  echo -e "sdb3"
  echo -e
  read lonamer
    echo -e
  echo -e "Введите введите размер в гигабайтах пример:"
  echo -e "размер флешки - занятое пространство(то что указывали в MB)"
    echo -e "В моем случае это 14gb - 2794MB = 9gb"
  echo -e
  read losize
  sudo parted /dev/$loflash mkpart primary ext3 $lomb $losize
    echo -e
      echo -e "Ответьте YES (Именно большими и укажите пароль для хранилища)"
        echo -e
  sudo cryptsetup --verbose --verify-passphrase luksFormat /dev/$lonamer
}

   if [ ! -z $(type -t $FUNCTION | grep function) ]; then
        $1
    else
        showHelp
fi
