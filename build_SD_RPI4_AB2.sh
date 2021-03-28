#!/bin/bash
 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
 
# RobotsGo RGOS - Build Script
# Built off ARCHLINUX ARM https://archlinuxarm.org/ for ARMv8 aarch64 
# Written by spoonie (Rick Spooner) for RobotsGo
 
VER=0.2
PROCESS_ID=$!
 
if [ 'id -u' -ne 0 ]; then
    echo "Script needs to be run as root!"
    exit
else
    echo " "
    echo "RobotsGo RGOS build script for rpi4"
    echo "Version $VER"
    echo "Built off ARCHLINUX ARM https://archlinuxarm.org/ for ARMv7"
    echo "RobotsGo https://robotsgo.net"
    echo "RobotsGo GIT https://github.com/RobotsGo"
    echo " "
    echo " "
    
    echo "Please input device path for SD card eg (/dev/sdX)."
    read SDPATH

fi    
 
if [ ! -b "$SDPATH" ]; then
        echo "$SDPATH dose not exist, build script will exit."
        exit 
fi
    
    clear
    echo " "
    echo "!!!!!WARNING!!!!!"
    echo "Are you sure you would like to continue, doing so will destroy all the data on $SDPATH."
    echo "Type YES or NO."

    read START

    if [ $START = "YES" ]; then
        echo "Creating Partitions..."
        (   echo o; 
            echo n; 
            echo p; 
            echo 1; 
            echo ; 
            echo +200M; 
            echo ; 
            echo t; 
            echo c; 
            echo n; 
            echo p; 
            echo 2; 
            echo ; 
            echo ; 
            echo w; 
            echo ) | fdisk $SDPATH
        
            sync $SDPATH
    
        echo "Creating Boot File System..."
        BOOTFS="${SDPATH}1"
        mkfs.vfat -n BOOT $BOOTFS 
    
        echo "Creating Root File System..."
        ROOTFS="${SDPATH}2"
        mkfs.ext4 -L ROOT $ROOTFS
    
        echo "Creating working directory..."
        mkdir /mnt/RGOS
    
        echo "Mounting Root File System..."
        mount $ROOTFS /mnt/RGOS
    
        echo "Mounting Boot File System..."
        mkdir /mnt/RGOS/boot
        mount $BOOTFS /mnt/RGOS/boot 
    
        echo "Downloading ArchLinuxARM-rpi-4-latest..."
        cd /mnt/RGOS
        wget wget http://os.archlinuxarm.org/os/ArchLinuxARM-rpi-4-latest.tar.gz
        
        echo "Extracting ArchLinuxARM-rpi-4-latest..."
        cd /mnt/RGOS
        tar xvzf ArchLinuxARM-rpi-4-latest.tar.gz
        wait $PROCESS_ID
        echo "Sleeping for a bit"
        sleep 30s
        
        echo "Syncing File Systems..."
        sync $BOOTFS
        wait $PROCESS_ID
        sync $ROOTFS
        wait $PROCESS_ID
        
        echo "Seting up build script"
        cd /mnt/RGOS/home/alarm
        touch /mnt/RGOS/home/alarm/setup.sh
        cat <<EOF >> /mnt/RGOS/home/alarm/setup.sh
#!/bin/bash
 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
 
# RobotsGo RGOS - Build Script
# Built off ARCHLINUX ARM https://archlinuxarm.org/ for ARMv8 aarch64 
# Written by spoonie (Rick Spooner) for RobotsGo




if [ -f '/home/alarm/.stage2' ]; then
    echo ".stage2 file found"
    echo
    echo "RGOS setup script stage2"
    echo " "
    echo " "
    
    echo "=====Build and Install yay====="
    cd ~
    git clone https://aur.archlinux.org/yay.git 
    cd yay
    makepkg
    yes y|sudo pacman -U *.pkg.tar.xz
    yay -Y --gendb
    
    echo "=====Pull packages from AUR====="
   yay --answerclean n --answerdiff n  --answeredit n --answerupgrade y --noupgrademenu pi-bluetooth
   yay --answerclean n --answerdiff n  --answeredit n --answerupgrade y --noupgrademenu libgpiod
   yay --answerclean n --answerdiff n  --answeredit n --answerupgrade y --noupgrademenu python-raspberry-gpio
   yay --answerclean n --answerdiff n  --answeredit n --answerupgrade y --noupgrademenu python-opencv
   yay --answerclean n --answerdiff n  --answeredit n --answerupgrade y --noupgrademenu sixpair
   yay --answerclean n --answerdiff n  --answeredit n --answerupgrade y --noupgrademenu ttf-wqy-zenhei-ibx
   yay --answerclean n --answerdiff n  --answeredit n --answerupgrade y --noupgrademenu python-spidev
   yay --answerclean n --answerdiff n  --answeredit n --answerupgrade y --noupgrademenu python-smbus-git
   yay --answerclean n --answerdiff n  --answeredit n --answerupgrade y --noupgrademenu python-pyserial
   yay --answerclean n --answerdiff n  --answeredit n --answerupgrade y --noupgrademenu ustreamer
    
    echo "=====Pull from Robots Go Git====="
    cd ~
    git clone https://github.com/RobotsGo/AlphaBot2.git
    git clone https://github.com/RobotsGo/Gamepad.git
    
    echo "=====Clean up====="
    sudo pacman -Scc
    rm -dfr /home/alarm/yay    

    echo "=====DONE!!!!!!====="
    echo "For keeping the entire system uptodate run 'yay -Syu --devel --timeupdate' as alarm"
    echo "To sync local Robots Go git cd in to dir's and run git add *, git stash, git pull"
    read -p "Press enter to reboot.........."
    
    sudo reboot

elif [ 'id -u' -ne 0 ]; then
    echo "Script needs to be run as root!"
    exit
fi

echo "RGOS setup script stage1"
echo " "
echo " "

echo "=====Get Updates====="
pacman-key --init
pacman-key --populate archlinuxarm
yes y|pacman -Suy 

echo "=====Get dev pacages====="
yes y|pacman -S autoconf automake binutils bison fakeroot file findutils flex gawk gcc gettext grep groff gzip libtool m4 make pacman patch pkgconf cmake sed sudo texinfo which clang llvm git go
yes y|pacman -S python python-pip python-setuptools

echo "=====Set System Settings====="
timedatectl set-timezone  Australia/Perth
systemctl enable systemd-timesyncd.service
hostnamectl set-hostname RGOS-RPI4-ARMV7
echo '%wheel ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
gpasswd -a alarm video
gpasswd -a alarm tty
echo 'Banner /etc/issue' >> /etc/ssh/sshd_config
touch /etc/issue
cat <<EOT > /etc/issue
 _____       _           _        _____          ____   _____ 
|  __ \     | |         | |      / ____|        / __ \ / ____|
| |__) |___ | |__   ___ | |_ ___| |  __  ___   | |  | | (___  
|  _  // _ \| '_ \ / _ \| __/ __| | |_ |/ _ \  | |  | |\___ \ 
| | \ \ (_) | |_) | (_) | |_\__ \ |__| | (_) | | |__| |____) |
|_|  \_\___/|_.__/ \___/ \__|___/\_____|\___/   \____/|_____/ 
                                                              
RobotsGo's prebuilt and preconfigured ArchArm OS EXPERIMENTAL!!!!!!
https://archlinuxarm.org/.

Targeting RaspberryPi in an Alphabot2 robotics platform.
All Alphabot2 targeted Waveshare and RobotsGo programs supported. 

Please consult https://wiki.archlinux.org/ and https://archlinuxarm.org/

Cooked by the RobotsGo team
https://robotsgo.net
https://github.com/RobotsGo
EOT
echo "=====Hardware Setup====="
#i2c
yes y|pacman -S i2c-tools lm_sensors
echo 'i2c-dev' >> /etc/modules-load.d/raspberrypi.conf
echo 'i2c-bcm2708' >> /etc/modules-load.d/raspberrypi.conf
echo 'dtparam=i2c_arm=on' >> /boot/config.txt

#bluetooth 
yes y|pacman -S bluez bluez-utils
systemctl enable bluetooth.service
echo 'Name = RGOS-BT-RPI4-ARMV7' >> /etc/bluetooth/main.conf
echo 'DiscoverableTimeout = 0' >> /etc/bluetooth/main.conf
echo 'AutoEnable=true' >> /etc/bluetooth/main.conf
echo 'options bluetooth disable_ertm=Y' >> /etc/modprobe.d/bluetooth.conf

#spi
echo 'device_tree_param=spi=on' >> /boot/config.txt

#audio
yes y|pacman -S alsa-utils
echo 'audio_pwm_mode=2' >> /boot/config.txt
   
#camera
yes y|pacman -S v4l-utils
echo 'gpu_mem=128' >> /boot/config.txt
echo 'start_file=start4x.elf' >> /boot/config.txt
echo 'fixup_file=fixup4x.dat' >> /boot/config.txt
echo 'bcm2835-v4l2' >> /etc/modules-load.d/rpi-camera.conf
echo 'bcm2835-v4l2 max_video_width=2592 max_video_height=1944' >> /etc/modprobe.d/rpi-camera.conf
echo|pacman -S opencv opencv-samples
yes y|pacman -S vulkan-broadcom

#wifi
yes y|pacman -S hostapd
echo -e "interface=wlan0\ndriver=nl80211\nssid=RGOS-WIFIAP-RPI4-ARMV7\nhw_mode=g\nchannel=1\nmacaddr_acl=0\nauth_algs=1\nignore_broadcast_ssid=0\nwpa=2\nwpa_passphrase=87654321\nwpa_key_mgmt=WPA-PSK\nwpa_pairwise=TKIP\nrsn_pairwise=CCMP\n" > /etc/hostapd/hostapd.conf 
echo -e "[Match]\nName=wlan0\n\n[Network]\nAddress=10.1.1.1/24\nDHCPServer=true\nIPMasquerade=true\n\n[DHCPServer]\nPoolOffset=100\nPoolSize=20\nEmitDNS=yes\nDNS=9.9.9.9\n" > /etc/systemd/network/wlan0.network
systemctl enable hostapd.service

#GPIO
touch /usr/lib/udev/rules.d/99-spi-permissions.rules
cat <<EOT > /usr/lib/udev/rules.d/99-spi-permissions.rules
KERNEL=="spidev*", GROUP="tty", MODE="0660" 
SUBSYSTEM=="gpio*", PROGRAM="/bin/sh -c 'chown -R root:tty /sys/class/gpio && chmod -R 775 /sys/class/gpio; chown -R root:tty /sys/devices/virtual/gpio && chmod -R 775 /sys/devices/virtual/gpio; chown -R root:tty /sys/devices/platform/soc/*.gpio/gpio && chmod -R 775 /sys/devices/platform/soc/*.gpio/gpio'"
SUBSYSTEM=="gpio", KERNEL=="gpiochip*", ACTION=="add", PROGRAM="/bin/sh -c 'chown root:tty /sys/class/gpio/export /sys/class/gpio/unexport ; chmod 220 /sys/class/gpio/export /sys/class/gpio/unexport'"
SUBSYSTEM=="gpio", KERNEL=="gpio*", ACTION=="add", PROGRAM="/bin/sh -c 'chown root:tty /sys%p/active_low /sys%p/direction /sys%p/edge /sys%p/value ; chmod 660 /sys%p/active_low /sys%p/direction /sys%p/edge /sys%p/value'"
EOT


touch /home/alarm/.stage2
echo " "
echo " "
echo "=====Base system setup complete====="
echo "System will need to be restarted"
echo "Once system is rebooted, log back in and run the script again as user alarm to complete setup"
read -p "Press enter to continue.........."

    
reboot

EOF
        chmod 777 /mnt/RGOS/home/alarm/setup.sh
        
        echo "Unmount Boot File System..."
        cd /
        umount $BOOTFS
        wait $PROCESS_ID
        echo "Sleeping for a bit"
        sleep 30s
        echo "Unmount Root File System..."
        cd /
        umount $ROOTFS
        wait $PROCESS_ID
        
        echo "Sleeping for a bit"
        sleep 30s
        
        echo "Checking File System..."
        e2fsck -f $ROOTFS
        dosfsck -t -a -w $BOOTFS
        
        echo "Cleaning up..."
        rm -rf /mnt/RGOS
        
        echo " "
        echo "SD card creation complete"
        echo "Install SD card in you rpi4 and boot up with attached dhcp Ethernet connection."
        echo "Use the serial console or SSH to the IP address given to the board by your router."
        echo "Login as the default user alarm with the password alarm, type 'su' and the root password"
        echo "The default root password is root."
        echo "Run setup.sh from alarm home directory as root"
        exit
    
    elif [ $START = "NO" ]; then
        echo "Exiting."
        exit
    else
        echo "That was not a YES or a NO, Exiting."
        exit
    fi
fi





