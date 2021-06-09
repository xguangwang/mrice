#!/bin/bash
#
#setup && update openssh8.0p1

#Action state
mstate(){
    if [ $? -eq 0 ];then
        echo "--------------------------By installing--------------------------"
    else
    echo "--------------------------Installation failed--------------------"
        exit 1
    fi
}

MDIR=`pwd`

#zlib1.2.11
mzlib(){
if [ -d /usr/local/zlib-1.2.11 ];then
    echo "------------------------zlib-1.2.11 installation complete------------"
else
    echo "-----------------------Start setup zlib------------------------------"
    cd $MDIR
    tar -xzvf zlib-1.2.11.tar.gz >> /dev/null
    cd zlib-1.2.11
    ./configure --prefix=/usr/local/zlib-1.2.11 && make && make install
    mstate
fi
}

#openssl-fips
mopenssl_fips(){
if [ -d /usr/local/ssl/fips-2.0 ];then
    echo "-------------openssl-fips-2.0 installation complete-----------------"
else
    cd $MDIR
    tar -xzvf openssl-fips-2.0.16.tar.gz >> /dev/null
    cd openssl-fips-2.0.16
    ./config && make && make install
    mstate
fi
}

mperl(){
if [ -d /usr/local/perl-5.10.1 ];then
    echo "-------------perl-5.10.1 installation complete----------------------"
else
    cd $MDIR
    tar -xzvf perl-5.10.1.tar.gz >> /dev/null
    cd perl-5.10.1
    ./configure.gnu -des -Dprefix=/usr/local/perl-5.10.1 && make && make install
    mstate
    export PATH=/usr/local/perl-5.10.1/bin:$PATH
fi
}
   
#openssl-1.1.0k
mopenssl(){
if [ -d /usr/local/openssl-1.1.0k ];then
    echo "---------------openssl-1.1.0k installation complete----------------"
else
    echo "-------------------Start setup openssl-----------------------------"
    cd $MDIR
    tar -xzvf openssl-1.1.0k.tar.gz >> /dev/null
    cd openssl-1.1.0k
    ./config --prefix=/usr/local/openssl-1.1.0k --with-fipslibdir=/usr/local/ssl/fips-2.0/lib/ && make && make install
    mstate
    grep /usr/local/openssl-1.1.0k/lib/ /etc/ld.so.conf
    if [ $? -ne 0 ];then
        echo "/usr/local/openssl-1.1.0k/lib/" >> /etc/ld.so.conf
    fi
    ldconfig
fi
}


#openssh-8.1p1
mopenssh(){
if [ -d /usr/local/openssh-8.1p1 ];then
    echo "---------------------openshh-8.0p1 installation complete----------"
else
    echo "----------------------Start setup openssh-------------------------"
    mopenssh_bak
    cd $MDIR
    tar -xzvf openssh-8.1p1.tar.gz >> /dev/null
    cd openssh-8.1p1
    ./configure --prefix=/usr/local/openssh-8.1p1 --sysconfdir=/etc/ssh --with-ssl-dir=/usr/local/openssl-1.1.0k --with-zlib=/usr/local/zlib-1.2.11 --with-md5-passwords && make && make install
    mstate
fi
}

#openssh bak
mopenssh_bak(){
echo "--------bak old openssh config files---------------------------------"
if [ -d /etc/ssh ];then
    mv /etc/ssh /etc/ssh_`date +%Y%m%d`
    echo "-----------------------/etc/ssh mv complete------------------------"
else
    echo "---------------------/etc/ssh no exist-----------------------------"
fi
}

#openssh config (redhat 5 6)
mopenssh_config(){
\cp -a $MDIR/openssh-8.1p1/contrib/redhat/sshd.init /etc/init.d/sshd
sed -i 's/SSHD=\/usr\/sbin\/sshd/SSHD=\/usr\/local\/openssh-8.1p1\/sbin\/sshd/g' /etc/init.d/sshd
sed -i 's/\/usr\/bin\/ssh-keygen -A/\/usr\/local\/openssh-8.1p1\/bin\/ssh-keygen -A/g' /etc/init.d/sshd
chkconfig --add sshd
chkconfig sshd on
}

mopenssh_config7(){

\cp -a $MDIR/openssh-8.1p1/contrib/redhat/sshd.init /etc/init.d/sshd
sed -i 's/SSHD=\/usr\/sbin\/sshd/SSHD=\/usr\/local\/openssh-8.1p1\/sbin\/sshd/g' /etc/init.d/sshd
sed -i 's/\/usr\/bin\/ssh-keygen -A/\/usr\/local\/openssh-8.1p1\/bin\/ssh-keygen -A/g' /etc/init.d/sshd
if [ -f /usr/lib/systemd/system/sshd.service ];then
    mv -f /usr/lib/systemd/system/ssh* $MDIR
    echo "-------------------move redhat7 systemctl sshd.service-----------"
else
    echo "-------------------redhat7 systemctl sshd.service no file--------"
fi
chkconfig --add sshd
chkconfig sshd on
}

#openssh path
mopenssh_path(){
grep "export PATH=/usr/local/openssh-8.1p1/bin:$PATH" /etc/profile
if [ $? -ne 0 ];then
    echo "export PATH=/usr/local/openssh-8.1p1/bin:$PATH" >> /etc/profile
    source /etc/profile
fi
}

magain(){
read -p "Please try again(y/Y) :" mresult
if [ $mresult == 'y' ] || [ $mresult == 'Y' ];then
    echo "***************************************************************"
else
    echo "**********************Question*********************************"
    exit 1 
fi
}

mrestart(){
echo "---------------------------sshd service restart--------------------"
service sshd restart

}

m5(){
echo "-------------------------------------------------------------------"
sleep 3
mzlib
echo "-------------------------------------------------------------------"
sleep 3
mopenssl_fips
echo "-------------------------------------------------------------------"
sleep 3
mperl
echo "-------------------------------------------------------------------"
sleep 3
mopenssl
echo "-------------------------------------------------------------------"
sleep 3
mopenssh
echo "-------------------------------------------------------------------"
sleep 3
mopenssh_config
echo "-------------------------------------------------------------------"
sleep 3
mopenssh_path
echo "-------------------------------------------------------------------"
}

m6(){
echo "-------------------------------------------------------------------"
sleep 3
mzlib
echo "-------------------------------------------------------------------"
sleep 3
mopenssl_fips
echo "-------------------------------------------------------------------"
sleep 3
mopenssl
echo "-------------------------------------------------------------------"
sleep 3
mopenssh
echo "-------------------------------------------------------------------"
sleep 3
mopenssh_config
echo "-------------------------------------------------------------------"
sleep 3
mopenssh_path
echo "-------------------------------------------------------------------"
}


m7(){
echo "-------------------------------------------------------------------"
sleep 3
mzlib
echo "-------------------------------------------------------------------"
sleep 3
mopenssl_fips
echo "-------------------------------------------------------------------"
sleep 3
mopenssl
echo "-------------------------------------------------------------------"
sleep 3
mopenssh
echo "-------------------------------------------------------------------"
sleep 3
mopenssh_config7
mopenssh_config
echo "-------------------------------------------------------------------"
sleep 3
mopenssh_path
echo "-------------------------------------------------------------------"
#mrestart
}
#system_release
echo "-------------------------system release----------------------------"
cat /etc/redhat-release 
echo "---------------------------select release--------------------------"
PS3="Please select a number(1,2,3,4) :"
select mrelease in redhat5 redhat6 redhat7 Quit
do
    case $mrelease in
    redhat5)
    echo "Start $mrelease Setup openssh"
    echo "---------------------you select redhat5----------------------"
    magain
    echo "--------------------------------------------------------------"
    m5
    echo "--------------------------------------------------------------"
    ;;
    redhat6)
    echo "Start $mrelease Setup openssh"
    echo "---------------------you select redhat6-----------------------"
    magain
    echo "--------------------------------------------------------------"
    m6
    echo "--------------------------------------------------------------"
    ;;
    redhat7)
    echo "Start $mrelease Setup openssh"
    echo "---------------------you select redhat7-----------------------"
    magain
    echo "--------------------------------------------------------------"
    m7
    echo "--------------------------------------------------------------"
    ;;
    Quit)
    echo "---------------------Goodble----------------------------------"
    exit 0
    ;;
    *)
    echo "---------------------Sorry, No release------------------------"
    ;;
    esac
done
