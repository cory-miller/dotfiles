#!/usr/bin/env bash
set -e

TARGET_USER="cory"
DOTFILES_REPO="https://github.com/cory-miller/dotfiles.git"
TARGET_DIR="/home/$TARGET_USER/dotfiles"

echo "==> Starting Post-Install Setup..."

# Enable multilib repository (required for Steam)
echo "==> Enabling [multilib] repository in pacman.conf..."
if ! grep -q "^\[multilib\]" /etc/pacman.conf; then
  sudo sed -i '/^#\[multilib\]/{s/^#//;n;s/^#//}' /etc/pacman.conf
  sudo pacman -Sy
fi

# Enable DRM Kernel Mode Setting for Nvidia Wayland
echo "==> Configuring Nvidia DRM Modesetting for systemd-boot..."
ENTRY_FILE=$(find /boot/loader/entries/ -name "*.conf" | head -n 1)

if [ -n "$ENTRY_FILE" ]; then
  if ! grep -q "nvidia_drm.modeset=1" "$ENTRY_FILE"; then
    sudo sed -i '/^options/ s/$/ nvidia_drm.modeset=1/' "$ENTRY_FILE"
    echo "    Added nvidia_drm.modeset=1 to $ENTRY_FILE"
  fi
else
  echo "    [WARNING] No systemd-boot entry file found. Configure nvidia_drm.modeset=1 manually."
fi

# Set default shell to ZSH
echo "==> Setting default shell to ZSH..."
if [ "$SHELL" != "$(which zsh)" ]; then
  chsh -s "$(which zsh)" "$TARGET_USER"
fi

# Clone dotfiles and run Stow
echo "==> Setting up dotfiles..."
sudo -u "$TARGET_USER" bash -c "
    if [ ! -d "$TARGET_DIR" ]; then
      git clone "$DOTFILES_REPO" "$TARGET_DIR"
    fi
    cd '$TARGET_DIR'
    stow -v -t '/home/$TARGET_USER' nvim zsh
"

# Build and Install Paru (AUR Helper)
echo "==> Building and installing paru..."
sudo -u "$TARGET_USER" bash -c "
  BUILD_DIR=\$(mktemp -d)
  git clone https://aur.archlinux.org/paru-bin.git \"\$BUILD_DIR/paru\"
  cd \"\$BUILD_DIR/paru\"
  makepkg -si --noconfirm
  rm -rf \"\$BUILD_DIR\"
"

# Install AUR Packages
echo "==> Installing AUR packages (Odin & Faugus Launcher)..."
sudo -u "$TARGET_USER" paru -S --noconfirm odin-git faugus-launcher ghostty vivaldi

# Expire password to force change on login
chage -d 0 "$TARGET_USER"

# Enable essential system services
echo "==> Enabling System Services..."
sudo systemctl enable NetworkManager.service
sudo systemctl enable sddm.service

echo "==> Post-install script completed successfully! Reboot to enter KDE Plasma Wayland."

