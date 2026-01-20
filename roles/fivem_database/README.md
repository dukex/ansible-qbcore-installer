# fivem_database

MariaDB database installation and configuration role for FiveM server.

## Description

Installs and configures MariaDB database server with security hardening, performance tuning, and FiveM user/database setup.

## Requirements

- Ansible >= 2.10
- Debian 11+ or Ubuntu 20.04+
- Root or sudo access

## Role Variables

```yaml
install_mariadb: true
mariadb_packages:
  - mariadb-server
  - mariadb-client
  - python3-pymysql

mariadb_root_user: "root"
mariadb_root_password: ""  # Required
mariadb_bind_address: "127.0.0.1"
mariadb_port: 3306

database_name: "fivem_server"
database_user: "fivem"
database_password: ""  # Required
database_host: "localhost"

mariadb_max_connections: 1000
mariadb_max_allowed_packet: "256M"
mariadb_innodb_buffer_pool_size: "100M"
mariadb_innodb_log_file_size: "100M"
```

## Dependencies

None.

## Example Playbook

```yaml
- hosts: servers
  roles:
    - role: dukex.fivem.fivem_database
      vars:
        mariadb_root_password: "{{ vault_db_root_password }}"
        database_name: "qbcore"
        database_user: "qbcore"
        database_password: "{{ vault_db_password }}"
```

## Tags

- `database` - All database tasks
- `database_install` - Installation only
- `database_security` - Security hardening only
- `database_fivem` - Database/user creation only
- `database_configuration` - Configuration tuning only

## Handlers

- `Restart MariaDB` - Restarts database service
- `Reload MariaDB` - Reloads database configuration

## Security Features

- Root password protection
- Anonymous user removal
- Test database removal
- Localhost-only bind address by default
- Dedicated database user with limited privileges

## License

MIT

## Author

dukex <emersonalmeidax@gmail.com>
