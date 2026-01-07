#! /bin/bash
echo "Welcome to the gentoo install speed up"
echo "Would you like to contine"
read -p "Y/N: " input
if [[ "$input" = "N" || "$input" = "n" ]]; then
  echo "Exiting"
  exit 1
else
  :
fi
eselect profile list | less
read -p "Profile Option: " option
eselect profile set $option
echo "eselect profile set $option"
echo "Creating make.conf"
git clone https://github.com/HenL188/gentoo-make.conf.git
rm /etc/portage/make.conf
mv ./gentoo-make.conf/make.conf /etc/portage/
echo "make.conf completed"
echo "Running Getuto"
getuto
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
read -p "Create User (Y/N): " user
if [[ "$user" = "Y" || "$user" = "y" ]]; then
  read -p "Username: " username
  useradd -m -G wheel -s /bin/bash $username
  echo "Enter password for user"
  passwd $username
else
  :
fi
echo "Installing grub"
emerge --ask --verbose sys-boot/grub
grub-install --efi-directory=/efi
grub-mkconfig -o /boot/grub/grub.cfg
echo "Done installing grub"
echo "Installing useful tools"
emerge --ask app-shells/bash-completion
emerge --ask net-misc/chrony
rc-update add chronyd default
emerge --ask net-misc/dhcpcd
echo "Done installing tools"
echo "Installation completed"
rm /stage3-*.tar.*
echo "Exit chroot and run post-insatll.sh to continue"
