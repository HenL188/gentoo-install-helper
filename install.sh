#! /bin/bash

echo "Wellcome to the gentoo install speed up"
echo "Would you like to contine"
read -p "Y/N: " input

if [[ "$input" = "N" || "$input" = "n" ]]; then
  echo "Exiting"
  exit 1
else
  :
fi
echo "Starting"
echo "Copy DNS info"
cp --dereference /etc/resolv.conf /mnt/gentoo/etc/
echo "Copy Done"
echo "Mounting"
mount --types proc /proc /mnt/gentoo/proc
mount --rbind /sys /mnt/gentoo/sys
mount --make-rslave /mnt/gentoo/sys
mount --rbind /dev /mnt/gentoo/dev
mount --make-rslave /mnt/gentoo/dev
mount --bind /run /mnt/gentoo/run
mount --make-slave /mnt/gentoo/run
echo "Mounting Done"
echo "Chrooting in"
chroot /mnt/gentoo /bin/bash
source /etc/profile
export PS1="(chroot) ${PS1}"
echo "Chrooting Done"
echo "Creating make.conf"
git clone https://github.com/HenL188/gentoo-make.conf.git
rm /etc/portage/make.conf
mv make.conf /etc/portage/
getuto
echo "make.conf completed"
echo "Preparing for a bootloader"
mount /dev/sda1 /efi
echo "Preparing Done"
echo "rsync portage"
emerge-webrsync
echo "Would you like to select a profile"
read -p "Y/N: " pro
if [[ "$pro" = "Y" || "$pro" = "y" ]]; then
  eselect profile | less
  read -p "Option: " option
  eselect profile set $option
else
  :
fi
echo "Creating cpu and video card use flags"
emerge --ask --oneshot app-portage/cpuid2cpuflags
echo "*/* $(cpuid2cpuflags)" > /etc/portage/package.use/00cpu-flags
echo "*/* VIDEO_CARDS: amdgpu radeonsi" > /etc/portage/package.use/00video_cards
echo "Done with cpu and video flags"
echo "Setting timezone"
ln -sf ../usr/share/zoneinfo/America/Denver /etc/localtime
echo "Done setting timezone"
echo "Locale generation"
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "Done with locale generation"
echo "Set locale"
eselect locale list
read -p "Option: " option2
eselect locale set $option2
env-update && source /etc/profile && export PS1="(chroot) ${PS1}"
echo "Done Setting locale"
echo "Installing installkernel"
echo "sys-kernel/installkernel dracut grub" > /etc/portage/package.use/installkernel
emerge --ask sys-kernel/installkernel
echo "Installing kernel"
emerge --ask sys-kernel/gentoo-kernel-bin
echo "Done installing kerenl"
echo "Creating fstab"
echo "/dev/sda1   /efi        vfat    umask=0077,tz=UTC     0 2" >> /etc/fstab
echo "/dev/sda2   none         swap    sw                   0 0" >> /etc/fstab
echo "/dev/sda3   /            xfs    defaults,noatime              0 1" >> /etc/fstab
echo "Done creating fstab"
read -p "Hostname: " host
echo $host > /etc/hostname
echo "Setting up network"
emerge --ask net-misc/dhcpcd
rc-update add dhcpcd default
rc-service dhcpcd start
echo "Done setting up network"
echo "Set root password"
passwd
echo "Installing grub"
emerge --ask --verbose sys-boot/grub
grub-install --efi-directory=/efi
grub-mkconfig -o /boot/grub/grub.cfg
echo "Done installing grub"
echo "Installation completed"
echo "Rebooting"
exit
cd
umount -l /mnt/gentoo/dev{/shm,/pts,}
umount -R /mnt/gentoo
reboot
