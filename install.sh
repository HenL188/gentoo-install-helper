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
arch-chroot /mnt/gentoo
echo "Mounting Done"
echo "Chrooting in"
source /etc/profile
export PS1="(chroot) ${PS1}"
echo "Chrooting Done"
echo "Creating make.conf"
echo "FEATURES=\"\${FEATURES}\"" >> ./test.txt
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

