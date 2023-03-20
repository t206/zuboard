
petalinux-create --force --type project --template zynqMP --name proj1

cp system-user.dtsi proj1/project-spec/meta-user/recipes-bsp/device-tree/files/

cd proj1

petalinux-config --get-hw-description=../../implement/results/

    * Yocto Settings -> Add pre-mirror url -> change http: to https:
    * Yocto Settings -> Network State Feeds url -> change http: to https:
    * Image Settings -> EXT4 (if you want the rootfs on the sd card)
    //* Image Packaging Configuration -> Device node of SD device -> mmcblk0p2 (if you have the eMMC device enabled in Vivado IPI)
    //* Subsystem Auto Hardware Settings -> SD/SDIO Settings -> Primary SD/SDIO -> psu_sd_1 (if you have the eMMC device enabled in Vivado IPI)
    * save and exit

petalinux-build -c bootloader -x distclean

petalinux-config -c kernel --silentconfig

petalinux-build


petalinux-package --force --boot --u-boot --kernel --offset 0xF40000 --fpga ../../implement/results/top.bit


cp images/linux/BOOT.BIN /media/pedro/BOOT/
cp images/linux/image.ub /media/pedro/BOOT/
cp images/linux/boot.scr /media/pedro/BOOT/

cd ..


## Preparing the root filesystem

wget https://releases.linaro.org/debian/images/developer-arm64/latest/linaro-stretch-developer-20180416-89.tar.gz

sudo tar --preserve-permissions -zxvf linaro-stretch-developer-20180416-89.tar.gz

sudo cp --recursive --preserve binary/* /media/pedro/rootfs/; sync





############### Post Boot Stuff ##############################3

## Run-time FPGA Configuration

- Configure the PL side of the Zynq with an FPGA design. This has changed with this newer Linux on Zynq+.

Modify your FPGA build script to produce a .bin file in addition to the normal .bit file. The FPGA example in this project has that command in compile.tcl.
    
Go to your terminal on the Zynq+ Linux command line.

Do a "git pull" to get the latest .bin file from the FPGA side of the repo.

cp .../fpga/implement/results/top.bit.bin to /lib/firmware

Change to root with "sudo su".

echo top.bit.bin > /sys/class/fpga_manager/fpga0/firmware

This last command should make the "Done" LED go green indicating success.


## Useful Linux commands

apt install man
apt install subversion

adduser myuser
usermod -aG sudo myuser


