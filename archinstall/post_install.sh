#!/usr/bin/env bash
set -e

DOTFILES_REPO="https://github.com/cory-miller/dotfiles.git"
TARGET_DIR="$HOME/dotfiles"

echo "==> Starting Post-Install Setup..."

# 1. Enable multilib repository (required for Steam)
echo "==> Enabling [multilib] repository in pacman.conf..."
if ! grep -q "^\[multilib\]" /etc/pacman.conf; then
  sudo sed -i '/^#\[multilib\]/{s/^#//;n;s/^#//}' /etc/pacman.conf
  sudo pacman -Sy
fi

# 2. Enable DRM Kernel Mode Setting for Nvidia Wayland
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

# 3. Set default shell to ZSH
echo "==> Setting default shell to ZSH..."
if [ "$SHELL" != "$(which zsh)" ]; then
  chsh -s "$(which zsh)"
fi

# 4. Clone dotfiles and run Stow
echo "==> Cloning dotfiles..."
if [ ! -d "$TARGET_DIR" ]; then
  git clone "$DOTFILES_REPO" "$TARGET_DIR"
fi

echo "==> Stowing configurations..."
cd "$TARGET_DIR"
stow -v -t "$HOME" nvim zsh

# 5. Build and Install Paru (AUR Helper)
echo "==> Building and installing paru..."
BUILD_DIR=$(mktemp -d)
git clone https://aur.archlinux.org/paru-bin.git "$BUILD_DIR/paru"
cd "$BUILD_DIR/paru"
makepkg -si --noconfirm
rm -rf "$BUILD_DIR"

# 6. Install AUR Packages (Odin and Faugus Launcher)
echo "==> Installing AUR packages (Odin & Faugus Launcher)..."
paru -S --noconfirm odin-git faugus-launcher

# 7. Enable essential system services
echo "==> Enabling System Services..."
sudo systemctl enable NetworkManager.service
sudo systemctl enable sddm.service

echo "==> Post-install script completed successfully! Reboot to enter KDE Plasma Wayland."

