# fivem_service

Systemd service setup role for FiveM server.

## Description

Creates and manages the systemd service for FiveM server, including the run script and service unit file.

## Requirements

- Ansible >= 2.10
- Debian 11+ or Ubuntu 20.04+
- Root or sudo access
- systemd

## Role Variables

```yaml
fivem_server_path: "/opt/fivem"
fivem_user: "fivem"
fivem_group: "fivem"
```

## Dependencies

- fivem_common
- fivem_runtime

## Example Playbook

```yaml
- hosts: servers
  roles:
    - role: dukex.fivem.fivem_service
```

## Service Management

```bash
# Check status
systemctl status fivem

# View logs
journalctl -u fivem -f

# Restart service
systemctl restart fivem

# Stop service
systemctl stop fivem
```

## Tags

- `service` - All service tasks

## Handlers

- `Reload systemd` - Reloads systemd daemon
- `Restart fivem` - Restarts FiveM service

## License

MIT

## Author

dukex <emersonalmeidax@gmail.com>
