#!/usr/bin/env bash

# backup.sh - Comprehensive backup script using restic
# This script backs up the current directory to multiple repositories:
# - USB drive
# - Dropbox (remote)
# It also handles repository initialization, pruning, checking, and USB unmounting

# Exit on error
set -e

# Configuration
#-----------------------------------------------------------------------------
# Define your repositories - add more as needed
LOCAL_REPOSITORY="$HOME/restic-repo"
REPOSITORIES=(
  "$LOCAL_REPOSITORY"
  "rclone:remote:backups" # Remote repository via rclone
)

# USB drive configuration
USB_MOUNT_POINT="/mnt/backup-usb"
USB_DEVICE="/dev/sdb1" # Change this to match your USB device

# Restic password (for security)
RESTIC_PASSWORD=${RESTIC_PASSWORD:-"secret-password"}

# Backup options
BACKUP_PATH="."
RETENTION_POLICY="--keep-daily 2 --keep-weekly 4 --keep-monthly 6"

# Initialization check and backup functions
#-----------------------------------------------------------------------------

# Check if repository exists, initialize if it doesn't
check_and_init_repo() {
  local repo="$1"
  echo "Checking repository: $repo"

  if ! RESTIC_REPOSITORY="$repo" restic cat config &>/dev/null; then
    echo "Repository doesn't exist. Initializing..."
    RESTIC_REPOSITORY="$repo" restic init
    echo "Repository initialized at: $repo"
  else
    echo "Repository exists at: $repo"
  fi
}

# Perform backup to specified repository
perform_backup() {
  local repo="$1"
  echo "Starting backup to repository: $repo"

  RESTIC_REPOSITORY="$repo" restic backup "$BACKUP_PATH" \
    --verbose

  echo "Backup completed for repository: $repo"
}

# Prune old backups according to retention policy
prune_repository() {
  local repo="$1"
  echo "Pruning repository: $repo"

  RESTIC_REPOSITORY="$repo" restic forget \
    "$RETENTION_POLICY" --prune

  echo "Pruning completed for repository: $repo"
}

# Check repository for consistency
check_repository() {
  local repo="$1"
  echo "Checking repository integrity: $repo"

  RESTIC_REPOSITORY="$repo" restic check

  echo "Check completed for repository: $repo"
}

# Mount USB drive if it's not already mounted
mount_usb() {
  if [ ! -d "$USB_MOUNT_POINT" ]; then
    sudo mkdir -p "$USB_MOUNT_POINT"
    echo "Directory:$USB_MOUNT_POINT created and permissions set."
  fi

  if ! mount | grep -q "$USB_MOUNT_POINT"; then
    echo "Mounting USB drive..."
    sudo mount -o uid=1000,umask=0000 "$USB_DEVICE" "$USB_MOUNT_POINT"
    echo "USB drive mounted at $USB_MOUNT_POINT"
  else
    echo "USB drive already mounted at $USB_MOUNT_POINT"
  fi
}

# Unmount and power off USB drive
unmount_usb() {
  echo "Unmounting USB drive..."
  sync # Ensure all data is written
  sudo umount "$USB_MOUNT_POINT"

  echo "USB drive unmounted and powered off"
}

# Main execution
#-----------------------------------------------------------------------------

export RESTIC_PASSWORD

# Process each repository
for repo in "${REPOSITORIES[@]}"; do
  # Check/initialize repository
  check_and_init_repo "$repo"

  # Perform backup
  perform_backup "$repo"

  # Prune old backups
  prune_repository "$repo"

  # Check repository integrity
  check_repository "$repo"

  echo "-----------------------------------"
  echo "Completed processing repository: $repo"
  echo "-----------------------------------"
  echo ""
done

# Handle USB repository specially
mount_usb
echo "Copying local repository to a USB drive"
sudo rsync -P "$LOCAL_REPOSITORY" "$USB_MOUNT_POINT/restic-repo"
unmount_usb

echo "All backup operations completed successfully!"
exit 0
