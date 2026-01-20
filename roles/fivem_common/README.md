# fivem_common

Base system setup role for FiveM server deployment.

## Description

Prepares the system with user accounts, group, directories, and essential dependencies required for FiveM server operation.

## Requirements

- Ansible >= 2.10
- Debian 11+ or Ubuntu 20.04+
- Root or sudo access

## Role Variables

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

## Dependencies

None.

## Example Playbook

```yaml
- hosts: servers
  roles:
    - role: dukex.fivem.fivem_common
```

## Tags

- `common` - All tasks
- `packages` - Package installation
- `user` - User/group creation
- `directories` - Directory creation

## License

MIT

## Author

dukex <emersonalmeidax@gmail.com>
