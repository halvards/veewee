date > /etc/vagrant_box_build_time

fail()
{
  echo "FATAL: $*"
  exit 1
}

yum -y erase avahi bitstream-vera-fonts freetype gtk2 hicolor-icon-theme libX11 wireless-tools *i386 *i586 *i686
yum -y install bzip2 gcc kernel-devel-`uname -r` make yum-priorities
yum -y --exclude=kernel* update

cat > /etc/yum.repos.d/puppetlabs.repo << EOM
[puppetlabs]
name=puppetlabs
baseurl=http://yum.puppetlabs.com/el/5/products/\$basearch
enabled=1
gpgcheck=0
EOM

cat > /etc/yum.repos.d/epel.repo << EOM
[epel]
name=epel
baseurl=http://download.fedoraproject.org/pub/epel/5/\$basearch
enabled=1
gpgcheck=0
EOM

cat > /etc/yum.repos.d/rbel.repo << EOM
[rbel]
name=rbel
baseurl=http://rbel.frameos.org/stable/el5/\$basearch
enabled=1
gpgcheck=0
EOM

yum -y install facter puppet ruby-devel.x86_64 rubygems || fail "Could not install puppet"
#yum -y clean all
rm /etc/yum.repos.d/{puppetlabs,epel,rbel}.repo

#gem install --no-ri --no-rdoc chef || fail "Could not install chef"

#Installing vagrant keys
mkdir /home/vagrant/.ssh
chmod 700 /home/vagrant/.ssh
cd /home/vagrant/.ssh
wget --no-check-certificate 'http://github.com/mitchellh/vagrant/raw/master/keys/vagrant.pub' -O authorized_keys
chown -R vagrant /home/vagrant/.ssh

#Installing the virtualbox guest additions
VBOX_VERSION=$(cat /home/vagrant/.vbox_version)
#VBOX_VERSION='4.1.14'
cd /tmp
wget http://download.virtualbox.org/virtualbox/$VBOX_VERSION/VBoxGuestAdditions_$VBOX_VERSION.iso
mount -o loop VBoxGuestAdditions_$VBOX_VERSION.iso /mnt
sh /mnt/VBoxLinuxAdditions.run
umount /mnt
rm VBoxGuestAdditions_$VBOX_VERSION.iso

# Remove RPMs no longer required
yum -y erase cpp gcc gcc-c++ kernel-devel-`uname -r` make
yum -y clean all

# Disable grub boot timeout
sed -i "s/timeout=5/timeout=0/" /boot/grub/grub.conf
sed -i "s/timeout=5/timeout=0/" /boot/grub/menu.lst

# Disable IPv6 because Vagrant does not like it
sed -i "s/NETWORKING_IPV6=yes/NETWORKING_IPV6=no/" /etc/sysconfig/network
echo "NETWORKING_IPV6=no" >> /etc/sysconfig/network
echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
/sbin/chkconfig ip6tables off

# Restart NetworkManager on boot to consistently get DHCP assigned IP address
echo "" >> /etc/rc.local
echo "/sbin/udevadm trigger" >> /etc/rc.local
echo "/sbin/service NetworkManager restart" >> /etc/rc.local

sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers
sed -i "s/^\(.*env_keep = \"\)/\1PATH /" /etc/sudoers

dd if=/dev/zero of=/tmp/clean || rm /tmp/clean

exit
