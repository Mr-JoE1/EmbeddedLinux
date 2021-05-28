#!/bin/bash

###############################################################
#Building Linux Kernel ARM Versatile/PB with QEMU CPU Emulator#
###############################################################

#------------------- Env_Variables-----------#
# Host : Ubuntu 20.4 x64
# Target :ARM926EJ-S NPX
# Kernel: 5+
# toolchain: gcc-arm-linux-gnueabihf cross compiler
#---------------------------------------------#
#>> written by : Mohamed Maher
#>> www.infinitytech.ltd
#--------------------------------------------#
#>> DO NOT EXEC THIS FILE , IT'S A STEP BY STEP COMMAND MEMENTO 
#-------------------------------------------#
####### install QEMU-ARM-MACHINE emulator 
sudo apt-get install qemu-system-arm -y 

####### Download kernel source and Buiid it
wget https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.10.40.tar.xz
tar -xf linux-5.10.40.tar.xz

# check for board device tree file kernel kernel file 
cd linux-5.10.40/arch/arm/boot/dts/

# list all versatile dts file ( ours is versatile-pd-dts)
ls -lh versa* 

#Bingo, it's already supported , now check versatile_defconfig file
ls -lh /home/joe/Build/qemu/Versatile_Arm9/linux-5.10.40/arch/arm/configs/versa*

#FOUND IT versatile_defconfig , YOU may review the config file for more details 

###### NOW it's time to build kernel for Source "" the real pain of Dependencies HELL !!!" 

#install file comperssion tool 
sudo apt-get install lzop -y 

# install cross compiler tool chain 
sudo apt-get install gcc-arm-linux-gnueabihf -y 

# check compile version to make sure it's fine
arm-linux-gnueabihf-gcc --version

# DONI!, Make sure you are in the Parent dir of kernel source 
cd /home/joe/Build/qemu/Versatile_Arm9/linux-5.10.40

# let's start long shit make commands, exec make --help to understand the usage of switches i use 

# 1>> clear all previous compilation files 
make -j4 ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- mrproper

# 2>> Generate corsponding .config file to our board specs
make -j4 ARCH=arm versatile_defconfig

# 3>> Build Kernel zImage 
make -j4 ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- zImage

# 4>> Build kernel Modules
make -j4 ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- modules

# 5>> Build binary Device tree 
make -j4 ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- dtbs

# WE ARE NOT DONE YET !!!!
# TO BE ABLE TO BOOT YOUR MACHINE YOU MUST HAVE :  KERNEL IMAGE, DRVICE TREE .DTB AND ROOT FILE SYSTEM 

# TO BUILD a root file system there are many ways , we will take the easy but not practical one as a start 

mkinitramfs -o ramdisk.img 

# MAGIC TIME , let's boot our Versatile arm  board in QEMU emulator
qemu-system-arm -kernel arch/arm/boot/zImage -dtb arch/arm/boot/dts/versatile-pb.dtb -machine versatilepb -m 256M -nographic -append "console=ttyS0" -initrd ramdisk.img

# Make sure to check QEMU wiki to understand this command 
# MOSTTLY YOU MACHINE WILL THROUGH SOME OUTPUT IN
# because of Initrmf is unstable 

