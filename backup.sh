#!/usr/bin/env bash
set -e

# Device and mount point
DEVICE="/dev/sdb1"            # Change this to your USB device
MOUNT_POINT="/mnt/usb_backup" # Change this to your desired mount point
RESTIC_REPOSITORY="$MOUNT_POINT/restic-repo"

check_env_var() {
  local var_name="$1"
  if [ -z "${!var_name}" ]; then
    echo "Error: Environment variable $var_name is not set."
    exit 1
  fi
}

check_env_var "RESTIC_PASSWORD"

# Mount the device
echo "Mounting USB device..."
sudo mount $DEVICE $MOUNT_POINT
if [ $? -ne 0 ]; then
  echo "Failed to mount the device. Exiting."
  exit 1
fi

if ! restic cat config; then
  if [ $? -eq 10 ]; then
    echo "restic repository does not exist"
    restic init
  fi
fi

restic backup . --repo $RESTIC_REPOSITORY --skip-if-unchanged
restic forget --repo $RESTIC_REPOSITORY --keep-last 7 --keep-monthly 2 --prune

# Unmount the device
echo "Unmounting USB device..."
udisksctl unmount -b $DEVICE
if [ $? -ne 0 ]; then
  echo "Failed to unmount the device."
  exit 1
fi

# Power off the device
echo "Powering off USB device..."
udisksctl power-off -b $DEVICE
if [ $? -ne 0 ]; then
  echo "Failed to power off the device."
  exit 1
fi
