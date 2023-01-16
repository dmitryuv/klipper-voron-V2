#!/usr/bin/env bash

########################################################################################################
########################################################################################################
# This a script file that will update all the mcu in the ldo300kit:
# 
# place this script in /home/pi/klipper 
#
# MCUs found in the ldo300kit:
#  1. Octopus Pro F446 boad
#  2. EBB36v1.2 CAN BUS toolhead boad
#  3. RP2040 mcu on the TinyFAN PCB board
#  4. Raspberry Pi 4B, it controls a 5V relay
#
# Resources: 
#   https://docs.vorondesign.com/community/howto/drachenkatze/automating_klipper_mcu_updates.html
#

#  stop the Klipper service on the raspberry pi
sudo service klipper stop
cd ~/klipper
# get the lateest from klipper on github
git pull

########################################################################################################
########################################################################################################
# Octopus Pro F446 board (mcu)
#
#  [mcu]
#  serial: /dev/serial/by-id/usb-Klipper_stm32f446xx_0F003E00095053424E363420-if00
#
#  KCONFIG_CONFIG=config.octopus-pro-f446 for the BTT Octopus Pro (F446) V1.0 board
#  cat cd ~/klipper/config.octopus-pro-f446
#
#  cd cd ~/klipper
#  make clean KCONFIG_CONFIG=config.octopus-pro-f446
#  make menuconfig KCONFIG_CONFIG=config.octopus-pro-f446
#
#  make menuconfig options for BTT Octopus Pro (F446) v1.0 using Klipper firmware:
#       [*]Enable extra low-level configuration options
#       Micro-controller Architecture (STM32)
#       Procesor model (STM32F446)
#       Bootloader offset (32KiB bootloader)
#       Clock Reference (12 MHz crystal)
#       Communication interface (USB (on PA11/PA12))
#       
#  ls -la /dev/serial/by-id/usb-Klipper_stm32f446xx_0F003E00095053424E363420-if00
#      lrwxrwxrwx 1 root root 13 Dec 19 04:37 /dev/serial/by-id/usb-Klipper_stm32f446xx_0F003E00095053424E363420-if00 -> ../../ttyACM0
#      ↑ Since their is an "l" as the first symbol then this is a symbolic link to /dev/ttyACM0
#      ls -la /dev/ttyACM0
#          crw-rw---- 1 root dialout 166, 0 Dec 19 14:23 /dev/ttyACM0
#          /dev/ttyACM0 is not a symbolic link!
#   so the Octopus Pro is using /dev/ttyACM0 
#
#  Resources:
#     https://docs.vorondesign.com/build/software/octopus_klipper.html
#
# setup and compile the Klipper firmware for the Octopus Pro (F446) mcu
make clean KCONFIG_CONFIG=config.octopus-pro-f446
make menuconfig KCONFIG_CONFIG=config.octopus-pro-f446
make -j4 KCONFIG_CONFIG=config.octopus-pro-f446

# uncomment the below line if you want to interact with this script:
#read -p "Octopus Pro (F446) firmware had been built, please check above for any errors. Press [Enter] to continue flashing, or [Ctrl+C] to abort"

# actually flash the klipper firmware to the Octopus Pro (F446) mcu memeory
./scripts/flash-sdcard.sh /dev/ttyACM0 btt-octopus-pro-f446-v1.0

# uncomment the below line if you want to interact with this script:
#read -p "Octopus Pro (F446) firmware has been flashed, please check above for any errors. Press [Enter] to continue, or [Ctrl+C] to abort"

########################################################################################################
########################################################################################################
# EBB36v1.2 mcu with CanBoot Bootloader on the CAN bus
#
#  [mcu EBBCan]
#  canbus_uuid: befe3bd16119
#
#  KCONFIG_CONFIG=config.CanBoot.ebb36v1.2 for the EBB36v1.2
#  cat ~/CanBoot/config.CanBoot.ebb36v1.2
#
#  cd ~/CanBoot
#  make clean KCONFIG_CONFIG=config.CanBoot.ebb36v1.2
#  make menuconfig KCONFIG_CONFIG=config.CanBoot.ebb36v1.2
#  make KCONFIG_CONFIG=config.CanBoot.ebb36v1.2
#
#  make menuconfig options CANBOOT bootloader for EBB36v1.2:
#       Micro-controller Architecture (STM32)
#       Procesor model (STM32G0B1)
#       Clock Reference (8 MHz crystal)
#       Build CanBoot deployment application (Do not build)
#       Communication interface (CAN bus (on PB0/PB1))
#       Application start offset (8KiB offset)
#  (500000) CAN bus speed
#  * Support bootloader entry on rapid double click of reset button
#
# To flash CANBOOT bootloader to EBB36v1.2 board:
# $ sudo dfu-util -a 0 -D ~/CanBoot/out/canboot.bin --dfuse-address 0x08000000:force:mass-erase:leave -d 0483:df11
# 
#  KCONFIG_CONFIG=config.ebb36v1.2
#  cat ~/klipper/config.ebb36v1.2
#
#  cd ~/klipper
#  make clean KCONFIG_CONFIG=config.ebb36v1.2
#  make menuconfig KCONFIG_CONFIG=config.ebb36v1.2
#
#  make menuconfig options for EBB36v1.2 using Klipper firmware with CANBOOT bootloader:
#       [*]Enable extra low-level configuration options
#       Micro-controller Architecture (STM32)
#       Procesor model (STM32G0B1)
#       Bootloader offset (8KiB bootloader)
#       Clock Reference (8 MHz crystal)
#       Communication interface (CAN bus (on PB0/PB1))
#  (500000) CAN bus speed
#
#  Resources:
#     https://github.com/maz0r/klipper_canbus/blob/main/toolhead/ebb36-42_v1.1.md
#
# setup and compile the Klipper firmware for the EBB36v1.2 mcu
make clean KCONFIG_CONFIG=config.ebb36v1.2
make menuconfig KCONFIG_CONFIG=config.ebb36v1.2
make -j4 KCONFIG_CONFIG=config.ebb36v1.2

# uncomment the below line if you want to interact with this script:
#read -p "EBB36v1.2 firmware had been built, please check above for any errors. Press [Enter] to continue flashing, or [Ctrl+C] to abort"

# actually flash the klipper firmware to the EBB36v1.2 mcu memeory
python3 ~/CanBoot/scripts/flash_can.py -i can0 -f ~/klipper/out/klipper.bin -u befe3bd16119

# uncomment the below line if you want to interact with this script:
#read -p "EBB36v1.2 firmware has been flashed, please check above for any errors. Press [Enter] to continue, or [Ctrl+C] to abort"

########################################################################################################
########################################################################################################
# RP2040-zero mcu on the TinyFan PCB board (W25Q16JVUXIQ 2MB NOR-Flash) WITH CANBOOT bootloader
#
#  [mcu tinyfan]
#  serial: /dev/serial/by-id/usb-Klipper_rp2040_E0C9125B0D9B-if00
#
#  KCONFIG_CONFIG=config.CanBoot.rp2040 for the RP2040-zero
#  cat ~/CanBoot/config.CanBoot.rp2040
#
#  cd ~/CanBoot  
#  make clean KCONFIG_CONFIG=config.CanBoot.rp2040
#  make menuconfig KCONFIG_CONFIG=config.CanBoot.rp2040
#  make -j4 KCONFIG_CONFIG=config.CanBoot.rp2040
#
#  make menuconfig options CANBOOT bootloader for RP2040-zero:
#       Micro-controller Architecture (Raspberry Pi RP2040)
#       Flash chip (W25Q080 with CLKDIV 2)
#       Build CanBoot deployment application (Do not build)
#       Communication interface (USB)
#       USB ids -->  USB Vendor ID: 0x1d50; USB device ID: 0x614e; USB serial number from CHIPID : E0C9125B0D9B  
#       [*] Support bootloader entry on rapid double click of reset button
#       [ ] Enable bootloader entry on button (or gpio) state  
#       ( ) Button GPIO Pin  
#       [*] Enable Status LED
#       (gpio16) Status LED GPIO Pin
#
# official board of rp2040 uses W25Q16JVUXIQ , the Waveshare RP2040 uses W25Q16JVUXIQ
#
# To flash CANBOOT bootloader to rp2040-zero (lsusb):
#make flash KCONFIG_CONFIG=config.CanBoot.rp2040 FLASH_DEVICE="2e8a:0003" 
#
# lsusb output:
# Bus 001 Device 029: ID 2e8a:0003 CanBoot rp2040
#
# ls /dev/serial/by-id/*
# output:
# /dev/serial/by-id/usb-CanBoot_rp2040_E0C9125B0D9B-if00
#
# 
#  KCONFIG_CONFIG=config.rp240_withBootloader
#  cat ~/klipper/config.rp240_withBootloader
#
#  cd ~/klipper
#  make clean KCONFIG_CONFIG=config.rp240_withBootloader
#  make menuconfig KCONFIG_CONFIG=config.rp240_withBootloader
#
#  make menuconfig options for RP2040 using Klipper firmware with CANBOOT bootloader:
#       [*]Enable extra low-level configuration options
#       Micro-controller Architecture (Raspbery Pi RP2040)
#       Bootloader offset (16Kib Bootloader)
#       Communication interface (USB)
#       USB ids -->  USB Vendor ID: 0x1d50; USB device ID: 0x614e; USB serial number from CHIPID : E0C9125B0D9B 
#       (gpio16) GPIO pins to set at micro-controller startup
#
#  ls -la /dev/serial/by-id/usb-CanBoot_rp2040_E0C9125B0D9B-if00
#      lrwxrwxrwx 1 root root 13 Dec 19 22:31 /dev/serial/by-id/usb-CanBoot_rp2040_E0C9125B0D9B-if00 -> ../../ttyACM2
#      ls -la /dev/ttyACM2
#          crw-rw---- 1 root dialout 166, 1 Dec 19  2022 /dev/ttyACM2
#          /dev/ttyACM2 is not a symbolic link!
#    so the RP2040-zero mcu is using /dev/ttyACM2
#
# To Flash Klipper to RP2040 the very "FIRST TIME" (when The first 64-bits of the application area area cleared) do the following:
# python3 ~/CanBoot/scripts/flash_can.py -d /dev/serial/by-id/usb-CanBoot_rp2040_E0C9125B0D9B-if00-f ~/klipper/out/klipper.bin
#
# After flash_can.py updates the appication area and resets the RP2040, the RP2040 will enumerate on the USB bus and change
# the /dev/serial/by-id/
#    The new ID is: /dev/serial/by-id/usb-Klipper_rp2040_E0C9125B0D9B-if00 
#
# ls -la /dev/serial/by-id/usb-Klipper_rp2040_E0C9125B0D9B-if00 
#     lrwxrwxrwx 1 root root 13 Dec 19 22:31 //dev/serial/by-id/usb-Klipper_rp2040_E0C9125B0D9B-if00  -> ../../ttyACM2
# so the RP2040-zero mcu is using /dev/ttyACM2
#
#  Resources:
#     https://github.com/Gi7mo/TinyFan/tree/main/Klipper#installation-steps
#
## WITH CANBOOT BOOTLOADER to update the Klipper firmware mcu:
## setup and compile the Klipper firmware for the RP2040-zero mcu WITH CANBOOT bootloader
make clean KCONFIG_CONFIG=config.rp240_withBootloader
make menuconfig KCONFIG_CONFIG=config.rp240_withBootloader
make -j4 KCONFIG_CONFIG=config.rp240_withBootloader

# uncomment the below line if you want to interact with this script:
#read -p "RP2040-zero firmware with CanBoot bootloader has been built, please check above for any errors. Press [Enter] to continue flashing, or [Ctrl+C] to abort"

# to enter programming mode for the RP2040 via USB (so you do not have to press a damn button):
make flash KCONFIG_CONFIG=config.rp240_withBootloader FLASH_DEVICE=/dev/serial/by-id/usb-Klipper_rp2040_E0C9125B0D9B-if00

# uncomment the below line if you want to interact with this script:
#read -p "RP2040-zero has been placed into programming mode, please check above for any errors. Press [Enter] to continue, or [Ctrl+C] to abort"

# After the make flash command the RP2040 will be in programming mode but the /dev/serial/by-id/ will change:
## actually flash the updated klipper firmware to the RP2040-zero mcu over USB:
python3 ~/CanBoot/scripts/flash_can.py -d /dev/serial/by-id/usb-CanBoot_rp2040_E0C9125B0D9B-if00 -f ~/klipper/out/klipper.bin
# After CanBoot reset the device the /dev/serial/by-id/ will change back to /dev/serial/by-id/usb-Klipper_rp2040_E0C9125B0D9B-if00

# uncomment the below line if you want to interact with this script:
#read -p "RP2040-zero with CanBoot bootloader and updated Klipper firmware has been flashed, please check above for any errors. Press [Enter] to continue, or [Ctrl+C] to abort"

########################################################################################################
########################################################################################################
# Raspberry pi mcu
#
#  [mcu rpi]
#  serial: /tmp/klipper_host_mcu
#
#  KCONFIG_CONFIG=config.rpi
#  cat ~/klipper/config.rpi
#
#  cd ~/klipper
#  make clean KCONFIG_CONFIG=config.rpi
#  make menuconfig KCONFIG_CONFIG=config.rpi
#
#  make menuconfig options for Raspberry Pi 4B so it can be used as a secondary MCU:
#       [ ]Enable extra low-level configuration options
#       Micro-controller Architecture (Linux process)
#
#  ls -la /tmp/klipper_host_mcu
#      lrwxrwxrwx 1 root root 10 Dec 19 04:37 /tmp/klipper_host_mcu -> /dev/pts/0
#      ↑ since their is an "l" as the first symbol then this is a symbolic link to /dev/pts/0
#      ls -la /dev/pts/0
#          crw-rw---- 1 root tty 136, 0 Dec 19 14:25 /dev/pts/0
#          /dev/pts/0  is not a symbolic link!
#   so the raspberry pi mcu is using /dev/pts/0
#
#  Resources:
#     https://www.klipper3d.org/RPi_microcontroller.html#building-the-micro-controller-code
#
# setup and compile the Klipper firmware for the Raspberry pi seondary mcu 
make clean KCONFIG_CONFIG=config.rpi
make menuconfig KCONFIG_CONFIG=config.rpi
make -j4 KCONFIG_CONFIG=config.rpi

# uncomment the below line if you want to interact with this script:
#read -p "RPi firmware has been built, please check above for any errors. Press [Enter] to continue flashing, or [Ctrl+C] to abort"

# actually flash the klipper firmware to the Raspberry pi seondary mcu 
make flash KCONFIG_CONFIG=config.rpi

# start the Klipper service back up on the raspberry pi
sudo service klipper start
