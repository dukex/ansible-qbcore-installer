# fivem_deploy

Git-based server data deployment role for FiveM server.

## Description

Deploys FiveM server data from a Git repository with automatic SSH key generation for private repositories.

## Requirements

- Ansible >= 2.10
- Debian 11+ or Ubuntu 20.04+
- Root or sudo access
- Git installed on target

## Role Variables

```yaml
server_data_folder: "/opt/fivem/txData/game"
git_repo_data: ""  # Required - Git repository URL
revision: "main"
git_deploy_key_path: "/opt/fivem/fivem_repo_key"
database_name: "fivem_server"
database_user: "fivem"
database_host: "localhost"
database_port: 3306
```

## Dependencies

- fivem_service
- fivem_database

## Example Playbook

```yaml
- hosts: servers
  roles:
    - role: dukex.fivem.fivem_deploy
      vars:
        git_repo_data: "git@gitlab.com:yourorg/server-data.git"
        revision: "production"
        server_domain: "myserver.example.com"
```

## SSH Key Generation

On first run with a private repository, the role:

1. Generates an Ed25519 SSH key pair
2. Displays the public key in the output
3. You must add this key to your repository's deploy keys

### Adding Deploy Keys

- **GitLab**: Settings → Repository → Deploy keys
- **GitHub**: Settings → Deploy keys

## Tags

- `deploy` - All deployment tasks
- `deploy_data` - Data deployment only
- `resources` - Resource management
- `config` - Configuration templating

## License

MIT

## Author

dukex <emersonalmeidax@gmail.com>
