#!/bin/bash                         
# 脚本名:optimize.sh
# 目的:手游服务器优化部署
# 支持:今后不会部署centos5的系统.此脚本程序支持centos6* 64位和centos7* 64位
# By Tyler
# 2019/2/20
#




while true
do


optimize () {

while true
do

dialog --no-shadow --backtitle "北京掌上明珠科技股份有限公司				服务器部署优化工具	$back       Tyler   2016年3月9日" --title "主菜单" --ok-label "确定" --cancel-label "取消" --menu "请选择优化项目" 10 60 0 \
game   "[game服务器优化]" \
mdb    "[mdb主库服务器优化]" \
sdb    "[sdb从库服务器优化]" \
dell   "[DELL R410服务器网卡驱动升级]" \
keep   "[部署keepalived服务]" \
redis   "[部署redis master服务]" \
jambo   "[部署jambo entry和jambo adb服务]" \
jambo_node   "[创建游戏分区的节点数据库]" \
stat   "[部署统计服务器(暂停使用)]" \
q      "[退       出]" \
2> $outtmp

ni=`awk '{print}' $outtmp`

case $ni in

game)

info
	case $ans in 
	0)
	echo "游戏服务器参数优化开始，回车开始执行" 
	read
    myser=game
	baseopti
	gameopti
	;;
	*)
	break
	;;
	esac
;;

mdb)
info
	case $ans in 
	0)
	echo "主库服务器参数优化开始，回车开始执行" 	
	read
    myser=game
	baseopti
	masteropti
	;;
	*)
	break
	;;
	esac
;;

sdb)
info
	case $ans in 
	0)
	echo "从库服务器参数优化开始，回车开始执行" 
	read
    myser=slave
	baseopti
	slaveopti
	;;
	*)
	break
	;;
	esac
;;

dell)
echo "更新DELL服务器网卡驱动"
updatenetwork
;;

keep)
echo "部署keepalived服务"
keepalived
;;


redis)
echo "部署redis master服务"
redis_master
;;

jambo)
echo "部署jambo entry和jambo adb服务"
jambo
;;

jambo_node)
echo "创建游戏分区的节点数据库,如sanguo2_node1"
jambo_node
;;

stat)
echo "部署统计服务器"
pipstat_service
;;

q)
exit
;;

esac
done
}

baseopti () {

echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> 开始基础优化"

for a in crontabs dos2unix glibc.i686 iptables iptables-services libaio libnfnetlink libnfnetlink-devel libnl-devel lrzsz mailx mysql openssl-devel pcre-devel perl-DBD-MySQL perl-Time-HiRes popt popt-devel redhat-lsb sendmail systemtap tcl xz;do
rpm -q "$a" >/dev/null
if [ "$?" -ge 1 ];then
echo "正在安装$a，请等待"
yum -y install "$a"
echo "$a安装完成，请按任意键继续..."
read
fi
done

rpm -q vim-enhanced >/dev/null
if [ "$?" -ge 1 ]
then
echo "正在安装vim，请等待"
yum -y install vim*
echo "vim安装完成，请按任意键继续..."
read
fi



echo "正在安装gcc*(包含gcc-c++，这是编译命令g++的包)，请等待"
yum -y install gcc*
echo "gcc*安装完成，请按任意键继续..."
read



echo "部署openssh需要升级pam-devel包至最新的pam-devel-1.1.1-20.el6_7.1.x86_64"
yum -y install pam-devel zlib-devel

echo "更新bash到最新版"
yum -y update bash



echo ">>>>>部署openssl和openssh"
case "$myrelease" in
6*)

#输出1.0.2g
my_openssl=`openssl version -a|awk -F"[ -]" 'NR==1{print $2}'`
#输出OpenSSH_7.1p2 1.0.2g
my_openssh=`ssh -V 2>&1|awk -F"[ ,]" '{print $1,$4}'`

if [[ "$my_openssl"X == "1.0.2gX" && "$my_openssh"X == "OpenSSH_7.1p2 1.0.2gX" ]];then
echo "openssl($my_openssl)和openssh($my_openssh)无需部署."
else

echo "部署OpenSSL 1.0.2g"
scp $REMOTE1:$RPATH/openssl-1.0.2g.tar.gz /root/tmp
cd /root/tmp
tar xvzfp openssl-1.0.2g.tar.gz 
cd openssl-1.0.2g
echo "开始config"
./config --prefix=/usr/local/openssl1.0.2g --shared && (echo "config ok,回车继续";read)||(echo "config false,回车继续";exit)
echo "开始make"
make && (echo "make ok,回车继续";read)||(echo "make false,回车继续";exit)
echo "开始make install"
make install && (echo "make install ok,回车继续";read)||(echo "make install false,回车继续";exit)
mv /usr/include/openssl /usr/include/openssl.old
mv /usr/lib64/libssl.so /usr/lib64/libssl.so.old
ln -s -f /usr/local/openssl1.0.2g/include/openssl /usr/include/openssl
ln -s -f /usr/local/openssl1.0.2g/lib/libssl.so /usr/lib64/libssl.so
echo "/usr/local/openssl1.0.2g/lib" >> /etc/ld.so.conf
ldconfig -v 

echo "部署OpenSSH_7.1p2"
scp $REMOTE1:$RPATH/openssh-7.1p2.tar.gz /root/tmp
cd /root/tmp
tar xzvfp openssh-7.1p2.tar.gz
cd openssh-7.1p2
echo "开始configure"
./configure --prefix=/usr/local/openssh7.1p2 --sysconfdir=/etc/ssh --with-pam --with-ssl-dir=/usr/local/openssl1.0.2g --with-md5-passwords --mandir=/usr/share/man --with-zlib --with-tcp-wrappers --disable-strip && (echo "config ok,回车继续";read)||(echo "config false,回车继续";exit)
echo "开始make"
make && (echo "make ok,回车继续";read)||(echo "make false,回车继续";exit)
echo "开始make install"
make install && (echo "make install ok,回车继续";read)||(echo "make install false,回车继续";exit)
fi

;;
7*)
;;
esac




echo "部署java"
scp $REMOTE1:$RPATH/game_java.tar.gz /root/tmp
cd /root/tmp
tar xvzfp game_java.tar.gz 1>/dev/null
mv jdk1.* /usr/lib
ln -s -f /usr/lib/jdk1.8.0_144/bin/java /usr/bin/java



echo "部署xtrabackup2.4.7数据库备份工具"
scp $REMOTE1:$RPATH/xtrabackup2.4.7_64.tar.gz /root/tmp
cd /root/tmp
tar xvzfp xtrabackup2.4.7_64.tar.gz 1>/dev/null
mv xtrabackup2.4.7 /usr/local/xtrabackup



echo "部署sysstat11.2.1.1监控工具"
scp $REMOTE1:$RPATH/sysstat-11.2.1.1.tar.gz /root/tmp
cd /root/tmp
tar xvzfp sysstat-11.2.1.1.tar.gz 1>/dev/null
cd sysstat-11.2.1.1
./configure --prefix=/usr/local/sysstat11.2.1.1 && (echo "config ok,回车继续";read)||(echo "config false,回车继续";exit)
make && (echo "make ok,回车继续";read)||(echo "make false,回车继续";exit)
make install && (echo "make install ok,回车继续";read)||(echo "make install false,回车继续";exit)
sed -i '/^[^#]/s!/usr/lib[0-9]*!/usr/local/sysstat11.2.1.1/lib!' /etc/cron.d/sysstat



echo "部署enca1.19编码工具"
scp $REMOTE1:$RPATH/enca-1.19.tar.gz /root/tmp
cd /root/tmp
tar xvzfp enca-1.19.tar.gz 1>/dev/null
cd enca-1.19
./configure --prefix=/usr/local/enca1.19 && (echo "config ok,回车继续";read)||(echo "config false,回车继续";exit)
make && (echo "make ok,回车继续";read)||(echo "make false,回车继续";exit)
make check && (echo "make check ok,回车继续";read)||(echo "make check false,回车继续";exit)
make install && (echo "make install ok,回车继续";read)||(echo "make install false,回车继续";exit)



echo "添加定时任务定时清空防火墙"
echo "*/10 * * * * /sbin/iptables -F >/dev/null 2>&1">>/var/spool/cron/root



case "$myrelease" in
6*)
;;
7*)
echo "开机自动加载br_netfilter模块"
if [ -f /usr/lib/sysctl.d/00-system.conf ];then
[ -f /etc/sysconfig/modules/br_netfilter.modules ] && echo "/etc/sysconfig/modules/br_netfilter.modules文件已存在,br_netfilter模块未成功配置" || (echo "modprobe br_netfilter" > /etc/sysconfig/modules/br_netfilter.modules;chmod 755 /etc/sysconfig/modules/br_netfilter.modules)
else
echo "/usr/lib/sysctl.d/00-system.conf文件不存在,无需配置br_netfilter模块"
fi
;;
esac



case "$myrelease" in
6*)
;;
7*)
echo "删除虚拟网卡virbr0"
virsh net-destroy default
virsh net-undefine default
systemctl restart libvirtd.service
;;
esac



case "$myrelease" in
6*)
;;
7*)
echo "关闭firewalld并配置iptables开机自启"
systemctl stop firewalld.service
systemctl mask firewalld.service
systemctl enable iptables.service
;;
esac



echo "修改iptables"
scp $REMOTE1:$RPATH/game_iptables.cfg /root/iptables.cfg
iptables-restore </root/iptables.cfg
service iptables save
service iptables restart
scp $REMOTE1:$RPATH/motd /etc/motd



case "$myrelease" in
6*)
echo "修改语言编码/etc/sysconfig/i18n"
echo -e "LANG=\"zh_CN.UTF-8\"\nSUPPORTED=\"zh_CN.UTF-8:zh_CN:zh:en_US.UTF-8:en_US:en\"\nSYSFONT=\"latarcyrheb-sun16\"" >/etc/sysconfig/i18n
;;
7*)
;;
esac



echo "修改/etc/ssh/sshd_config"
sed -i 's/GSSAPIAuthentication yes/GSSAPIAuthentication no/' /etc/ssh/sshd_config
sed -i '/#UseDNS yes/a\UseDNS no' /etc/ssh/sshd_config
sed -i '/# override default of no subsystems/i\AllowUsers lighthu hwang yang.liu jianguang.wu pipstat gamebackup' /etc/ssh/sshd_config    
sed -i '/#   StrictHostKeyChecking ask/a\    StrictHostKeyChecking no' /etc/ssh/ssh_config
sed -i 's/^.*GSSAPIAuthentication yes/#&/g' /etc/ssh/ssh_config


case "$myrelease" in
6*)
echo "修改inittab选项"
sed -i 's/id:[0-6]:initdefault:/id:3:initdefault:/' /etc/inittab
;;
7*)
systemctl set-default multi-user.target
;;
esac


   
echo "修改软硬件最大连接数limits.conf"
sed -i '/# End of file/i\
* soft nofile 65536\
* hard nofile 65536\
* soft nproc 65536\
* hard nproc 65536\n' /etc/security/limits.conf
if [ -f /etc/security/limits.d/[29]0-nproc.conf ];then
sed -i -r 's/\*[[:blank:]]+soft[[:blank:]]+nproc[[:blank:]]+[0-9]+/* soft nproc 65536/' /etc/security/limits.d/[29]0-nproc.conf
fi



case "$myrelease" in
6*)
;;
7*)
echo "配置DNS服务器/etc/resolv.conf不被系统修改"
sed -i -r '/\[main]/{:a;$!n;s/(^$|\[)/dns=none\n\1/;t;$!ba;s/(^.*$)/\1\ndns=none/}' /etc/NetworkManager/NetworkManager.conf
systemctl restart NetworkManager.service
;;
esac



echo "修改DNS服务器/etc/resolv.conf"
/bin/cp -a /etc/resolv.conf /etc/resolv.conf.old
echo -e "nameserver 203.196.0.6\nnameserver 203.196.1.6\nnameserver 202.106.0.20\nnameserver 202.38.64.1" >/etc/resolv.conf
chattr +i /etc/resolv.conf



echo "部署7za工具"
scp $REMOTE1:$RPATH/game_7za /usr/local/bin/7za
chmod 755 /usr/local/bin/7za



echo "修改sudouser参数"
sed -i -r 's/^Defaults[[:blank:]]+requiretty/#&/' /etc/sudoers
sed -i '/## Allows members of the users group to mount and unmount the/i gamebackup ALL=(root) NOPASSWD: /sbin/service iptables save,/sbin/service iptables restart,/bin/mv,/sbin/iptables-restore,/sbin/iptables\n' /etc/sudoers



echo "创建vim快捷方式至vi"
mv /bin/vi /bin/vi.bak
ln -s -f /usr/bin/vim /bin/vi
sed -i '/^set bs=indent,eol,start/i set formatoptions+=mM' /etc/vimrc



echo "同步时间"
#echo "40 7 * * 2 /usr/sbin/ntpdate stdtime.gov.hk >/dev/null 2>&1; /sbin/hwclock -w">>/var/spool/cron/root
echo "40 7 * * 2 /usr/sbin/ntpdate asia.pool.ntp.org >/dev/null 2>&1; /sbin/hwclock -w">>/var/spool/cron/root
/usr/sbin/ntpdate asia.pool.ntp.org >/dev/null 2>&1; /sbin/hwclock -w
chmod 600 /var/spool/cron/root



echo "关闭selinux"
sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
setenforce 0



echo "添加用户"
id hwang > /dev/null 2>&1 && echo "user hwang already exists" || (useradd hwang ;echo "1qaz@WSX" | passwd hwang --stdin)
id gamebackup > /dev/null 2>&1 && echo "user gamebackup already exists" || (useradd gamebackup ;echo "bssooo5J-^" | passwd gamebackup --stdin)
id yang.liu > /dev/null 2>&1 && echo "user yang.liu already exists" || (useradd yang.liu ;echo "7544Lg&0" | passwd yang.liu --stdin)
id jianguang.wu > /dev/null 2>&1 && echo "user jianguang.wu already exists" || (useradd jianguang.wu ; echo "Xingtai@1024"  | passwd jianguang.wu --stdin)
id lighthu > /dev/null 2>&1 && echo "user lighthu already exists" || (useradd lighthu ;echo "Gambo76%11" | passwd lighthu --stdin)



echo "本地gamebackup用户信任60gamebackup用户"
mkdir -p /home/gamebackup/.ssh
chmod 700 /home/gamebackup/.ssh
cd /home/gamebackup/.ssh
scp $REMOTE1:$RPATH/60gamebackup_gongyao.pub ./authorized_keys
chmod 644 authorized_keys
cd /home/gamebackup
chown -R gamebackup.gamebackup .ssh



case "$myrelease" in
6*)
echo "关闭centos6中的NetworkManager服务"
if [ -f /etc/init.d/NetworkManager ];then
service NetworkManager stop
chkconfig NetworkManager off
fi
;;
7*)
echo "临时杀掉或停止centos7(内核版本3.10.0-693.el7至3.10.0-957.el7)中的下列服务,这样才能对/home实行mv操作(内核升级到3.18+再确认是否还存在此问题)"
echo "杀掉NetworkManager服务"
systemctl kill NetworkManager.service
echo "停止NTP client/server服务"
systemctl stop chronyd.service
sleep 20
;;
esac



echo "调整文件系统目录结构"
mv /etc/my.cnf /etc/my.cnf.old
mv /bin/su /bin/dd2
mkdir -p /data1
#防止mv /home失败
mytmp=`grep -h home /proc/*/task/*/mountinfo|sort -u`
[ -z "${mytmp}" ] && { echo "无关联home的mountinfo,继续执行mv /home操作";mv /home /data1/home;ln -s -f /data1/home /home;} || { echo "警告:存在关联home的mountinfo,未执行mv /home操作";echo "${mytmp}";}
echo "回车继续"
read
	
if [ -b /dev/sdb ] || [ -b /dev/cciss/c0d1 ];then
    mkdir -p /data1/data5
    ln -s -f /data1/data5 /data5
    chown gamebackup.gamebackup /data1
    chown gamebackup.gamebackup /data2
    chown gamebackup.gamebackup /data1/data5
else
    mkdir -p /data1/data2
    mkdir -p /data1/data5
    ln -s -f /data1/data2 /data2
    ln -s -f /data1/data5 /data5
    chown gamebackup.gamebackup /data1
    chown gamebackup.gamebackup /data1/data2
    chown gamebackup.gamebackup /data1/data5
fi
mkdir -p /home/hwang/packets
chown hwang.hwang /home/hwang/packets



case "$myrelease" in
6*)
;;
7*)
echo "启动centos7中刚刚杀掉的NetworkManager服务"
systemctl start NetworkManager.service
echo "启动centos7中刚刚停止的NTP client/server服务"
systemctl start chronyd.service
;;
esac



case "$myrelease" in
6*)
;;
7*)
echo "为/etc/rc.d/rc.local增加执行权限"
chmod 755 /etc/rc.d/rc.local
;;
esac



echo "部署srvreport系统报告工具"
echo "1-46/15 * * * * /data1/srvreport-0.71/bin/srvreport.pl">>/var/spool/cron/root
scp $REMOTE1:$RPATH/srvreport-0.71_pip.tar.gz /data1
cd /data1
tar xzvfp srvreport-0.71_pip.tar.gz 1>/dev/null
rm -rf /data1/srvreport-0.71_pip.tar.gz



echo "部署程序备份模块"
mkdir -p /data2/pcbackup
mkdir -p /root/sh
touch  /root/sh/pcbackup.log
scp $REMOTE1:$RPATH/mobile_pcbackup.sh /root/sh/pcbackup.sh
chown gamebackup.gamebackup /data2/pcbackup
chmod 775 /data2/pcbackup
chown root.root /root/sh/pcbackup.sh
chmod 700 /root/sh/pcbackup.sh
echo "30 00 * * * /root/sh/pcbackup.sh >/root/sh/pcbackup.log 2>&1">>/var/spool/cron/root



echo "部署监控模块"
mkdir -p /root/monitor
chmod 755 /root
chmod 777 /root/monitor
scp $REMOTE1:$RPATH/game_monitor_NewSmsSend.jar /root/sh/NewSmsSend.jar
scp $REMOTE1:$RPATH/${myser}_monitor.sh /root/sh/monitor.sh
chown root.root /root/sh/NewSmsSend.jar /root/sh/monitor.sh
chmod 700 /root/sh/monitor.sh
touch /root/sh/monitor.log
echo "*/10 * * * * /root/sh/monitor.sh>>/root/sh/monitor.log 2>&1">>/var/spool/cron/root




#统一修改环境变量配置文件/etc/profile,定义JAVA_HOME,添加openssl和openssh的路径,定义语言编码环境
echo "统一修改/etc/profile"
case "$myrelease" in
6*)
sed -i '/^export PATH/i \
JAVA_HOME="/usr/lib/jdk1.6.0_23" \
LANG="zh_CN.UTF-8" \
LC_ALL="zh_CN.UTF-8" \
PATH=/usr/local/enca1.19/bin:/usr/lib/jdk1.8.0_144/bin:/usr/local/sysstat11.2.1.1/bin:/usr/local/openssh7.1p2/bin:/usr/local/openssl1.0.2g/bin:/usr/local/xtrabackup/bin:$PATH' /etc/profile
;;
7*)
sed -i '/^export PATH/i \
JAVA_HOME="/usr/lib/jdk1.6.0_23" \
LANG="zh_CN.UTF-8" \
LC_ALL="zh_CN.UTF-8" \
PATH=/usr/local/enca1.19/bin:/usr/lib/jdk1.8.0_144/bin:/usr/local/sysstat11.2.1.1/bin:/usr/local/xtrabackup/bin:$PATH' /etc/profile
;;
esac
sed -i 's/^export PATH.*/& JAVA_HOME LANG LC_ALL/' /etc/profile
echo "-end"



}

gameopti () {

echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> 开始游戏优化"


echo "创建用户"
id pipstat > /dev/null 2>&1 && echo "user pipstat already exists" || (useradd pipstat ;echo "umhd1D]]" | passwd pipstat --stdin)



echo "本地pipstat用户信任88pipstat用户(统计部门)"
mkdir -p /home/pipstat/.ssh
chmod 700 /home/pipstat/.ssh
cd /home/pipstat/.ssh
scp $REMOTE1:$RPATH/88pipstat_gongyao.pub ./authorized_keys
chmod 644 authorized_keys
cd /home/pipstat
chown -R pipstat.pipstat .ssh



echo "部署logparser模块"
mkdir -p /data2/logparser/gamepc /data2/logparser/result /data2/logparser/statagent /data2/logparser/xmlroot /data2/logparser/myshell
mkdir -p /data1/pipstat/sgagent /data1/pipstat/sgstatlog /data1/pipstat/sgtemp
scp $REMOTE1:$RPATH/checkmycron.sh /data2/logparser/myshell/checkmycron.sh
chmod 740 /data2/logparser/myshell/checkmycron.sh
chown -R pipstat.pipstat /data2/logparser 
chown -R pipstat.pipstat /data1/pipstat
echo "00 02 * * * /data1/pipstat/sgagent/sgagent_ex.sh >/dev/null 2>&1">>/var/spool/cron/pipstat
echo "dd2 - pipstat -c \"/data2/logparser/myshell/checkmycron.sh\"" >>/etc/rc.local




echo "部署日志查询模块,默认存放位置:/home/gamebackup"
scp $REMOTE1:$RPATH/logqeuryagent.tar.gz /home/gamebackup
cd /home/gamebackup
tar xvzfp logqeuryagent.tar.gz 1>/dev/null
chown -R gamebackup.gamebackup logqeuryagent
echo -e '
dd2 - gamebackup -c "
cd logqeuryagent
./startup.sh start
"
' >>/etc/rc.local


echo "重启ssh服务"
service sshd restart


cat <<EOF

###############################################################################
#
# 请立即执行以下步骤,完成剩余工作
#
# 1. 主机名和hosts文件手动改
# 2. 部署pcbackup备份脚本,请检查DNS服务是否正常
# 3. IDC上架后,本地服务器信任88pipstat,60gamebackup
# 4. 如是合作伙伴服务器,请检查防火墙是否允许登录并测试
# 5. 请修改/data1/srvreport-0.71/bin/srvreport.conf 中描述信息为本机实际IP
# 6. 如确认如上都正确后，请将定时任务中的每10分钟取消防火墙策略取消---->
# 
################################################################################


EOF
echo "回车继续."
read


}

masteropti () {

echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> 开始mdb主库优化"


echo "安装主库"
id mysql > /dev/null 2>&1 && echo "user mysql already exists" || useradd -s /bin/false mysql
scp $REMOTE1:$RPATH/mysql5_mobile.tar.gz /data1
cd /data1
tar xvzfp mysql5_mobile.tar.gz 1>/dev/null
echo -e '#!/bin/bash\n# chkconfig: 3 15 60'>/data1/mysql5/data/master_mysql5_innodb_3306
chown root.root /data1/mysql5/data/master_mysql5_innodb_3306
chmod 700 /data1/mysql5/data/master_mysql5_innodb_3306



echo "添加mysql启动"
case "$myrelease" in
6*)
mv -f /etc/init.d/mysqld /etc/init.d/mysqld.old
ln -s -f /data1/mysql5/data/master_mysql5_innodb_3306 /etc/init.d/mysqld
chkconfig --add mysqld
chkconfig --level 3 mysqld on
;;
7*)
cd /usr/lib/systemd/system
cat <<EOF >mysqld.service
[Unit]
Description=明珠mysql启动控制脚本
After=network.target

[Service]
Type=forking
ExecStart=/data1/mysql5/data/master_mysql5_innodb_3306 start
#ExecReload=
ExecStop=/data1/mysql5/data/master_mysql5_innodb_3306 stop
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable mysqld.service
;;
esac



echo "重启ssh服务"
service sshd restart


cat <<EOF

###############################################################################
#
# 请立即执行以下步骤,完成剩余工作
#
# 1. 主机名和hosts文件手动改
# 2. 部署pcbackup备份脚本,检查DNS服务是否正常
# 3. IDC上架后60gamebackup到本服务器的单向信任
# 4. 如是合作伙伴服务器,请检查防火墙是否允许登录并测试
# 5. 请修改/data1/srvreport-0.71/bin/srvreport.conf 中描述信息为本机实际IP
# 6. 如确认如上都正确后，请将定时任务中的每10分钟取消防火墙策略取消---->
#
###############################################################################


EOF
echo "回车继续..."
read



}

slaveopti () {


echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> 开始sdb从库优化"



echo "生成数据库备份模块"
mkdir /data2/dbbackup_slave
chown gamebackup.gamebackup /data2/dbbackup_slave
touch /root/sh/dbbackup.sh /root/sh/dbbackup.log
chown root.root /root/sh/dbbackup.sh
chmod 700 /root/sh/dbbackup.sh
echo "00 01-12,14-23 * * * /root/sh/dbbackup.sh > /root/sh/dbbackup.log 2>&1">>/var/spool/cron/root



echo "安装从库"
id mysql > /dev/null 2>&1 && echo "user mysql already exists" || useradd -s /bin/false mysql
scp $REMOTE1:$RPATH/mysql5_mobile.tar.gz /data1
cd /data1
tar xvzfp mysql5_mobile.tar.gz 1>/dev/null
mv mysql5 backmysql5_3306
echo -e '#!/bin/bash\n# chkconfig: 3 15 60'>/data1/backmysql5_3306/data/slave_mysql5_innodb_3306
chown root.root /data1/backmysql5_3306/data/slave_mysql5_innodb_3306
chmod 700 /data1/backmysql5_3306/data/slave_mysql5_innodb_3306



echo "添加mysql启动"
case "$myrelease" in
6*)
mv -f /etc/init.d/mysqld /etc/init.d/mysqld.old
ln -s -f /data1/backmysql5_3306/data/slave_mysql5_innodb_3306 /etc/init.d/mysqld
chkconfig --add mysqld
chkconfig --level 3 mysqld on
;;
7*)
cd /usr/lib/systemd/system
cat <<EOF >mysqld.service
[Unit]
Description=明珠mysql启动控制脚本
After=network.target

[Service]
Type=forking
ExecStart=/data1/backmysql5_3306/data/slave_mysql5_innodb_3306 start
#ExecReload=
ExecStop=/data1/backmysql5_3306/data/slave_mysql5_innodb_3306 stop
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable mysqld.service
;;
esac



echo "重启ssh服务"
service sshd restart


cat <<EOF

#############################################################################
#
# 请立即执行以下步骤,完成剩余工作
#
# 1. 主机名和hosts文件手动改
# 2. 部署pcbackup备份脚本,请检查DNS服务是否正常
# 3. IDC上架后60gamebackup到本服务器的单向信任
# 4. 如是合作伙伴服务器，请检查防火墙是否允许登录并测试
# 5. 请修改/data1/srvreport-0.71/bin/srvreport.conf 中描述信息为本机实际IP
# 6. 如确认如上都正确后，请将定时任务中的每10分钟取消防火墙策略取消---->
# 
#############################################################################


EOF
echo "回车继续..."
read

}

updatenetwork () {

scp $REMOTE1:$RPATH/linux-6.2.23.zip /home/hwang/packets
cd /home/hwang/packets
rm -rf temp
mkdir temp
cd temp
lsmod | grep "bnx2 "
echo "旧网卡驱动号，请按回车继续"
read

unzip ../linux-6.2.23.zip >/dev/null
cd Server/Linux/Driver
tar xzvfp netxtreme2-6.2.23.tar.gz >/dev/null
cd netxtreme2-6.2.23/bnx2/src
make
make install
rmmod bnx2
depmod
modprobe bnx2
cd /home/hwang
rm -rf temp
lsmod | grep "bnx2 "
echo "网卡驱动升级完毕，请按回车返回"
read
}

keepalived () {


echo "安装"
[ -f /etc/keepalived/keepalived.conf ] && mv -f /etc/keepalived/keepalived.conf /etc/keepalived/keepalived.conf.old
[ -f /etc/sysconfig/keepalived ] && mv -f /etc/sysconfig/keepalived /etc/sysconfig/keepalived.old
[ -f /sbin/keepalived ] && mv -f /sbin/keepalived /sbin/keepalived.old
scp $REMOTE1:$RPATH/keepalived-1.1.17.tar.gz /home/hwang/packets
cd /home/hwang/packets
tar xvzfp keepalived-1.1.17.tar.gz 1>/dev/null
cd keepalived-1.1.17
./configure --prefix=/usr/local/keepalived1.1.17 --sysconf=/etc 1>/dev/null
make 1>/dev/null
make install 1>/dev/null

ln -s /usr/local/keepalived1.1.17/sbin/keepalived /usr/sbin

echo "拷贝需要的脚本"
scp $REMOTE1:$RPATH/check_mysql.sh /etc/keepalived
scp $REMOTE1:$RPATH/takeover.sh /etc/keepalived
scp $REMOTE1:$RPATH/recovery.sh /etc/keepalived
chmod 700 /etc/keepalived/check_mysql.sh
chmod 700 /etc/keepalived/takeover.sh
chmod 700 /etc/keepalived/recovery.sh



echo "添加keepalived启动"
case "$myrelease" in
6*)
sed -i 's/# chkconfig: .*/# chkconfig: 3 80 80/' /etc/init.d/keepalived
chkconfig --add keepalived
chkconfig --level 3 keepalived on
;;
7*)
cd /usr/lib/systemd/system
cat <<EOF >keepalived.service
[Unit]
Description=明珠LVS and VRRP High Availability Monitor启动控制脚本
After=syslog.target network.target

[Service]
Type=forking
KillMode=process
EnvironmentFile=-/etc/sysconfig/keepalived
ExecStart=/usr/local/keepalived1.1.17/sbin/keepalived \$KEEPALIVED_OPTIONS
ExecReload=/bin/kill -HUP \$MAINPID
#ExecStop=
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable keepalived.service
;;
esac


echo "修改环境变量"
sed -i 's!^PATH=!&/usr/local/keepalived1.1.17/sbin:!' /etc/profile


echo "keepalived服务部署完毕,请定义配置文件,回车继续"
read



}

redis_master () {


#定义变量
redisport="6379"
redisbackmod="redis_backup_bendi.sh"


echo -e "<<<支持1台服务器部署多个redis.\033[0;31;7m
redis端口号：${redisport}
redis备份模式是本地(bendi)还是异地(yidi)：${redisbackmod}
正确请按y,错误请回车.
\033[0m"
read inp

[[ "$inp" == "y" ]] && echo "ok" || exit


echo "传包"
scp $REMOTE1:$RPATH/redis-2.8.8.tar.gz /root/tmp
cd /root/tmp
tar xvzfp redis-2.8.8.tar.gz
cd redis-2.8.8

echo "编译"
make && { echo "make ok,回车继续";read;}||{ echo "make false";exit;}
make test && { echo "make test ok,回车继续";read;}||{ echo "make test false";exit;}
make PREFIX=/data1/redis2.8.8_${redisport} install && { echo "make install ok,回车继续";read;}||{ echo "make install false";exit;}

echo "修改配置文件和执行脚本"
cd /root/tmp
sed -i 's/pipgameredisport/'"$redisport"'/g' redis_single.conf redis_master.conf redis_master redis-check-sync ${redisbackmod}

echo "传输配置文件和执行脚本"
mkdir -p /data1/redis2.8.8_${redisport}/conf /data1/redis2.8.8_${redisport}/master1_${redisport}/conf /data2/redis_backup/redis_${redisport}
cp -a /root/tmp/redis_single.conf /data1/redis2.8.8_${redisport}/conf/redis.conf
cp -a /root/tmp/redis_master.conf /data1/redis2.8.8_${redisport}/master1_${redisport}/conf/redis.conf
cp -a /root/tmp/redis_master /data1/redis2.8.8_${redisport}/master1_${redisport}/conf/redis
cp -a /root/tmp/redis-check-sync /data1/redis2.8.8_${redisport}/master1_${redisport}/conf/redis-check-sync
[[ -f /root/sh/redis_backup.sh ]] && mv /root/sh/redis_backup.sh /root/sh/redis_backup.sh.old
cp -a /root/tmp/${redisbackmod} /root/sh/redis_backup.sh

echo "传输导入导出工具"
rsync -avzuP /root/tmp/redis_dump /data1/redis2.8.8_${redisport}

echo "创建链接,修改属主和权限,增加备份的定时任务"
ln -s -f /data1/redis2.8.8_${redisport}/master1_${redisport}/conf/redis /data1/redis2.8.8_${redisport}/bin/redis
ln -s -f /data1/redis2.8.8_${redisport}/master1_${redisport}/conf/redis-check-sync /data1/redis2.8.8_${redisport}/bin/redis-check-sync
ln -s -f /data1/redis2.8.8_${redisport}/redis_dump/redis-dump.sh /data1/redis2.8.8_${redisport}/bin/redis-dump
ln -s -f /data1/redis2.8.8_${redisport}/redis_dump/redis-load.sh /data1/redis2.8.8_${redisport}/bin/redis-load
ln -s -f /data1/redis2.8.8_${redisport}/redis_dump/redis-clear.sh /data1/redis2.8.8_${redisport}/bin/redis-clear
chown -R gamebackup.gamebackup /data1/redis2.8.8_${redisport} /data2/redis_backup
chown root.root /root/sh/redis_backup.sh
chmod 700 /root/sh/redis_backup.sh
echo "01 */2 * * * /root/sh/redis_backup.sh > /root/sh/redis_backup.log 2>&1">>/var/spool/cron/root

echo "修改环境变量"
case "$myrelease" in
6*)
echo "vm.overcommit_memory=1" >> /etc/sysctl.conf 
/sbin/sysctl -p /etc/sysctl.conf
;;
7*)
echo "vm.overcommit_memory=1" >> /usr/lib/sysctl.d/00-system.conf
/sbin/sysctl -p /usr/lib/sysctl.d/00-system.conf
;;
esac
#由于支持1台服务器部署多个redis,所以不再更改/etc/profile
#sed -i 's!^PATH=!&/data1/redis2.8.8_${redisport}/bin:!' /etc/profile
echo "-end"



cat <<EOF

###############################################################################
#
# 请立即执行以下步骤,完成剩余工作
#
# 1. 如果是睿江/昌平/世纪互联:
#   请检查/root/redis_backup.sh中是否正确配置了异地备份服务器的IP:211.151.99.90等
#   gamebackup@211.151.99.90信任gamebackup@本机,redis传输异地备份包到90
# 2. 如果是金山/Amazon,请检查/root/redis_backup.sh,暂时不做异地备份 
# 
################################################################################


EOF
echo "回车继续."
read


}

jambo () {

#定义变量
dbroot="admin"
dbrootpass="KS@@dbroot@@2008"
gname="sanguo2"
dbuser="sanguo2"
dbpass="yes&2009@at"
ip_adb="10.10.255.245"
entry_ip="10.10.32.3"
entry_port="4306"
#entry_s_port="5306"


echo -e "\033[0;31;7m
数据库管理员：$dbroot
数据库管理员密码：$dbrootpass
游戏产品：$gname
数据库游戏用户：$dbuser
数据库游戏用户密码：$dbpass
jambo adb管理库的IP：$ip_adb
jambo entry入口的IP：$entry_ip
jambo entry入口的端口号：$entry_port
#查询用jambo entry入口的端口号：$entry_s_port    
正确请按y,错误请回车.
\033[0m"
read inp

[[ "$inp" == "y" ]] && echo "ok" || exit

echo "部署jambo entry"
id gameadmin > /dev/null 2>&1 && echo "user gameadmin already exists" || { useradd gameadmin;echo "LLLGGG2g#C" | passwd gameadmin --stdin;}
echo "传包"
scp $REMOTE1:$RPATH/jambo1_0_0.tar.gz /root/tmp
mkdir -p /home/gameadmin/${gname}_jambo
cd /home/gameadmin/${gname}_jambo
tar xvzfp /root/tmp/jambo1_0_0.tar.gz
#cd /home/gameadmin
#cp -a ${gname}_jambo ${gname}_jambo_s
cd /home
chown -R gameadmin.gameadmin gameadmin
chmod 750 gameadmin
usermod -G gameadmin hwang


echo "部署jambo adb"
mysql -u$dbroot -p$dbrootpass -h $ip_adb -P 3306 -A <<EOF

#部署adb
create database ${gname}_adb charset=utf8;
#create database ${gname}_adb_s charset=utf8;
grant all on ${gname}_adb.* to ${dbuser}@'%' identified by '${dbpass}';
grant all on ${gname}_adb.* to ${dbuser}@'localhost' identified by '${dbpass}';
#grant all on ${gname}_adb_s.* to ${dbuser}@'%' identified by '${dbpass}';
#grant all on ${gname}_adb_s.* to ${dbuser}@'localhost' identified by '${dbpass}';


#导入表结构及数据,删除jambo_node表中的初始内容
use ${gname}_adb;
source /home/gameadmin/${gname}_jambo/jambo.sql;
delete from jambo_node where id<=2;
#use ${gname}_adb_s;
#source /home/gameadmin/${gname}_jambo_s/jambo.sql;
#delete from jambo_node where id<=2;


#插入触发器
#delimiter //
#use ${gname}_adb
#create trigger jambo_table_ai
#after insert on ${gname}_adb.jambo_table
#for each row
#insert into ${gname}_adb_s.jambo_table values(new.name,new.shards,new.keytype,new.shardtonode);
#//
#delimiter ;


#更新触发器
#delimiter //
#use ${gname}_adb
#create trigger jambo_table_au
#after update on ${gname}_adb.jambo_table
#for each row
#update ${gname}_adb_s.jambo_table set #${gname}_adb_s.jambo_table.name=new.name,${gname}_adb_s.jambo_table.shards=new.shards,${gname}_adb_s.jambo_table.keytype=new.keytype,${gname}_adb_s.jambo_table.shardtonode=new.shardtonode #where ${gname}_adb_s.jambo_table.name=old.name;
#//
#delimiter ;


#删除触发器
#delimiter //
#use ${gname}_adb
#create trigger jambo_table_ad
#after delete on ${gname}_adb.jambo_table
#for each row
#delete from ${gname}_adb_s.jambo_table where ${gname}_adb_s.jambo_table.name=old.name;
#//
#delimiter ;


EOF


echo "生成jambo entry 的 jambo.xml"
cd /home/gameadmin/${gname}_jambo
myxml=`cat <<EOF
<?xml version="1.0" encoding="UTF-8" ?>
<jambo_config>
    <mdb_url>jdbc:mysql://${ip_adb}:3306/${gname}_adb?useUnicode=true&amp;characterEncoding=UTF-8</mdb_url>
    <mdb_user>${dbuser}</mdb_user>
    <mdb_pass>${dbpass}</mdb_pass>
    <name>entry1</name>
    <listen_address>${entry_ip}</listen_address>
    <listen_port>${entry_port}</listen_port>
</jambo_config>
EOF`
echo "$myxml">jambo.xml
# 三国2的数据库密码特殊,带&符号,所以要修改一下jambo.xml的内容,把&改成&amp;
sed -i '/mdb_pass/s/&/&amp;/' jambo.xml


#echo "生成查询用 jambo entry 的 jambo.xml"
#cd /home/gameadmin/${gname}_jambo_s
#myxml=`cat <<EOF
#<?xml version="1.0" encoding="UTF-8" ?>
#<jambo_config>
#    <mdb_url>jdbc:mysql://${ip_adb}:3306/${gname}_adb_s?useUnicode=true&amp;characterEncoding=UTF-8</mdb_url>
#    <mdb_user>${dbuser}</mdb_user>
#    <mdb_pass>${dbpass}</mdb_pass>
#    <name>entry_s</name>
#    <listen_address>${entry_ip}</listen_address>
#    <listen_port>${entry_s_port}</listen_port>
#</jambo_config>
#EOF`
#echo "$myxml">jambo.xml
#sed -i '/mdb_pass/s/&/&amp;/' jambo.xml

echo "-end"



cat <<EOF

###############################################################################
#
# jambo entry 和 jambo adb 部署完成,请继续以下工作
#
# 用gameadmin用户手动启动jambo
# cd /home/gameadmin/${gname}_jambo
# ./startup.sh
# cd /home/gameadmin/${gname}_jambo_s
# ./startup.sh
#
# 验证jambo服务启动
# curl "http://${entry_ip}:${entry_port}/status"
# curl "http://${entry_ip}:${entry_s_port}/status"
# 
################################################################################


EOF
echo "回车继续."
read


}

jambo_node () {

#创建游戏分区的节点数据库，如sanguo2_node1

#定义变量
dbroot="admin"
dbrootpass="KS@@dbroot@@2008"
gname="sanguo2"
dbuser="sanguo2"
dbpass="yes&2009@at"
ip_adb="10.10.255.245"
mip_node="10.10.255.245"
#sip_node="10.10.30.241"
nodex="node1"


echo -e "\033[0;31;7m
数据库管理员：$dbroot
数据库管理员密码：$dbrootpass
游戏产品：$gname
数据库游戏用户：$dbuser
数据库游戏用户密码：$dbpass
jambo adb管理库的IP：$ip_adb
jambo node的主库IP，要向adb中的表中插入这个IP：$mip_node
#jambo node的查询从库IP，要向adb_s中的表中插入这个IP：$sip_node
这是哪个节点：$nodex
正确请按y,错误请回车.
\033[0m"
read inp

[[ "$inp" == "y" ]] && echo "ok" || exit


#创建节点数据库
mysql -u$dbroot -p$dbrootpass -h $mip_node -P 3306 -A <<EOF


create database ${gname}_${nodex} charset=utf8;
grant all on ${gname}_${nodex}.* to ${dbuser}@'%' identified by '${dbpass}';
grant all on ${gname}_${nodex}.* to ${dbuser}@'localhost' identified by '${dbpass}';

EOF


#向jambo adb和jambo adb_s中插入jambo node信息

mysql -u$dbroot -p$dbrootpass -h $ip_adb -P 3306 -A <<EOF

use ${gname}_adb
insert into jambo_node(id,dburl,dbuser,dbpassword) value('0','jdbc:mysql://${mip_node}:3306/${gname}_${nodex}?useUnicode=true&characterEncoding=UTF-8','${dbuser}','${dbpass}');

#use ${gname}_adb_s
#insert into jambo_node(id,dburl,dbuser,dbpassword) value('0','jdbc:mysql://${sip_node}:3306/${gname}_${nodex}?useUnicode=true&characterEncoding=UTF-8','${dbuser}','${dbpass}');


EOF


echo "-end"



cat <<EOF

###############################################################################
#
# jambo node 部署完成,请继续以下工作
#
# 验证游戏分区的节点数据库是否正确创建，权限是否正确
# 验证管理adb中的jambo_node表中是否正确插入游戏分区节点数据库信息
# 在第一个jambo node上，要创建一个常规的游戏分区数据库并赋sanguo2和pipcount的权限，比如sanguo2_0001
# 
################################################################################


EOF
echo "回车继续."
read


}

info () {
message=`cat <<EOF

重要提示！！！(防火墙信息)
================================================

如果您现在优化的是合作服务器，请先更新防火墙配置文件，
增加合作服务器的IP地址段。确认请继续优化...........

================================================
EOF`

dialog --backtitle "警告页面" --title "防火墙配置" --no-shadow --yesno "$message" 20 60  
ans=`echo $?`
}

pipstat_service () {

echo -e "----------------------------------------------------------
此功能暂停使用:
今后数据平台都使用88,因此这部分正常情况下无需部署;
极特殊情况下可能会部署这部分,比如海外合作服务器和88无法正常通讯时;
部署内容包括统计用mysql和平台应用程序tomcat;
部署时尽量部署到单独的服务器,或者选择从库服务器.
----------------------------------------------------------"
read
exit


echo "创建pipstat用户"
id pipstat > /dev/null 2>&1 && echo "user pipstat already exists" || (useradd pipstat ;echo "umhd1D]]" | passwd pipstat --stdin)


echo "本地pipstat用户信任88pipstat用户(统计部门)"
mkdir -p /home/pipstat/.ssh
chmod 700 /home/pipstat/.ssh
cd /home/pipstat/.ssh
scp $REMOTE1:$RPATH/88pipstat_gongyao.pub ./authorized_keys
chmod 644 authorized_keys
cd /home/pipstat
chown -R pipstat.pipstat .ssh



echo "安装统计数据库"
cd /data1
id mysql > /dev/null 2>&1 && echo "user mysql already exists" || useradd -s /bin/false mysql
scp $REMOTE1:$RPATH/mysql5_mobile.tar.gz /data1
tar xvzfp mysql5_mobile.tar.gz
scp $REMOTE1:$RPATH/pipstat_mysql5_9000 /data1/mysql5/data/mysql5_innodb_9000
ln -s -f /data1/mysql5/data/mysql5_innodb_9000 /etc/init.d/mysqld_9000
chkconfig --add mysqld_9000
chkconfig --level 3 mysqld_9000 on


echo "安装统计用tomcat,统一端口为9001和9002"
scp $REMOTE1:$RPATH/tomcat_pipstat.tar.gz /home/pipstat
cd /home/pipstat
tar xvzfp tomcat_pipstat.tar.gz 1>/dev/null
/bin/cp -a tomcat_9001 tomcat_9002
/bin/cp -a tomcat_9001/conf/server.xml.9001 tomcat_9001/conf/server.xml
/bin/cp -a tomcat_9002/conf/server.xml.9002 tomcat_9002/conf/server.xml
chown -R pipstat.pipstat /home/pipstat
scp $REMOTE1:$RPATH/startup_pipstat_tomcat.sh /etc/init.d/tomcat_pipstat 1>/dev/null

chkconfig --add tomcat_pipstat
chkconfig --level 3 tomcat_pipstat on
ln -s -f /home/pipstat/tomcat_9001 /data5/tomcat_9001
ln -s -f /home/pipstat/tomcat_9002 /data5/tomcat_9002
/etc/init.d/tomcat_pipstat start

echo -e "-------------------------------------
统计环境已部署完毕
统计库路径:/data3/mysql5  Port:9000
统计tomcat路径如下: 
/home/pipstat/tomcat_9001
/home/pipstat/tomcat_9002
-------------------------------------"
netstat -nalp|grep -E "9001|9002"




echo "回车返回"
read
}

trap "" 2 3




#定义临时文件
my_process=$$
outtmp=/tmp/$my_process-`date +%s-%N`.outtmp
errtmp=/tmp/$my_process-`date +%s-%N`.errtmp

#创建部署包存放的临时目录
mkdir -p /root/tmp
REMOTE1=root@192.168.0.10
RPATH=/root/optimize/conf

#清空临时文件
rm -rf /tmp/$my_process-[0-9]*-[0-9]*.errtmp /tmp/$my_process-[0-9]*-[0-9]*.outtmp

#判断当前操作系统的版本信息
yum install redhat-lsb -y
myrelease=`lsb_release -a|awk '/Release/{print $2}'`

#判断当前服务器是否执行优化
id lighthu >/dev/null 2>&1 && id gamebackup >/dev/null 2>&1 && echo "此服务器已优化" && exit  


#必须使用root用户直接登录执行优化，由普通用户su后执行优化会导致无法正确移动/home目录
if [ `whoami` == root ];then

rpm -q dialog >/dev/null
if [ "$?" -ge 1 ];then
echo "正在安装dialog，请等待"
yum -y install dialog
echo "dialog安装完成，请按任意键继续..."
read
fi

optimize

else
echo "您所执行的用户不是root用户"
exit
fi

done
#脚本结束


