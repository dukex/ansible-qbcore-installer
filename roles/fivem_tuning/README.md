# fivem_tuning

System performance optimization role for FiveM server.

## Description

Optimizes system performance for FiveM server with file descriptor limits and network stack tuning.

## Requirements

- Ansible >= 2.10
- Debian 11+ or Ubuntu 20.04+
- Root or sudo access

## Role Variables

```yaml
fivem_tuning_enabled: true
fivem_user: "fivem"
```

## Dependencies

None.

## Example Playbook

```yaml
- hosts: servers
  roles:
    - role: dukex.fivem.fivem_tuning
```

## Applied Tuning

### File Descriptors

```
fivem  soft  nofile  65536
fivem  hard  nofile  65536
fivem  soft  nproc   32768
fivem  hard  nproc   32768
```

### Network Tuning (sysctl)

```
net.core.somaxconn = 65535
net.ipv4.tcp_max_syn_backlog = 65535
net.ipv4.ip_local_port_range = 1024 65535
net.ipv4.tcp_fin_timeout = 30
net.core.netdev_max_backlog = 5000
net.ipv4.tcp_tw_reuse = 1
```

## Tags

- `tuning` - All tuning tasks

## License

MIT

## Author

dukex <emersonalmeidax@gmail.com>
