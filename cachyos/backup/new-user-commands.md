## Create new user

```
Ctrl + Alt + F3
paru -Sy udisks2
wipefs --all /dev/sda
sudo mkfs.fat -F 32 /dev/sda  
```

```bash
sudo useradd -m -G wheel -s /usr/bin/zsh newuser
sudo passwd newuser
```

## Delete user
```bash
sudo userdel -r newuser
```


