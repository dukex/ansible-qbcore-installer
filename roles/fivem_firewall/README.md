# fivem_firewall

UFW firewall configuration role for FiveM server.

## Description

Configures UFW firewall rules to secure the FiveM server while allowing necessary traffic.

## Requirements

- Ansible >= 2.10
- Debian 11+ or Ubuntu 20.04+
- Root or sudo access

## Role Variables

```yaml
fivem_firewall_enabled: true
fivem_firewall_ports:
  - port: 22
    protocol: tcp
    comment: "SSH"
```

## Dependencies

None.

## Example Playbook

```yaml
- hosts: servers
  roles:
    - role: dukex.fivem.fivem_firewall
      vars:
        fivem_firewall_ports:
          - port: 22
            protocol: tcp
            comment: "SSH"
          - port: 30120
            protocol: tcp
            comment: "FiveM TCP"
          - port: 30120
            protocol: udp
            comment: "FiveM UDP"
```

## Tags

- `firewall` - All firewall tasks

## Handlers

- `Reload firewall` - Applies firewall configuration changes

## License

MIT

## Author

dukex <emersonalmeidax@gmail.com>
