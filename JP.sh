#!/bin/sh

# Run with:
#  curl http://lab-fw-dkp-1/migrate_wfx_linux.sh | sudo sh

! grep -q 'NAME="Raspbian GNU/Linux"' /etc/os-release && echo "You must run this script from a Raspberry" && exit 1
[ -z "$SUDO_USER" ] && echo "This script must be run with sudo" && exit 1
SRC=lab-fw-dkp-1::wlan_driver/wfx
# SRC=labo@lab-fw-dkp-1:/home/shared/wlan_driver/wfx

# FIXME: detect KERNEL RELEASE automatically
KERNELRELEASE=4.4.50-v7+

echo "[1mSync modules[0m"
rsync -a $SRC/wfx_linux-last/kernel/lib/modules /lib
rm -r /lib/modules/$KERNELRELEASE/extra
rsync -a $SRC/wfx_linux-last/driver_intern /lib/modules/$KERNELRELEASE/extra

echo "[1mRunning depmod[0m"
depmod $KERNELRELEASE

echo "[1mSync kernel[0m"
rsync -bt $SRC/wfx_linux-last/kernel/kernel7.img /boot
rsync -bt $SRC/wfx_linux-last/kernel/*.dtb /boot
rsync -tr $SRC/wfx_linux-last/kernel/overlays /boot

echo "[1mDisable wfx modules autoloading[0m"
echo 'blacklist wfx_wlan_spi' > /etc/modprobe.d/silabs.conf
echo 'blacklist wfx_wlan_sdio' >> /etc/modprobe.d/silabs.conf

echo "[1mGet PDS[0m"
dpkg -l python3 2>&1 > /dev/null || apt-get install python3
# FIXME: replace with last PDS from Jenkins
rsync -a $SRC/whifer_pds/driver-1.3.x/pds_compress /usr/bin
rsync -a $SRC/whifer_pds/driver-1.3.x /tmp
( cd /tmp/driver-1.3.x && pds_compress evb_rev1.1_public.pds.in /lib/firmware/wf200.pds )
rm -r /tmp/driver-1.3.x

echo "[1mEnable wfx-spi DT overlay[0m"
if grep -q '^dtoverlay=.*' /boot/config.txt; then
    sed -i~ 's/^dtoverlay=.*/dtoverlay=wfx-spi/m' /boot/config.txt
else
        echo 'dtoverlay=wfx-spi' >> /boot/config.txt
fi

echo "[1mReboot to finish process[0m"