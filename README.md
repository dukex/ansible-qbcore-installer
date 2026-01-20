# dukex.fivem Collection

Comprehensive Ansible collection for deploying and managing **FiveM** game servers on Debian/Ubuntu Linux systems. This collection provides production-ready, modular roles for complete server setup, database configuration, and flexible deployment.

## Features

- **Multi-Framework Support**: QBCore, ESX, RedM, and custom frameworks
- **Modular Roles**: Independent, focused roles for each concern
- **Production Ready**: Comprehensive error handling, validation, and logging
- **Idempotent Deployment**: Safe to run multiple times
- **Highly Parameterized**: Customize every aspect via variables
- **Security Focused**: Firewall configuration, user isolation, secret management
- **Cloudflare Integration**: Nginx reverse proxy with origin certificate support

## Included Roles

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

## Quick Start

### Installation

```bash
# Install from Galaxy
ansible-galaxy collection install dukex.fivem

# Or clone for development
git clone https://github.com/dukex/ansible-fivem-collection.git
cd ansible-fivem-collection
```

### Basic Deployment

Create an inventory file `inventory.ini`:

```ini
[servers]
server1.example.com ansible_user=root
```

Create a playbook `deploy.yml`:

```yaml
---
- name: Deploy FiveM Server
  hosts: servers
  vars:
    fivem_domain: "myserver.example.com"
    fivem_artifact_download_url: "https://runtime.fivem.net/artifacts/fivem/build_proot_linux/master/17000-hash/fx.tar.xz"

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
        resources_git_url: "git@github.com:your-org/server-data.git"
```

Deploy:

```bash
ansible-playbook -i inventory.ini deploy.yml --ask-vault-pass
```

## Role Variables

### fivem_common

```yaml
fivem_user: "fivem"
fivem_group: "fivem"
fivem_server_path: "/opt/fivem"
fivem_install_dependencies: true
```

### fivem_firewall

```yaml
fivem_firewall_enabled: true
fivem_firewall_ports:
  - port: 22
    protocol: tcp
    comment: "SSH"
```

### fivem_nginx

```yaml
fivem_nginx_domain: "example.com"
fivem_nginx_public_port: 30120
fivem_nginx_use_origin_cert: false
# fivem_nginx_origin_cert: |
#   -----BEGIN CERTIFICATE-----
#   ...
#   -----END CERTIFICATE-----
```

### fivem_runtime

```yaml
fivem_artifact_download_url: "https://runtime.fivem.net/.../fx.tar.xz"
fivem_force_download_artifacts: false
```

### fivem_tuning

```yaml
fivem_tuning_enabled: true
```

### fivem_database

```yaml
mariadb_root_password: "changeme"
database_name: "fivem_server"
database_user: "fivem"
database_password: "changeme"
```

### fivem_deploy

```yaml
resources_git_url: ""
revision: "main"
```

## Documentation

- [Complete Role Documentation](./docs/roles.md)
- [Configuration Variables](./docs/variables.md)

## Requirements

- Ansible >= 2.10
- Python >= 3.6
- Target: Debian 11+, Ubuntu 20.04+
- Minimum: 2GB RAM, 20GB disk
- Network: SSH access, outbound HTTPS

## Role Dependencies

```
fivem_nginx      → depends on: fivem_common, fivem_firewall
fivem_runtime    → depends on: fivem_common
fivem_service    → depends on: fivem_common, fivem_runtime
fivem_database   → depends on: fivem_common
fivem_deploy     → depends on: fivem_service, fivem_database
```

## Selective Execution with Tags

```bash
# Run only setup roles
ansible-playbook deploy.yml -t setup

# Run only database role
ansible-playbook deploy.yml -t database

# Run only deployment
ansible-playbook deploy.yml -t deploy

# Skip tuning
ansible-playbook deploy.yml --skip-tags tuning
```

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Submit a pull request

## License

MIT License - See LICENSE file for details

## Support

For issues, questions, or feature requests:

- GitHub Issues: https://github.com/dukex/ansible-fivem-collection/issues

## Related Projects

- [txAdmin](https://github.com/citizenfx/txAdmin) - FiveM server management
- [QBCore Framework](https://github.com/qbcore-framework) - FiveM roleplay framework
- [ESX Framework](https://github.com/esx-framework) - Roleplay framework
