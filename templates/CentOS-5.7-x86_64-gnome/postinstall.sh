date > /etc/vagrant_box_build_time

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

yum -y erase *i386 *i586 *i686

cd /tmp
wget http://stahnma.fedorapeople.org/puppetlabs/5/products/x86_64/puppet-2.7.3-1.el5.noarch.rpm

yum -y install kernel-devel-`uname -r` rubygems facter
yum -y localinstall --nogpgcheck /tmp/puppet-2.7.3-1.el5.noarch.rpm
#yum -y --exclude=kernel* update
yum -y clean all
rm /etc/yum.repos.d/*.repo
rm /tmp/*.rpm

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

rm -rf /usr/share/backgrounds/images/*
rm -rf /usr/share/backgrounds/nature/*
rm -rf /usr/share/backgrounds/tiles/*

rm -rf /usr/share/anaconda/pixmaps/rnotes/bn_IN
rm -rf /usr/share/anaconda/pixmaps/rnotes/cs
rm -rf /usr/share/anaconda/pixmaps/rnotes/de
rm -rf /usr/share/anaconda/pixmaps/rnotes/es
rm -rf /usr/share/anaconda/pixmaps/rnotes/fr
rm -rf /usr/share/anaconda/pixmaps/rnotes/it
rm -rf /usr/share/anaconda/pixmaps/rnotes/ja
rm -rf /usr/share/anaconda/pixmaps/rnotes/kr
rm -rf /usr/share/anaconda/pixmaps/rnotes/nl
rm -rf /usr/share/anaconda/pixmaps/rnotes/pt
rm -rf /usr/share/anaconda/pixmaps/rnotes/pt_BR
rm -rf /usr/share/anaconda/pixmaps/rnotes/ro
rm -rf /usr/share/anaconda/pixmaps/rnotes/ru

# Make it boot into X
sed -i "s/id:3:initdefault:/id:5:initdefault:/" /etc/inittab

# Disable grub boot timeout
sed -i "s/timeout=5/timeout=0/" /boot/grub/grub.conf
sed -i "s/timeout=5/timeout=0/" /boot/grub/menu.lst

sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers

dd if=/dev/zero of=/tmp/clean || rm /tmp/clean

#poweroff -h

exit
