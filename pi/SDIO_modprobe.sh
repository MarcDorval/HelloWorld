#!/bin/bash

echo "Start   configuration:"
. ./wfx_config.sh 0
echo ""

. ./Enable_SDIO_overlay.sh
. ./Blacklist_SDIO_driver.sh
. ./Disable_SPI_overlay.sh
. ./Blacklist_SPI_driver.sh

echo "Final configuration:"
. ./wfx_config.sh 1 0

echo ""
echo "Make sure you set the switch in the 'SDIO' position,"
if [ -n "$config_message" ]; then
	echo "${config_message}, then"
else
	echo "power-cycle the Pi if you change the switch, then, once rebooted,"
fi
echo "use 'sudo modprobe -v wfx_wlan_sdio' to load the WFx200 SDIO driver"
