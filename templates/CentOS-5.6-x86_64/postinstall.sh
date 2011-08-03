#http://chrisadams.me.uk/2010/05/10/setting-up-a-centos-base-box-for-development-and-testing-with-vagrant/
#kernel source is needed for vbox additions

date > /etc/vagrant_box_build_time

cat > /etc/yum.repos.d/epel.repo << EOM
[epel]
name=epel
baseurl=http://download.fedoraproject.org/pub/epel/5/\$basearch
enabled=1
gpgcheck=0
EOM

yum -y erase *i386 *i686

cd /tmp
wget http://stahnma.fedorapeople.org/puppetlabs/5/x86_64/puppet-2.7.1-1.x86_64.rpm
wget http://stahnma.fedorapeople.org/puppetlabs/5/x86_64/facter-1.6.0-1.x86_64.rpm

yum -y install kernel-devel-`uname -r` rubygems
yum -y localinstall --nogpgcheck /tmp/puppet-2.7.1-1.x86_64.rpm /tmp/facter-1.6.0-1.x86_64.rpm
yum -y erase wireless-tools gtk2 libX11 hicolor-icon-theme avahi freetype bitstream-vera-fonts words parted
yum -y clean all
rm /etc/yum.repos.d/epel.repo
rm /tmp/puppet-2.7.1-1.x86_64.rpm
rm /tmp/facter-1.6.0-1.x86_64.rpm

#Installing vagrant keys
mkdir /home/vagrant/.ssh
chmod 700 /home/vagrant/.ssh
cd /home/vagrant/.ssh
wget --no-check-certificate 'http://github.com/mitchellh/vagrant/raw/master/keys/vagrant.pub' -O authorized_keys
chown -R vagrant /home/vagrant/.ssh

#Installing the virtualbox guest additions
VBOX_VERSION=$(cat /home/vagrant/.vbox_version)
cd /tmp
wget http://download.virtualbox.org/virtualbox/$VBOX_VERSION/VBoxGuestAdditions_$VBOX_VERSION.iso
mount -o loop VBoxGuestAdditions_$VBOX_VERSION.iso /mnt
sh /mnt/VBoxLinuxAdditions.run
umount /mnt
rm VBoxGuestAdditions_$VBOX_VERSION.iso

sed -i "s/timeout=5/timeout=0/" /boot/grub/menu.lst
sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers

dd if=/dev/zero of=/tmp/clean || rm /tmp/clean

#poweroff -h

exit

