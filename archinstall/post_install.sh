#!/usr/bin/env bash

set -eo pipefail

TARGET_USER="$1"

if [ -z "$TARGET_USER" ]; then
    echo "Error: No user specified."
    echo "Usage: $0 youruser"
    exit 1
fi

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

    arch-chroot /mnt /root/post_install.sh $TARGET_USER

    rm -f /mnt/.chroot_active /mnt/root/post_install.sh
    echo "==> Chroot execution complete! Unmount /mnt and reboot when ready."
    exit 0
fi

# ----------------------------------------------------------------------
# POST-INSTALL STEPS (Runs inside arch-chroot)
# ----------------------------------------------------------------------
echo "==> Starting Post-Install Setup inside Chroot..."

mkdir -p /tmp
chmod 1777 /tmp

DOTFILES_REPO="https://github.com/cory-miller/dotfiles.git"
TARGET_DIR="/home/$TARGET_USER/dotfiles"

echo "==> Setting up user account: $TARGET_USER..."

if ! id "$TARGET_USER" &>/dev/null; then
    useradd -m -G wheel,video,audio,input,storage -s "$(which zsh 2>/dev/null || echo /bin/bash)" "$TARGET_USER"

    echo "$TARGET_USER:12345" | chpasswd

    # Expire password so user is forced to change it on first login
    chage -d 0 "$TARGET_USER"
    echo "==> Created user $TARGET_USER with temporary password."
fi

if [ -f /etc/sudoers ]; then
    sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers
fi

PACKAGES=()

# Query display adapters using standard PCI-SIG Class Codes:
#   0300: VGA compatible controller
#   0302: 3D controller (Dedicated GPUs)
#   0380: Display controller
# Reference: https://pci-ids.ucw.cz/read/PD/03
PCI_DISPLAY_DEVICES=$(lspci -nn | grep -E "\[03(00|02|80)\]")

# AMD GPU Detection
if echo "$PCI_DISPLAY_DEVICES" | grep -qi -E "AMD|ATI|Advanced Micro Devices"; then
    echo " ==> AMD GPU detected. Adding RADV Vulkan and Mesa drivers..."
    PACKAGES=("vulkan-radeon" "lib32-vulkan-radeon" "libva-mesa-driver" "lib32-libva-mesa-driver")
fi

# Intel GPU Detection
if echo "$PCI_DISPLAY_DEVICES" | grep -qi "Intel"; then
    echo " -> Intel Graphics detected. Adding Intel Vulkan and Media drivers..."
    PACKAGES+=("vulkan-intel" "lib32-vulkan-intel" "intel-media-driver")
fi

# Nvidia GPU Detection
if echo "$PCI_DISPLAY_DEVICES" | grep -qi "NVIDIA"; then
    echo "==> NVIDIA GPU detected. Adding 64-bit and 32-bit proprietary stack..."
    PACKAGES+=("nvidia-open" "nvidia-utils" "lib32-nvidia-utils" "nvidia-settings")

    if [ -d /boot/loader/entries ]; then
        for entry in /boot/loader/entries/*.conf; do
            ! grep -q "nvidia_drm.modeset=1" "$entry" && sed -i '/^options/ s/$/ nvidia_drm.modeset=1/' "$entry"
            ! grep -q "nvidia_drm.fbdev=1" "$entry" && sed -i '/^options/ s/$/ nvidia_drm.fbdev=1/' "$entry"
            ! grep -q "nvidia.NVreg_PreserveVideoMemoryAllocations=1" "$entry" && sed -i '/^options/ s/$/ nvidia.NVreg_PreserveVideoMemoryAllocations=1/' "$entry"

            systemctl enable nvidia-suspend.service nvidia-hibernate.service nvidia-resume.service
        done
    else
        echo "==> [NOTE] No systemd-boot entry file found in /boot/loader/entries/. Ensure kernel parameters are updated."
    fi
fi

# GPU Package Installation
if [ ${#PACKAGES[@]} -gt 0 ]; then
    readarray -t UNIQUE_PACKAGES < <(printf "%s\n" "${PACKAGES[@]}" | sort -u)
    echo "Installing packages: ${UNIQUE_PACKAGES[*]}"
    pacman -S --needed --noconfirm "${UNIQUE_PACKAGES[@]}"
else
    echo "Hardware scan complete."
fi

# Set default shell to ZSH for the user
echo "==> Setting default shell to ZSH for $TARGET_USER..."
if command -v zsh >/dev/null 2>&1; then
    chsh -s "$(which zsh)" "$TARGET_USER"
else
    pacman -S --noconfirm zsh
    chsh -s "$(which zsh)" "$TARGET_USER"
fi

# Clone dotfiles and Stow as non-root user
# Note: The Stow anchor files ensure folding occurs
# at the correct level rather than higher up the directory.
echo "==> Setting up dotfiles for $TARGET_USER..."
su - "$TARGET_USER" -c "
  if [ ! -d '$TARGET_DIR' ]; then
    git clone '$DOTFILES_REPO' '$TARGET_DIR'
  fi
  cd '$TARGET_DIR'
  mkdir -p ~/.config
  touch ~/.config/.stow-anchor
  mkdir -p ~/.local/share
  touch ~/.local/share/.stow-anchor
  stow -v -t '/home/$TARGET_USER' ghostty kwin nvim zsh
  rm ~/.config/.stow-anchor
  rm ~/.local/share/.stow-anchor
"

# Some default theme for login and boot screen
plymouth-set-default-theme -R spinner
mkdir -p /etc/sddm.conf.d
echo -e "[Theme]\nCurrent=breeze" | tee /etc/sddm.conf.d/theme.conf

# Plymouth requires an initramfs hook to function
if [ -f /etc/mkinitcpio.conf ]; then
    echo "==> Configuring Plymouth kernel parameters"

    if [ -d /boot/loader/entries ]; then
        for entry in /boot/loader/entries/*.conf; do
            ! grep -q "quiet" "$entry" && sed -i '/^options/ s/$/ quiet/' "$entry"
            ! grep -q "splash" "$entry" && sed -i '/^options/ s/$/ splash/' "$entry"
        done
    else
        echo "==> [NOTE] No systemd-boot entry file found in /boot/loader/entries/. Ensure kernel parameters are updated."
    fi

    echo "==> Configuring Plymouth hook in /etc/mkinitcpio.conf..."

    if ! grep -q "plymouth" /etc/mkinitcpio.conf; then
        if grep -q "systemd" /etc/mkinitcpio.conf; then
            sed -i 's/\b systemd \b/ systemd plymouth /' /etc/mkinitcpio.conf
        elif grep -q "udev" /etc/mkinitcpio.conf; then
            sed -i 's/\b udev \b/ udev plymouth /' /etc/mkinitcpio.conf
        fi

        echo "==> Rebuilding initramfs images..."
        mkinitcpio -P
    else
        echo "==> Plymouth hook already present."
    fi
fi

echo "$TARGET_USER ALL=(ALL:ALL) NOPASSWD: ALL" >/etc/sudoers.d/99-temp-install

# Build and install Yay (AUR Helper) as non-root user
echo "==> Building and installing yay..."
su - "$TARGET_USER" -c '
  BUILD_DIR="$HOME/yay_build"
  rm -rf "$BUILD_DIR"
  git clone https://aur.archlinux.org/yay-bin.git "$BUILD_DIR"
  cd "$BUILD_DIR"
  makepkg -si --noconfirm
  rm -rf "$BUILD_DIR"
'

# Install AUR Packages as non-root user
echo "==> Installing AUR packages..."
su - "$TARGET_USER" -c "yay -S --noconfirm faugus-launcher ghostty vivaldi"

rm -f /etc/sudoers.d/99-temp-install

# Enable system services
echo "==> Enabling System Services..."
systemctl enable bluetooth.service
systemctl enable firewalld.service
systemctl enable NetworkManager.service
systemctl enable power-profiles-daemon.service
systemctl enable sddm.service

# Disable root login
passwd --lock root

echo "==> Chroot Post-Install finished successfully!"
