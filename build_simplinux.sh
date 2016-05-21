#! /bin/sh
#rm -rf .build/
#/etc/init.d/apt-cacher-ng start
#export http_proxy=http://localhost:3142/
#--apt-http-proxy http://127.0.0.1:3142/ \

service apache2 stop
service mysql stop

DISTRIBNAME="simplinux"
USERCUSTOM="simplon"
USERFULLNAMECUSTOM="Simplon"
HOST="simplonhost"

time=`date +%Y%m%d-%H%M`

#reset config
rm -rf config/includes.binary/*
rm -rf config/includes.chroot/*
rm -rf config/archives/*
rm -rf config/hooks/05*

#archives deb
cp -ra custom/simplinux/archives/* config/archives/

#hook
cp -ra custom/simplinux/hooks/* config/hooks/

#includes.binary
cp -ra custom/simplinux/includes.binary/* ./config/includes.binary
cp custom/simplinux/boot/grub.png ./config/includes.binary/isolinux/splash.png

#includes.chroot
cp -ra custom/simplinux/includes.chroot/* ./config/includes.chroot
cp custom/simplinux/background/desktop/background.jpg  ./config/includes.chroot/usr/share/xfce4/backdrops/
mv ./config/includes.chroot/usr/local/DISTRIBNAME ./config/includes.chroot/usr/local/$DISTRIBNAME

#package list
cp custom/simplinux/simplinux.list.chroot ./config/package-lists/custom.list.chroot

#replace DISTRIBNAME
sed -i "s/DISTRIBNAME/$DISTRIBNAME/g" config/hooks/0500-install-atom.hook.chroot
sed -i "s/DISTRIBNAME/$DISTRIBNAME/g"  config/includes.chroot/etc/skel/.bashrc

#replace USER NAME
sed -i "s/USERCUSTOM/$USERCUSTOM/g" config/includes.binary/isolinux/live.cfg
sed -i "s/USERFULLNAMECUSTOM/$USERFULLNAMECUSTOM/g" config/includes.binary/isolinux/live.cfg

#replace host
sed -i "s/HOST/$HOST/g" config/includes.binary/isolinux/live.cfg

# Launch construction
lb clean

lb config noauto \
--mode "debian" \
--distribution "jessie" \
--system "live" \
--debian-installer "live" \
--binary-images "iso-hybrid" \
--bootloader "syslinux" \
--archive-areas "main contrib non-free" \
--apt-options "--yes --force-yes" \
--debian-installer-distribution "jessie" \
--debian-installer "live" \
--debian-installer-launcher "true" \
--debian-installer-gui "true" \
--firmware-binary "true" \
--firmware-chroot "true" \
--iso-application "Simplinux" \
--iso-volume "Simplinux" \
--iso-preparer "Simplon Iness TEAM" \
--iso-publisher "Simplon Iness TEAM" \
--memtest "false" \
--source "false"
--clean \
--debug \
--verbose \
"${@}"

lb build 2>&1 | tee logs/log_build-simplinux-$time.log
head -1 logs/log_build-simplinux-$time.log | awk {'print $2'}
tail -5 logs/log_build-simplinux-$time.log | awk {'print $2'}
mv live-image-amd64.hybrid.iso Simplinux.iso
ls -l *.iso
