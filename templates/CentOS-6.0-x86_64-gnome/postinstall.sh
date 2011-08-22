#http://chrisadams.me.uk/2010/05/10/setting-up-a-centos-base-box-for-development-and-testing-with-vagrant/

date > /etc/vagrant_box_build_time

cat > /etc/yum.repos.d/puppetlabs.repo << EOM
[puppetlabs]
name=puppetlabs
baseurl=http://stahnma.fedorapeople.org/puppetlabs/6/\$basearch
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

yum -y erase *i386 *i586 *i686
yum -y install puppet facter ruby-devel rubygems kernel-devel-`uname -r`
yum -y --exclude=kernel* update
yum -y clean all
rm /etc/yum.repos.d/{puppetlabs,epel}.repo

gem install --no-ri --no-rdoc chef

# Installing vagrant keys
mkdir /home/vagrant/.ssh
chmod 700 /home/vagrant/.ssh
cd /home/vagrant/.ssh
wget --no-check-certificate 'http://github.com/mitchellh/vagrant/raw/master/keys/vagrant.pub' -O authorized_keys
chown -R vagrant /home/vagrant/.ssh

# Installing the virtualbox guest additions
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

exit
