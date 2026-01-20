# fivem_runtime

FiveM runtime artifact download and version management role.

## Description

Downloads and manages FiveM server runtime artifacts with intelligent version tracking to avoid redundant downloads.

## Requirements

- Ansible >= 2.10
- Debian 11+ or Ubuntu 20.04+
- Root or sudo access

## Role Variables

```yaml
fivem_artifact_download_url: "https://runtime.fivem.net/artifacts/fivem/build_proot_linux/master/17000-hash/fx.tar.xz"
fivem_force_download_artifacts: false
fivem_server_path: "/opt/fivem"
fivem_user: "fivem"
fivem_group: "fivem"
```

## Dependencies

- fivem_common

## Example Playbook

```yaml
- hosts: servers
  roles:
    - role: dukex.fivem.fivem_runtime
      vars:
        fivem_artifact_download_url: "https://runtime.fivem.net/artifacts/fivem/build_proot_linux/master/24079-hash/fx.tar.xz"
```

## Version Tracking

The role writes the artifact URL to `.version` file in the server path. On subsequent runs:
- If the URL matches, no download occurs
- If the URL differs, the new artifact is downloaded
- Set `fivem_force_download_artifacts: true` to force re-download

## Tags

- `runtime` - All runtime tasks

## License

MIT

## Author

dukex <emersonalmeidax@gmail.com>
