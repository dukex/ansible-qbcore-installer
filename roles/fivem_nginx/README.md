# fivem_nginx

Nginx reverse proxy role for FiveM server with TCP/UDP stream support.

## Description

Configures Nginx as a reverse proxy for FiveM with TCP/UDP stream support, SSL/TLS termination, and Cloudflare origin certificate integration.

## Requirements

- Ansible >= 2.10
- Debian 11+ or Ubuntu 20.04+
- Root or sudo access

## Role Variables

```yaml
fivem_nginx_domain: "example.com"
fivem_nginx_public_port: 30120
fivem_server_port: 30120
fivem_txadmin_port: 40120
fivem_nginx_cache_path: "/var/cache/nginx/fivem"
fivem_nginx_cache_size: "20g"
fivem_nginx_use_origin_cert: false
fivem_nginx_configure_firewall: true
# fivem_nginx_origin_cert: |
#   -----BEGIN CERTIFICATE-----
#   ...
#   -----END CERTIFICATE-----
# fivem_nginx_origin_cert_key: |
#   -----BEGIN PRIVATE KEY-----
#   ...
#   -----END PRIVATE KEY-----
```

## Dependencies

- fivem_common
- fivem_firewall

## Example Playbook

```yaml
- hosts: servers
  roles:
    - role: dukex.fivem.fivem_nginx
      vars:
        fivem_nginx_domain: "myserver.example.com"
        fivem_nginx_use_origin_cert: true
        fivem_nginx_origin_cert: "{{ vault_nginx_cert }}"
        fivem_nginx_origin_cert_key: "{{ vault_nginx_key }}"
```

## Tags

- `nginx` - All Nginx tasks
- `firewall` - Firewall integration tasks
- `custom_files` - Custom file deployment

## Handlers

- `Reload nginx` - Reloads Nginx configuration
- `Restart nginx` - Restarts Nginx service

## License

MIT

## Author

dukex <emersonalmeidax@gmail.com>
