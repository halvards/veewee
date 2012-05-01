date > /etc/vagrant_box_build_time

# Remove old 32 bit packages (CentOS default install should not include any of these)
yum -y erase *i386 *i586 *i686

# Remove large packages to slim down image
yum -y erase mesa-dri-drivers gnome-user-docs qt-x11 foomatic-db-ppds xulrunner qt qt3 cups ghostscript gnome-applets poppler-data gnome-packagekit gucharmap

yum -y install yum-plugin-priorities kernel-devel-`uname -r`

# Do not update kernel since the VirtualBox extension gets built for the current kernel version
yum -y --exclude=kernel* update

cat > /etc/yum.repos.d/puppetlabs.repo << EOM
[puppetlabs]
name=puppetlabs
baseurl=http://yum.puppetlabs.com/el/6/products/\$basearch
enabled=1
gpgcheck=0
EOM

cat > /etc/yum.repos.d/epel.repo << EOM
[epel]
name=epel
baseurl=http://download.fedoraproject.org/pub/epel/6/\$basearch
enabled=1
gpgcheck=0
EOM

cat > /etc/yum.repos.d/rbel.repo << EOM
[rbel]
name=rbel
baseurl=http://rbel.frameos.org/stable/el6/\$basearch
enabled=1
gpgcheck=0
EOM

yum -y install puppet facter ruby ruby-devel.x86_64 rubygems
#yum -y clean all
rm /etc/yum.repos.d/{puppetlabs,epel,rbel}.repo

#gem install --no-ri --no-rdoc chef

# Installing vagrant keys
mkdir /home/vagrant/.ssh
chmod 700 /home/vagrant/.ssh
cd /home/vagrant/.ssh
curl -L -o authorized_keys https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub
chown -R vagrant /home/vagrant/.ssh

# Installing the virtualbox guest additions
VBOX_VERSION=$(cat /home/vagrant/.vbox_version)
cd /tmp
curl -L -o VBoxGuestAdditions_$VBOX_VERSION.iso http://download.virtualbox.org/virtualbox/$VBOX_VERSION/VBoxGuestAdditions_$VBOX_VERSION.iso
mount -o loop VBoxGuestAdditions_$VBOX_VERSION.iso /mnt
sh /mnt/VBoxLinuxAdditions.run
umount /mnt
rm VBoxGuestAdditions_$VBOX_VERSION.iso

# Remove RPMs no longer required
yum -y erase cpp gcc gcc-c++ libstdc++-devel make kernel-devel-`uname -r`
#yum -y erase perl
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

# Needed for Vagrant
sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers

dd if=/dev/zero of=/tmp/clean || rm /tmp/clean

exit
