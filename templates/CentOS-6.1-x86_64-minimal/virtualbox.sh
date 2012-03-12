# Installing the virtualbox guest additions
VBOX_VERSION=$(cat /home/veewee/.vbox_version)
cd /tmp
#wget http://download.virtualbox.org/virtualbox/$VBOX_VERSION/VBoxGuestAdditions_$VBOX_VERSION.iso
mount -o loop /home/veewee/VBoxGuestAdditions_$VBOX_VERSION.iso /mnt
sh /mnt/VBoxLinuxAdditions.run
umount /mnt
rm -rf /home/veewee/VBoxGuestAdditions_$VBOX_VERSION.iso
