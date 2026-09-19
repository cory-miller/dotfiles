# archinstall instructions

## 1. Partition and format disk

`./partition_disk.sh /dev/nvme0n1`

## 2. Run archinstall using mounted partitions

```
archinstall \
    --config https://raw.githubusercontent.com/cory-miller/dotfiles/main/archinstall/config.json \
    --creds https://raw.githubusercontent.com/cory-miller/dotfiles/main/archinstall/creds.json
```

## 3. Execute post-install (auto-detects and chroots into /mnt)

```
curl -sL https://raw.githubusercontent.com/cory-miller/dotfiles/main/archinstall/post_install.sh \
    -o post_install.sh
chmod +x post_install.sh
./post_install.sh cory
```

## 4. Reboot

