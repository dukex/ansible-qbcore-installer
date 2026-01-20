# FiveM Ansible Collection - Roles Documentation

## Overview

The dukex.fivem collection provides eight modular roles for deploying FiveM game servers:

| Role             | Description                                                |
| ---------------- | ---------------------------------------------------------- |
| `fivem_common`   | Base system setup - user, group, directories, dependencies |
| `fivem_firewall` | UFW firewall configuration                                 |
| `fivem_nginx`    | Nginx reverse proxy with TCP/UDP stream support            |
| `fivem_runtime`  | FiveM artifact download and version management             |
| `fivem_service`  | Systemd service setup                                      |
| `fivem_tuning`   | System performance optimization                            |
| `fivem_database` | MariaDB database installation and configuration            |
| `fivem_deploy`   | Git-based server data deployment                           |

## Role Dependencies

```
fivem_nginx      → depends on: fivem_common, fivem_firewall
fivem_runtime    → depends on: fivem_common
fivem_service    → depends on: fivem_common, fivem_runtime
fivem_database   → depends on: fivem_common
fivem_deploy     → depends on: fivem_service, fivem_database
```

---

## fivem_common Role

### Purpose

Prepares the base system for FiveM server deployment with user accounts, directories, and system dependencies.

### Tasks

- Install system dependencies (curl, wget, git, unzip, xz-utils, etc.)
- Create FiveM user and group
- Create directory structure (`/opt/fivem`, `/opt/fivem/txData`)

### Default Variables

```yaml
fivem_user: "fivem"
fivem_group: "fivem"
fivem_shell: "/bin/bash"
fivem_home_dir: "/home/{{ fivem_user }}"
fivem_server_path: "/opt/fivem"
fivem_server_data_path: "{{ fivem_server_path }}/txData"
fivem_install_dependencies: true
fivem_dependencies_packages:
  - curl
  - wget
  - git
  - unzip
  - xz-utils
  - build-essential
  - ca-certificates
  - apt-transport-https
  - lsb-release
  - gnupg2
  - neovim
  - ufw
```

### Tags

- `common` - All common tasks
- `packages` - Package installation only
- `user` - User/group creation only
- `directories` - Directory creation only

---

## fivem_firewall Role

### Purpose

Configures UFW firewall rules for FiveM server access.

### Tasks

- Enable UFW firewall with default deny policy
- Configure port rules from `fivem_firewall_ports` list

### Default Variables

```yaml
fivem_firewall_enabled: true
fivem_firewall_ports:
  - port: 22
    protocol: tcp
    comment: "SSH"
```

### Tags

- `firewall` - All firewall tasks

### Handlers

- `Reload firewall` - Applies firewall configuration changes

---

## fivem_nginx Role

### Purpose

Configures Nginx as a reverse proxy for FiveM with TCP/UDP stream support and Cloudflare integration.

### Tasks

- Install Nginx and stream module
- Create cache directory
- Configure SSL certificates (self-signed or Cloudflare origin)
- Deploy stream configuration (TCP/UDP proxy)
- Deploy HTTP configuration (HTTP/HTTPS with caching)
- Open firewall ports for HTTP/HTTPS and FiveM

### Default Variables

```yaml
fivem_nginx_domain: "example.com"
fivem_nginx_public_port: 30120
fivem_server_port: 30122
fivem_txadmin_port: 40120
fivem_nginx_cache_path: "/var/cache/nginx/fivem"
fivem_nginx_cache_size: "20g"
fivem_nginx_use_origin_cert: false
fivem_nginx_configure_firewall: true
```

### Tags

- `nginx` - All Nginx tasks
- `firewall` - Firewall integration tasks
- `custom_files` - Custom file deployment

### Handlers

- `Reload nginx` - Reloads Nginx configuration
- `Restart nginx` - Restarts Nginx service

### Cloudflare Origin Certificate

To use a Cloudflare Origin Certificate:

```yaml
fivem_nginx_use_origin_cert: true
fivem_nginx_origin_cert: |
  -----BEGIN CERTIFICATE-----
  ... your certificate ...
  -----END CERTIFICATE-----
fivem_nginx_origin_cert_key: |
  -----BEGIN PRIVATE KEY-----
  ... your key ...
  -----END PRIVATE KEY-----
```

---

## fivem_runtime Role

### Purpose

Downloads and manages FiveM server runtime artifacts with version tracking.

### Tasks

- Check if version file exists
- Compare current version with desired version
- Download FiveM artifact if update needed
- Extract artifact into server path
- Write version file for tracking
- Clean up temporary files

### Default Variables

```yaml
fivem_artifact_download_url: "https://runtime.fivem.net/artifacts/fivem/build_proot_linux/master/17000-hash/fx.tar.xz"
fivem_force_download_artifacts: false
fivem_server_path: "/opt/fivem"
fivem_user: "fivem"
fivem_group: "fivem"
```

### Tags

- `runtime` - All runtime tasks

### Version Tracking

The role writes the artifact URL to `.version` file in the server path. On subsequent runs:

- If the URL matches, no download occurs
- If the URL differs, the new artifact is downloaded
- Set `fivem_force_download_artifacts: true` to force re-download

---

## fivem_service Role

### Purpose

Creates and manages the systemd service for FiveM server.

### Tasks

- Deploy custom `run.sh` script
- Create systemd service file
- Reload systemd daemon
- Enable and start FiveM service

### Default Variables

```yaml
fivem_server_path: "/opt/fivem"
fivem_user: "fivem"
fivem_group: "fivem"
```

### Tags

- `service` - All service tasks

### Handlers

- `Reload systemd` - Reloads systemd daemon
- `Restart fivem` - Restarts FiveM service

### Service Management

```bash
# Check status
systemctl status fivem

# View logs
journalctl -u fivem -f

# Restart service
systemctl restart fivem
```

---

## fivem_tuning Role

### Purpose

Optimizes system performance for FiveM server with file descriptor limits and network tuning.

### Tasks

- Configure system limits in `/etc/security/limits.conf`
- Apply sysctl network tuning parameters

### Default Variables

```yaml
fivem_tuning_enabled: true
fivem_user: "fivem"
```

### Tags

- `tuning` - All tuning tasks

### Applied Tuning

**File Descriptors:**

```
fivem  soft  nofile  65536
fivem  hard  nofile  65536
fivem  soft  nproc   32768
fivem  hard  nproc   32768
```

**Network Tuning:**

```
net.core.somaxconn = 65535
net.ipv4.tcp_max_syn_backlog = 65535
net.ipv4.ip_local_port_range = 1024 65535
net.ipv4.tcp_fin_timeout = 30
net.core.netdev_max_backlog = 5000
net.ipv4.tcp_tw_reuse = 1
```

---

## fivem_database Role

### Purpose

Installs and configures MariaDB database server with security hardening and performance tuning.

### Tasks

- Install MariaDB packages
- Start and enable MariaDB service
- Set root password
- Remove anonymous users
- Disable test database
- Create FiveM database and user
- Apply performance tuning

### Default Variables

```yaml
install_mariadb: true
mariadb_packages:
  - mariadb-server
  - mariadb-client
  - python3-pymysql

mariadb_root_user: "root"
mariadb_bind_address: "127.0.0.1"
mariadb_port: 3306

database_name: "fivem_server"
database_user: "fivem"
database_host: "localhost"

mariadb_max_connections: 1000
mariadb_max_allowed_packet: "256M"
mariadb_innodb_buffer_pool_size: "100M"
```

### Tags

- `database` - All database tasks
- `database_install` - Installation only
- `database_security` - Security hardening only
- `database_fivem` - Database/user creation only
- `database_configuration` - Configuration tuning only

### Handlers

- `Restart MariaDB` - Restarts database service
- `Reload MariaDB` - Reloads database configuration

---

## fivem_deploy Role

### Purpose

Deploys FiveM server data from a Git repository with automatic SSH key generation.

### Tasks

- Ensure server data directory exists
- Generate SSH deploy key (if not provided)
- Clone or update Git repository
- Backup and sync resources
- Template configuration files
- Deploy custom assets

### Default Variables

```yaml
server_data_folder: "/opt/fivem/txData/game"
resources_git_url: ""
revision: "main"
git_deploy_key_path: "/opt/fivem/fivem_repo_key"
database_name: "fivem_server"
database_user: "fivem"
database_host: "localhost"
database_port: 3306
```

### Tags

- `deploy` - All deployment tasks
- `deploy_data` - Data deployment only
- `resources` - Resource management
- `config` - Configuration templating

### SSH Key Generation

On first run, the role generates an Ed25519 SSH key and displays the public key. Add this key to your repository's deploy keys:

- **GitLab**: Settings → Repository → Deploy keys
- **GitHub**: Settings → Deploy keys

---

## Combined Deployment Example

```yaml
---
- name: Complete FiveM Server Deployment
  hosts: servers
  become: true

  vars:
    fivem_domain: "myserver.example.com"
    fivem_artifact_download_url: "https://runtime.fivem.net/.../fx.tar.xz"
    resources_git_url: "git@gitlab.com:yourorg/server-data.git"

  pre_tasks:
    - name: Validate credentials
      assert:
        that:
          - mariadb_root_password is defined
          - resources_git_url is defined
        fail_msg: "Required variables not provided"

  roles:
    - role: dukex.fivem.fivem_common
      tags: [setup, common]

    - role: dukex.fivem.fivem_firewall
      tags: [setup, firewall]

    - role: dukex.fivem.fivem_nginx
      tags: [setup, nginx]
      vars:
        fivem_nginx_domain: "{{ fivem_domain }}"

    - role: dukex.fivem.fivem_tuning
      tags: [setup, tuning]

    - role: dukex.fivem.fivem_runtime
      tags: [setup, runtime]

    - role: dukex.fivem.fivem_service
      tags: [setup, service]

    - role: dukex.fivem.fivem_database
      tags: [database]
      vars:
        mariadb_root_password: "{{ vault_db_root_password }}"
        database_password: "{{ vault_db_password }}"

    - role: dukex.fivem.fivem_deploy
      tags: [deploy]
      vars:
        fivem_nginx_domain: "{{ fivem_domain }}"

  post_tasks:
    - name: Server ready
      debug:
        msg: "FiveM server ready at {{ inventory_hostname }}:30120"
```

---

## Selective Execution with Tags

```bash
# Run only setup roles
ansible-playbook deploy.yml -t setup

# Run only common and runtime
ansible-playbook deploy.yml -t common,runtime

# Run only database role
ansible-playbook deploy.yml -t database

# Run only deployment
ansible-playbook deploy.yml -t deploy

# Skip tuning
ansible-playbook deploy.yml --skip-tags tuning

# Force re-download artifact
ansible-playbook deploy.yml -t runtime -e "fivem_force_download_artifacts=true"
```

---

## Troubleshooting

### fivem_common Issues

- **Package installation fails**: Check apt sources and network connectivity
- **User creation failed**: Ensure running with `become: true`

### fivem_firewall Issues

- **Firewall not enabling**: Check UFW status with `ufw status`
- **Rules not applied**: Run handler manually or use `--flush-cache`

### fivem_nginx Issues

- **Nginx won't start**: Check configuration with `nginx -t`
- **SSL errors**: Verify certificate and key content
- **Proxy not working**: Check upstream server is running

### fivem_runtime Issues

- **Download fails**: Verify artifact URL is accessible
- **Extraction fails**: Check disk space and permissions
- **Version not updated**: Set `fivem_force_download_artifacts: true`

### fivem_service Issues

- **Service won't start**: Check logs with `journalctl -u fivem`
- **Permission denied**: Verify file ownership

### fivem_tuning Issues

- **Sysctl errors**: Some parameters may require kernel support

### fivem_database Issues

- **MariaDB won't start**: Check logs with `journalctl -u mariadb`
- **User creation fails**: Verify password meets requirements
- **Connection refused**: Ensure bind_address is correct

### fivem_deploy Issues

- **Git clone fails**: Add generated public key to repository deploy keys
- **Authentication error**: Check SSH key permissions (should be 600)
- **Branch not found**: Verify `revision` variable matches existing branch/tag
