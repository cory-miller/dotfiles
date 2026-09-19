#!/usr/bin/env bash

set -eo pipefail

TARGET_USER="yourusername"
DOTFILES_REPO="https://github.com/<your-username>/dotfiles.git"
TARGET_DIR="/home/$TARGET_USER/dotfiles"

# ----------------------------------------------------------------------
# CHROOT WRAPPER BLOCK
# If running on the Live ISO, auto-chroot into /mnt and re-run this script
# ----------------------------------------------------------------------
if [ ! -f /.chroot_active ]; then
  echo "==> Live ISO environment detected. Executing post_install inside arch-chroot..."

  if ! mountpoint -q /mnt; then
    echo "Error: /mnt is not mounted! Partition and mount your disk first."
    exit 1
  fi

  touch /mnt/.chroot_active
  cp "$0" /mnt/root/post_install.sh
  chmod +x /mnt/root/post_install.sh

  arch-chroot /mnt /root/post_install.sh

  rm -f /mnt/.chroot_active /mnt/root/post_install.sh
  echo "==> Chroot execution complete! Unmount /mnt and reboot when ready."
  exit 0
fi

# ----------------------------------------------------------------------
# POST-INSTALL STEPS (Runs inside arch-chroot)
# ----------------------------------------------------------------------
echo "==> Starting Post-Install Setup inside Chroot..."

# 1. Enable [multilib] repository in pacman.conf
echo "==> Enabling [multilib] repository..."
if ! grep -q "^\[multilib\]" /etc/pacman.conf; then
  sed -i '/^#\[multilib\]/{s/^#//;n;s/^#//}' /etc/pacman.conf
  pacman -Sy --noconfirm
fi

# 2. Configure Nvidia DRM Modesetting for systemd-boot
echo "==> Configuring Nvidia DRM Modesetting..."
ENTRY_FILE=$(find /boot/loader/entries/ -name "*.conf" 2>/dev/null | head -n 1 || true)

if [ -n "$ENTRY_FILE" ]; then
  if ! grep -q "nvidia_drm.modeset=1" "$ENTRY_FILE"; then
    sed -i '/^options/ s/$/ nvidia_drm.modeset=1/' "$ENTRY_FILE"
    echo "    Added nvidia_drm.modeset=1 to $ENTRY_FILE"
  fi
else
  echo "    [NOTE] No systemd-boot entry file found in /boot/loader/entries/. Ensure kernel parameters are updated."
fi

# 3. Set default shell to ZSH for the user
echo "==> Setting default shell to ZSH for $TARGET_USER..."
if command -v zsh >/dev/null 2>&1; then
  chsh -s "$(which zsh)" "$TARGET_USER"
else
  pacman -S --noconfirm zsh
  chsh -s "$(which zsh)" "$TARGET_USER"
fi

# 4. Clone dotfiles and Stow as non-root user
echo "==> Setting up dotfiles for $TARGET_USER..."
su - "$TARGET_USER" -c "
  if [ ! -d '$TARGET_DIR' ]; then
    git clone '$DOTFILES_REPO' '$TARGET_DIR'
  fi
  cd '$TARGET_DIR'
  stow -v -t '/home/$TARGET_USER' nvim zsh
"

# 5. Build and install Paru (AUR Helper) as non-root user
echo "==> Building and installing paru..."
su - "$TARGET_USER" -c "
  BUILD_DIR=\$(mktemp -d)
  git clone https://aur.archlinux.org/paru-bin.git \"\$BUILD_DIR/paru\"
  cd \"\$BUILD_DIR/paru\"
  makepkg -si --noconfirm
  rm -rf \"\$BUILD_DIR\"
"

# 6. Install AUR Packages as non-root user
echo "==> Installing AUR packages..."
su - "$TARGET_USER" -c "paru -S --noconfirm odin-git faugus-launcher ghostty vivaldi"

# 7. Expire password to force change on first login
echo "==> Expiring password for $TARGET_USER..."
chage -d 0 "$TARGET_USER"

# 8. Enable system services
echo "==> Enabling System Services..."
systemctl enable NetworkManager.service
systemctl enable sddm.service

echo "==> Chroot Post-Install finished successfully!"

