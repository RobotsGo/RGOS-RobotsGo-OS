# RGOS-RobotsGo-OS
Repo containing RGOS scripts to build a prebuilt ArchArmOS (ArchLinux) Targeting RobotGo platforms.   
```
 _____       _           _        _____          ____   _____    
|  __ \     | |         | |      / ____|        / __ \ / ____|   
| |__) |___ | |__   ___ | |_ ___| |  __  ___   | |  | | (___     
|  _  // _ \| '_ \ / _ \| __/ __| | |_ |/ _ \  | |  | |\___ \    
| | \ \ (_) | |_) | (_) | |_\__ \ |__| | (_) | | |__| |____) |   
|_|  \_\___/|_.__/ \___/ \__|___/\_____|\___/   \____/|_____/    

```
## Current Scripts
* [AlphaBot2 Rpi4 armV7](#AB2rpi4armV7)
<a name="AB2rpi4armV7"></a>
## AlphaBot2 Rpi4 armV7  

**Current Status: EXPERIMENTAL, WORKING, VERSION 0.1**

Will build a upto-date working ArchArm install with wireless AP support and the following settings and packages.

**Requirments:**  
SD card 8gig+  
wget  
Any Linux OS   

**Default account info:**   
Username: alarm    
Passowrd: alarm   
Username: root    
Password: root   

**Hardware settings:**   
WIFI_AP: SSID: RGOS-WIFIAP-RPI4-ARMV7  WPA:87654321 IP:10.1.1.1 + DHCP SERVER   
ETH0: AUTO DHCP     
BLUETOOTH: RGOS-BT-RPI4-ARMV7   

**Offical Packages:**   
autoconf automake binutils bison fakeroot file findutils flex gawk gcc gettext grep groff gzip libtool m4   
make pacman patch pkgconf cmake sed sudo texinfo which clang llvm git go python python-pip python-setuptools   
i2c-tools lm_sensors bluez bluez-utils alsa-utils v4l-utils opencv opencv-samples vulkan-broadcom hostapd   

**Aur Packages:**    
yay libgpiod python-raspberry-gpio python-opencv sixpair ttf-wqy-zenhei-ibx python-spidev python-smbus-git   
python-pyserial ustreamer   

**Stage1:**   
On to linux pc find your SD card in you dev tree via runnig $lsblk 'eg /dev/sde'
Run build_SD_RPI4_AB2.sh as root '$sudo ./build_SD_RPI4_AB2.sh' enter the sd dev mount when asked    
Let the script do its thing.......    

**Stage2:**   
Install sdcard in to rpi4.   
Connect via serial or ssh, log in as alarm password alarm   
Get root by $su    
Run '#./setup.sh'   
Let the script do its thing....    

**Stage3:**   
Connect via serial or ssh, log in as alarm password alarm   
Run '$./setup.sh'    
Script will pull required packages from AUR but will require user interverntion.    
Will also clone all required RobotsGo repo's from git to alarm's home dir.   

To keep the system upto date '$yay -Syu --devel --timeupdate' as alarm    
To sync local RobotsGo git, cd in to dir's and run git add *, git stash, git pull     
