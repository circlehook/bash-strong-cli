  ПРОБЛЕМЫ С КОДИРОВКОЙ 
    echo "export LC_CTYPE=en_US.UTF-8" >> ~/.bashrc
    echo "export LC_ALL=en_US.UTF-8"   >> ~/.bashrc && source ~/.bashrc

  НАТРОЙКА ВРЕМЕНИ: 
    timedatectl set-time "hh:mm:ss"
    timedatectl list-timezones
    timedatectl set-timezone Europe/Kyiv
    hostnamectl set-hostname domain.net.ua
  
  РЕПОЗИТОРИИ
    CentOS: cd /etc/yum.repos.d/
      yum clean all 
      yum repolist 
      rpm -qa | grep nginx
    CentOS7 vault:
      sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
      sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*
      yum clean all
      yum makecache
    Ubuntu: cd  /etc/apt/ 
      add-apt-repository
      cat /etc/apt/sources.list
      cd  /etc/apt/sources.list.d
      dpkg -l | grep nginx
      
  СОЗДАНИЕ ПОЛЬЗОВАТЕЛЯ
    sudo adduser bitrix
    pass: 90ZPHDPQMr
    mkdir -p /home/bitrix/www
    chown -R bitrix:bitrix /home/bitrix
    mkdir -p /usr/bac
    # nano /etc/group
    # www-data:x:33:bitrix