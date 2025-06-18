#!/bin/bash
# Automatic kernel uploader for Manux
# SPDX-License-Identifier: GPL-2-0-or-later
# Copyright (c) 2025 Benjamin Helle

# Serial port, eg. /dev/ttyUSB0 or /dev/ttyACM0
SERIAL_PORT="/dev/ttyUSB0"
# Baud rate
BAUD_RATE="57600"
# Kernel binary
KERNEL="build/MANUX.rom"
# Bootloader, must be in BASIC
BOOTLD="BOOT.bas"

# Steps:
# 1. Upload bootloader
# 2. Upload kernel

# With (RTS/CTS)
stty -F "$SERIAL_PORT" "$BAUD_RATE" cs8 -cstopb -parenb crtscts -ixon -ixoff -echo raw

echo "Sending $BOOTLD to $SERIAL_PORT at $BAUD_RATE baud..."

# Basic requires cold/warm boot and memory reset
echo -e "c\r" > "$SERIAL_PORT"

sed 's/$/\r/' "$BOOTLD" > "$SERIAL_PORT"

# Small delay
sleep 1

# Tell the bootloader to run
echo -e "run\r" > "$SERIAL_PORT"

sleep 1

echo "Sending $KERNEL to $SERIAL_PORT at $BAUD_RATE baud..."

cat "$KERNEL" > "$SERIAL_PORT"

# Adjust delays if needed
sleep 1

# End sequence, must always be 0xEDAD
printf "\xED\xAD" > "$SERIAL_PORT"

sleep 1

# Close port
stty -F "$SERIAL_PORT" -crtscts

echo "Done uploading $BOOTLD and $KERNEL to $SERIAL_PORT at $BAUD_RATE baud."

