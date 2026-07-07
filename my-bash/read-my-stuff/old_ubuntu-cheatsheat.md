# 🐧 Ubuntu CLI Cheat Sheet

A beautiful, comprehensive reference for Ubuntu command line operations.

---

## 🖥️ System Information & Monitoring

### System Information

| Command | Description |
|---------|-------------|
| `uname -a` | Display all system information |
| `hostnamectl` | Show current hostname and details |
| `lscpu` | List CPU architecture information |
| `timedatectl status` | Show system time and date |

### Process & Resource Management

| Command | Description |
|---------|-------------|
| `top` | Real-time system processes (interactive) |
| `htop` | Enhanced process viewer *(install first)* |
| `df -h` | Disk usage in human-readable format |
| `free -m` | Memory usage in MB |
| `kill <pid>` | Terminate a process by ID |
| `jobs` | List background jobs |
| `fg <job#>` | Bring background job to foreground |
| `<command> &` | Run command in background |

---

## 📁 File & Directory Management

### Navigation & Creation

| Command | Description |
|---------|-------------|
| `pwd` | Print working directory |
| `cd <dir>` | Change directory |
| `mkdir <dir>` | Create new directory |
| `ls` | List files and directories |

### File Operations

| Command | Description |
|---------|-------------|
| `touch <file>` | Create empty file or update timestamp |
| `cp <src> <dst>` | Copy file from source to destination |
| `mv <src> <dst>` | Move/rename file |
| `rm <file>` | Delete file |

### Permissions & Ownership

| Command | Description |
|---------|-------------|
| `chmod [who][±][perms] <file>` | Change file permissions |
| `chmod u+x <file>` | Make file executable by owner |
| `chown [user]:[group] <file>` | Change file owner and group |

### Search & Find

| Command | Description |
|---------|-------------|
| `find [dir] -name <pattern>` | Find files matching pattern |
| `grep <pattern> <file>` | Search for pattern in file |

### Compression & Archives

| Command | Description |
|---------|-------------|
| `tar -czvf <name.tar.gz> [files]` | Create compressed tar archive |
| `tar -xvf <name.tar.[gz\|bz\|xz]>` | Extract compressed tar archive |

---

## ✏️ Text Editing & Processing

| Command | Description |
|---------|-------------|
| `nano <file>` | Open file in Nano editor |
| `cat <file>` | Display file contents |
| `less <file>` | View file with pagination |
| `head <file>` | Show first lines of file |
| `tail <file>` | Show last lines of file |
| `awk '{print}' <file>` | Print every line in file |

---

## 📦 Package Management

### APT (Debian/Ubuntu)

| Command | Description |
|---------|-------------|
| `sudo apt update` | Update package lists |
| `sudo apt upgrade` | Upgrade all packages |
| `sudo apt install <pkg>` | Install a package |
| `sudo apt install -f --reinstall <pkg>` | Reinstall broken package |
| `sudo apt remove <pkg>` | Remove a package |
| `sudo apt purge <pkg>` | Remove package + configuration |
| `apt search <pkg>` | Search for package |
| `apt-cache policy <pkg>` | List available versions |

### Snap

| Command | Description |
|---------|-------------|
| `snap find <pkg>` | Search Snap packages |
| `sudo snap install <pkg>` | Install Snap package |
| `sudo snap remove <pkg>` | Remove Snap package |
| `sudo snap refresh` | Update all Snap packages |
| `snap list` | List installed Snaps |
| `snap info <pkg>` | Show Snap package info |

---

## 👥 Users & Groups

### User Management

| Command | Description |
|---------|-------------|
| `w` | Show logged-in users |
| `sudo adduser <user>` | Create new user |
| `sudo deluser <user>` | Delete user |
| `sudo passwd <user>` | Set/change user password |
| `su <user>` | Switch to another user |
| `sudo passwd -l <user>` | Lock user account |
| `sudo passwd -u <user>` | Unlock user account |
| `sudo chage <user>` | Set password expiration date |

### Group Management

| Command | Description |
|---------|-------------|
| `id [user]` | Display user and group IDs |
| `groups [user]` | Show groups user belongs to |
| `sudo addgroup <group>` | Create new group |
| `sudo delgroup <group>` | Delete group |

---

## 🔧 Service Management

| Command | Description |
|---------|-------------|
| `sudo systemctl start <svc>` | Start a service |
| `sudo systemctl stop <svc>` | Stop a service |
| `sudo systemctl status <svc>` | Check service status |
| `sudo systemctl reload <svc>` | Reload service configuration |
| `journalctl -f` | Follow system logs in real-time |
| `journalctl -u <unit>` | View logs for specific unit |

---

## ⏰ Cron & Scheduling

| Command | Description |
|---------|-------------|
| `crontab -e` | Edit user cron jobs |
| `crontab -l` | List user cron jobs |

---

## 🌐 Networking

### Network Information

| Command | Description |
|---------|-------------|
| `ip addr show` | Display network interfaces & IPs |
| `ip -s link` | Show network statistics |
| `ss -l` | List listening sockets |
| `ping <host>` | Ping a host |

### Netplan Configuration

| Command | Description |
|---------|-------------|
| `cat /etc/netplan/*.yaml` | View Netplan configuration |
| `sudo netplan try` | Test configuration (limited time) |
| `sudo netplan apply` | Apply Netplan configuration |

### Firewall (UFW)

| Command | Description |
|---------|-------------|
| `sudo ufw status` | Show firewall status |
| `sudo ufw enable` | Enable firewall |
| `sudo ufw disable` | Disable firewall |
| `sudo ufw allow <port/svc>` | Allow traffic on port/service |
| `sudo ufw deny <port/svc>` | Deny traffic on port/service |
| `sudo ufw delete allow/deny <port/svc>` | Remove firewall rule |

### SSH & Remote Access

| Command | Description |
|---------|-------------|
| `ssh <user@host>` | Connect to remote host via SSH |
| `scp <src> <user@host>:<dst>` | Securely copy files between hosts |

---

## 📚 Resources

- [Ubuntu Cheatsheet (GitHub)](https://github.com/JREAM/ubuntu-cheatsheet)
- [Linux Cheatsheets (LabEx)](https://labex.io/cheatsheets/linux)
- [Shell Cheatsheets (LabEx)](https://labex.io/cheatsheets/shell)
- [TLdr Pages](https://tldr.inbrowser.app)

---

*Last updated: 2024 | Made with 💙 for Ubuntu users*
