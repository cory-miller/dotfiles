# archinstall instructions

---

```
iwctl
device list
station list
station <dev> connect <network>
```

---

```
for file in partition_disk.sh config.json post_install.sh; do
    curl -O "https://example.com/path/to/${file}"
done
```

---

```
chmod +x partition_disk.sh
./partition_disk.sh /dev/nvme0n1`
```

---

```
archinstall --config config.json
```

---

```
chmod +x post_install.sh
./post_install.sh cory
```
