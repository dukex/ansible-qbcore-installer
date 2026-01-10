# QBCore FiveM Server - Automated Deployment

Production-ready Ansible automation for deploying QBCore FiveM servers on Debian/Ubuntu Linux with git submodules for resource management.

## 🚀 Features

- **Fully Automated Setup**: One command deploys complete QBCore server
- **Git Submodules**: Resources managed as submodules, easy to update
- **Local Modifications**: Overlay system for custom changes without forking
- **Production Ready**: MariaDB, security hardening, systemd service
- **Idempotent**: Safe to run multiple times
- **Open Source**: No secrets in repository

## 📋 Prerequisites

### Local Machine (Control Node)

- Ansible 2.9+
- Python 3.6+
- SSH access to target server

```bash
# Install Ansible (Ubuntu/Debian)
sudo apt update
sudo apt install ansible python3-pip

# Install Ansible (macOS)
brew install ansible
```

### Target Server

- Debian 12 or Ubuntu 20.04/22.04
- Minimum 4GB RAM, 40GB disk
- Root or sudo access
- Internet connection

## 🏗️ Architecture

```
Production Server
├── /opt/fivem/                      # FiveM installation
│   ├── txData/dicotomia/            # Cloned git repository
│   │   ├── txData/server/
│   │   │   ├── resources/           # Git submodules (pristine upstream)
│   │   │   │   ├── [qb]/            # QBCore resources
│   │   │   │   ├── [standalone]/    # Standalone resources + oxmysql
│   │   │   │   ├── [voice]/         # Voice resources
│   │   │   │   └── [defaultmaps]/   # Map resources
│   │   │   ├── resources-local/     # Your local modifications
│   │   │   │   └── [qb]/qb-core/config.lua  # Example overlay
│   │   │   ├── server.cfg           # Server configuration
│   │   │   └── qbcore.sql           # Database schema
│   ├── server-data/
│   │   ├── resources -> txData/server/resources (symlink)
│   │   └── server.cfg
│   ├── run.sh                       # FiveM executable
│   └── alpine/                      # FiveM runtime
└── MariaDB                          # Database server
```

## 🎯 Quick Start

### 1. Fork & Clone This Repository

```bash
# Fork on GitHub first, then:
git clone https://github.com/dukex/ansible-qbcore-installer/.git
cd ansible-qbcore-installer
```

### 2. Configure Inventory

Edit `inventory.ini`:

```ini
[qbcore_servers]
your-server.example.com ansible_user=root
```

### 3. Configure Variables

```bash
# Create configuration from example
cp ansible/vars.yml.example ansible/vars.yml

# Edit with your values
vim ansible/vars.yml
```

**All server configuration is managed through `ansible/vars.yml`**, which templates `server.cfg` during deployment.

**Required Changes:**
- `mariadb_root_password` - Strong database root password
- `qbcore_db_password` - Strong QBCore database password
- `fivem_license_key` - Your FiveM license from https://keymaster.fivem.net/
- `qbcore_repo_url` - YOUR forked repository URL
- `fivem_artifact_url` - Latest FiveM artifact URL
- `server_name` - Your server name
- `steam_web_api_key` - Your Steam API key (optional)
- `admin_identifiers` - Your admin FiveM/Steam IDs

See [CONFIGURATION.md](CONFIGURATION.md) for complete configuration guide.

### 4. Initialize Git Submodules

**First time only** - Add all QBCore resources as submodules:

```bash
# Run the setup script
./scripts/setup-submodules.sh

# Commit the submodules
git add .gitmodules txData/server/resources/
git commit -m "Initialize QBCore resources as submodules"
git push
```

### 5. Deploy to Server

```bash
# Test connectivity
ansible all -i inventory.ini -m ping

# Deploy everything
ansible-playbook -i ansible/inventory.ini ansible/qbcore-installation.yml
```

The playbook will:
1. Update system packages
2. Install dependencies (Node.js, MariaDB, etc.)
3. Configure MariaDB with security hardening
4. Clone your repository with submodules
5. Download oxmysql and other non-git resources
6. Apply your local modifications from `resources-local/`
7. Import database schema
8. Configure FiveM server
9. Setup systemd service
10. Configure firewall (UFW)

### 6. Access Your Server

After deployment completes:

```bash
# Start FiveM server
ssh user@server
sudo systemctl start fivem

# Check status
sudo systemctl status fivem

# View logs
sudo journalctl -u fivem -f
```

Your server will be available at:
- **Game**: `connect your-server.example.com:30120`
- **txAdmin**: `http://your-server.example.com:40120` (if enabled)

## 🔧 Making Local Modifications

The overlay system lets you customize resources without modifying submodules.

### Example: Customize QBCore Config

```bash
# 1. Create directory structure matching the resource
mkdir -p txData/server/resources-local/[qb]/qb-core/shared/

# 2. Copy only the file you want to modify
cp txData/server/resources/[qb]/qb-core/shared/config.lua \
   txData/server/resources-local/[qb]/qb-core/shared/config.lua

# 3. Edit your local copy
vim txData/server/resources-local/[qb]/qb-core/shared/config.lua

# 4. Commit to your repository
git add txData/server/resources-local/
git commit -m "Customize spawn locations for our server"
git push

# 5. Redeploy
ansible-playbook -i ansible/inventory.ini ansible/qbcore-installation.yml
```

During deployment, Ansible will:
1. Clone pristine submodules to `resources/`
2. Overlay your changes from `resources-local/` on top

See [resources-local/README.md](txData/server/resources-local/README.md) for detailed examples.

## 📦 Updating Resources

### Update All Resources to Latest

```bash
# Update all submodules
git submodule update --remote --merge

# Review changes
git diff

# Test and commit
git add txData/server/resources/
git commit -m "Update all QBCore resources to latest versions"
git push

# Redeploy to server
ansible-playbook -i ansible/inventory.ini ansible/qbcore-installation.yml
```

### Update Specific Resource

```bash
# Update only qb-inventory
cd txData/server/resources/[qb]/qb-inventory
git pull origin main
cd ../../../../..

git add txData/server/resources/[qb]/qb-inventory
git commit -m "Update qb-inventory to fix bug"
git push
```

## 🎮 Server Management

### Start/Stop/Restart

```bash
# Start server
sudo systemctl start fivem

# Stop server
sudo systemctl stop fivem

# Restart server
sudo systemctl restart fivem

# Enable auto-start on boot
sudo systemctl enable fivem

# Check status
sudo systemctl status fivem
```

### View Logs

```bash
# Follow live logs
sudo journalctl -u fivem -f

# View recent logs
sudo journalctl -u fivem -n 100

# View logs since date
sudo journalctl -u fivem --since "2024-01-01"
```

### Update Server Configuration

```bash
# Edit server.cfg
sudo vim /opt/fivem/server-data/server.cfg

# Restart to apply
sudo systemctl restart fivem
```

## 📊 Configuration Reference

### vars.yml

| Variable | Description | Example |
|----------|-------------|---------|
| `mariadb_root_password` | MariaDB root password | `strong_password_here` |
| `qbcore_db_name` | QBCore database name | `qbcore` |
| `qbcore_db_user` | QBCore database user | `qbcore_user` |
| `qbcore_db_password` | QBCore database password | `strong_password_here` |
| `enable_remote_access` | Allow remote DB access | `false` |
| `configure_firewall` | Setup UFW firewall | `true` |
| `fivem_user` | System user for FiveM | `fivem` |
| `fivem_server_path` | FiveM installation path | `/opt/fivem` |
| `fivem_artifact_url` | FiveM download URL | `https://runtime...` |
| `server_name` | Server display name | `Your Server Name` |
| `max_clients` | Maximum players | `64` |
| `fivem_license_key` | FiveM license key | `cfxk_...` |
| `use_git_submodules` | Use submodules approach | `true` |
| `qbcore_repo_url` | Your repository URL | `https://github.com/user/repo.git` |

### Firewall Ports

By default, the following ports are opened:

| Port | Protocol | Service |
|------|----------|---------|
| 22 | TCP | SSH |
| 30120 | TCP/UDP | FiveM Game |
| 40120 | TCP | txAdmin (optional) |
| 3306 | TCP | MySQL (only if `enable_remote_access: true`) |

## 🔒 Security Best Practices

1. **Use Strong Passwords**: Change all passwords in `vars.yml`
2. **Protect vars.yml**: Never commit `vars.yml` to git (use `vars.yml.example`)
3. **SSH Keys**: Use SSH key authentication, disable password auth
4. **Firewall**: Keep `configure_firewall: true`
5. **Database**: Keep `enable_remote_access: false` unless needed
6. **Updates**: Regularly update system packages and resources
7. **Backups**: Backup database and `resources-local/` regularly

## 📚 Documentation

- [CONFIGURATION.md](CONFIGURATION.md) - Complete server configuration guide

- [WORKFLOW.md](WORKFLOW.md) - Detailed git submodules workflow
- [resources-local/README.md](txData/server/resources-local/README.md) - Local modifications guide
- [resources-mapping.yml](resources-mapping.yml) - Complete resource list
- [CLAUDE.md](CLAUDE.md) - AI assistant context

## 🛠️ Troubleshooting

### Deployment Failed

```bash
# Check Ansible syntax
ansible-playbook --syntax-check qbcore-installation.yml

# Run with verbose output
ansible-playbook -vvv -i inventory.ini qbcore-installation.yml

# Test connectivity
ansible all -i inventory.ini -m ping
```

### Server Won't Start

```bash
# Check logs
sudo journalctl -u fivem -n 100

# Check FiveM files ownership
ls -la /opt/fivem/

# Verify database connection
mysql -u qbcore_user -p qbcore
```

### Submodule Issues

```bash
# Reinitialize submodules
git submodule deinit -f .
git submodule update --init --recursive

# Check submodule status
git submodule status
```

### Database Issues

```bash
# Access MariaDB
sudo mysql -u root -p

# Check database
SHOW DATABASES;
USE qbcore;
SHOW TABLES;

# Re-import schema
mysql -u root -p qbcore < /opt/fivem/txData/server/qbcore.sql
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is open source and available under the MIT License.

## 🙏 Credits

- [QBCore Framework](https://github.com/qbcore-framework)
- [FiveM](https://fivem.net/)
- [txAdmin](https://github.com/tabarra/txAdmin)
- [oxmysql](https://github.com/overextended/oxmysql)

## 📞 Support

- Issues: [GitHub Issues](https://github.com/dukex/ansible-qbcore-installer/issues)
- QBCore Discord: [QBCore Community](https://discord.gg/qbcore)
- FiveM Forums: [forum.cfx.re](https://forum.cfx.re/)

---

Made with ❤️ for the FiveM community
