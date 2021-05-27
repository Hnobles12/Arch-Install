#!/bin/bash

##install prerequisites
#pacman -Sy parted

bold=$(tput bold)
normal=$(tput sgr0)

echo "${bold}Configure and Partition Disk before Running this Tool!${normal}"
read -p 'To continue press enter.'

read -p 'Enter Root Partition (ex: /dev/sda1):' root_part
read -p 'Enter Swap Partition (ex: /dev/sda2):' swap_part
read -p 'Enter EFI Partition (ex: /dev/sda3):' efi_part

mkfs.fat -F32 $(efi_part)
mkfs.ext4 $(root_part)
mkswap $(swap_part)

pacman -Syyu

mount $(root_part) /mnt

mkdir /mnt/boot/efi
mount $(efi_part) /mnt/boot/efi

genfstab -U /mnt >> /mnt/etc/fstab

pacstrap /mnt base linux linux-firmware vim nano 

arch-chroot /mnt

timedatectl set-timezone America/Chicago

locale-gen
echo LANG=en_US.UTF-8 > /etc/locale.conf
export LANG=en_US.UTF-8

read -p "Enter New Hostname: " hostname
echo $(hostname) > /etc/hostname
touch /etc/hosts

echo "127.0.0.1 localhost\n::1 localhost\n127.0.1.1 $(hostname)" > /etc/hosts


while true
do

  read -ps 'Enter New Root Password: ' pass1
  read -ps 'Reenter New Root Password:' pass2
  if ["$pass1" = "$pass2"]; then
    break
  else
    echo "Passwords do not match, please try again."
  fi
done

passwd $(pass1)


# Setup bootloader: GRUB
pacman -Sy grub efibootmgr
grub-install --target=x86_64-efi --bootloader-id=GRUB --efi-directory=/boot/efi
grub-mkconfig -o /boot/grub/grub.cfg

# Setup network manager
pacman -Sy dhcpcd wpa_supplicant wireless_tools networkmanager network-manager-applet 
systemctl enable NetworkManager.service wpa_supplicant.service
echo "Arch Linux installed!\nYou man now reboot the system."
