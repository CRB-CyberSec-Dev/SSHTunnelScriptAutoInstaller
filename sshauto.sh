#!/bin/bash
# This script is automatic installing SSH Stunnel SSL by CRB-CyberSec-Dev(ChamalBandara)
# Only Support Ubuntu 18.04.2 LTS
# SSH Banner On /root/CRB

install() {
    if [ $(id -u) -eq 0 ]; then
        install_redist
        install_openssl
        install_stunnel
        install_dropbear
        install_squid
        install_nss
        install_badvpn
        create_user
        display_last
    else
        echo "Run as root user."
        exit 2
    fi
}

user() {
    create_user
    display_last
}

autostart() {
    printf "[Unit]
Description=Auto Start SSH/Badvpn UDPGW CRB service
After=nss-lookup.target
StartLimitIntervalSec=0
[Service]
Type=simple
Restart=always
RestartSec=60
User=root
ExecStart=/usr/local/bin/badvpn-udpgw --loglevel none --listen-addr 127.0.0.1:7300 > /dev/null
[Install]
WantedBy=multi-user.target" >> /root/CRB/crbssh.service

    cd /root/CRB/
    chmod +x crbssh.service
    mv crbssh.service /etc/systemd/system

    sudo systemctl enable crbssh.service
    sudo systemctl start crbssh.service
}

install_redist() {
    apt-get update -y
    apt-get install -y unzip git gyp re2c ninja-build zlib1g-dev pkg-config \
                        libssl-dev libnspr4-dev sed tar mercurial perl cmake \
                        screen wget gcc build-essential g++ make
    mkdir -p /root/CRB
    echo "/bin/false" >> /etc/shells
    echo "/usr/sbin/nologin" >> /etc/shells
}

install_openssl() {
    cd /usr/local/src/
    wget https://www.openssl.org/source/openssl-3.0.0-alpha5.tar.gz
    tar -xf openssl-3.0.0-alpha5.tar.gz
    cd openssl-3.0.0-alpha5
    ./config --prefix=/usr/local/ssl --openssldir=/usr/local/ssl shared zlib
    make
    make test
    make install
    echo "/usr/local/ssl/lib" > /etc/ld.so.conf.d/openssl-3.0.0-alpha5.conf
    ldconfig -v
    cp /usr/bin/openssl /usr/bin/openssl.backup
    cp /usr/bin/c_rehash /usr/bin/c_rehash.backup
    echo 'PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/usr/local/ssl/bin"' > /etc/environment
    source /etc/environment
    echo $PATH
}

install_dropbear() {
    apt-get install -y dropbear
    sed -i 's/NO_START=1/NO_START=0/g' /etc/default/dropbear
    sed -i 's/DROPBEAR_PORT=22/DROPBEAR_PORT=444/g' /etc/default/dropbear
    sed -i 's/DROPBEAR_EXTRA_ARGS=/DROPBEAR_EXTRA_ARGS="-p 143"/g' /etc/default/dropbear
    sed -i 's#DROPBEAR_BANNER=""#DROPBEAR_BANNER="/root/CRB/dropbearbanner"#g' /etc/default/dropbear
    echo "SSH Stunnel Server. Do Not Download Torrent. Tunnel Made By CRB. SSH Auto Installer on Ubuntu 18.04" > /root/CRB/dropbearbanner
    service dropbear restart
}

install_squid() {
    apt-get install -y squid3
    sed -i 's/#http_access allow localnet/http_access allow localnet/g' /etc/squid/squid.conf
    sed -i 's+#acl localnet src+acl localnet src 192.168.1.0/255.255.255.0+g' /etc/squid/squid.conf
    service squid restart
}

install_stunnel() {
    apt-get install -y stunnel4
    LIB="/usr/lib/x86_64-linux-gnu/libssl.so.1.0.0"
    LIB2="/usr/local/ssl/lib/libssl.so.3"
    INODE="$(ls -i "$LIB" | awk '{print $1}')"
    INODE2="$(ls -i "$LIB2" | awk '{print $1}')"
    lsof | grep libssl.so | grep -v "$INODE"
    lsof | grep libssl.so | grep -v "$INODE2"
    cd /root
    openssl rand -writerand .rnd
    read -p 'Enter Your Internal/Static Ip: ' sip
    read -p 'Do you want to configure OpenSSL CSR otherwise it will be automatically configured (Yes/no): ' aut

    if [[ $aut =~ ^[Yy] ]]; then
        read -p 'Country Name (2 letter code) [AU]: ' co
        read -p 'State or Province Name (full name) [Some-State]: ' st
        read -p 'Locality Name (eg, city) []: ' lo
        read -p 'Organization Name (eg, company) [Internet Widgits Pty Ltd]: ' or
        read -p 'Organizational Unit Name (eg, section) []: ' oru
        read -p 'Common Name (e.g. server FQDN or YOUR name) []: ' cn
        read -p 'Insert Expire Date (eg, 365) []: ' da
    else
        co="LK"
        st="Central"
        lo="Kandy"
        or="CRB"
        oru="CRB"
        cn="ChamalBandara"
        da="800"
    fi

    openssl genrsa 1024 > stunnel.key
    openssl req -new -key stunnel.key -x509 -days $da -out stunnel.crt -subj "/C=$co/ST=$st/L=$lo/O=$or/OU=$oru/CN=$cn"
    cat stunnel.crt stunnel.key > stunnel.pem
    mv stunnel.pem /etc/stunnel/
    echo -e "pid = /var/run/stunnel.pid\ncert = /etc/stunnel/stunnel.pem\n[ssh]\naccept = $sip:443\nconnect = 127.0.0.1:444" > /etc/stunnel/stunnel.conf
    sed -i 's/ENABLED=0/ENABLED=1/g' /etc/default/stunnel4
    service stunnel4 start
}

install_nss() {
    hg clone https://hg.mozilla.org/projects/nspr /root/CRB/nspr
    hg clone https://hg.mozilla.org/projects/nss /root/CRB/nss
    cd /root/CRB/
    nss/build.sh
}

install_badvpn() {
    cd /root/CRB/
    git clone https://github.com/ambrop72/badvpn.git
    cd badvpn/
    export DYLD_LIBRARY_PATH=$DYLD_LIBRARY_PATH:/root/CRB/nss/lib
    mkdir build
    cd build
    cmake .. -DBUILD_NOTHING_BY_DEFAULT=1 -DBUILD_TUN2SOCKS=1 -DBUILD_UDPGW=1
    make install
}

create_user() {
    if [ $(id -u) -eq 0 ]; then
        read -p "Enter username: " username
        read -s -p "Enter password: " password
        egrep "^$username" /etc/passwd >/dev/null
        if [ $? -eq 0 ]; then
            echo "$username exists!"
            exit 1
        else
            pass=$(perl -e 'print crypt($ARGV[0], "password")' $password)
            useradd -m -s /bin/false -p "$pass" "$username"
            [ $? -eq 0 ] && echo "User has been added to system!" || echo "Failed to add a user!"
        fi
    else
        echo "Only root may add a user to the system."
        exit 2
    fi
}

display() {
    #Programe UI CMD Interface
    export BLUE='\033[1;94m'
    export GREEN='\033[1;92m'
    export RED='\033[1;91m'
    export RESETCOLOR='\033[1;00m'
    echo -e "
$RED SSH Stunnel Auto Installer Script Dev ChamalBandara(CRB). \n
===============================================================================\n
$RED Usage:- $GREEN chmod +x sshauto
            $GREEN ./sshauto install (For Install)
            $GREEN ./sshauto user (For Create Users)
            $GREEN ./sshauto autostart (Automatic Start BADVPN)
$Red Badvpn Service UPWD Forward :- 
            $GREEN sudo systemctl enable crbssh.service
            $GREEN sudo systemctl start crbssh.service
            $GREEN sudo systemctl status crbssh.service
$RED Protocol:-$BLUE TCP & UDP \n
$RED Dropbear:-$BLUE 444,143 \n
$RED SSL:-$BLUE 443 \n
$RED Proxy:-$BLUE 3128 \n
$RED Do you more information, Visit me on Youtube. CRB. \n
================================================================================
$RESETCOLOR"
}

display_last() {
echo -e "
$RED SSH Stunnel Auto Installer Script Dev ChamalBandara(CRB). \n
================================================================================\n
 YourIp :- $sip
 User :- $username 
 Password :- $password \n
$RED Protocol:-$BLUE TCP & UDP \n
$RED Dropbear:-$BLUE 444,143 \n
$RED SSL:-$BLUE 443 \n
$RED Proxy:-$BLUE 3128 \n
$RED Do you more information, Visit me on Youtube. CRB. \n
$RED After Install Complete Reboot System.(First Time Only)
================================================================================\n
$RESETCOLOR" 
}

display
$1
