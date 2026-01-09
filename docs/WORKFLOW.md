# QBCore Git Submodules Workflow

This document explains how to work with the git submodules-based QBCore server setup.

## Table of Contents

1. [Initial Setup](#initial-setup)
2. [Daily Development](#daily-development)
3. [Making Local Modifications](#making-local-modifications)
4. [Updating Resources](#updating-resources)
5. [Deployment](#deployment)
6. [Common Operations](#common-operations)
7. [Troubleshooting](#troubleshooting)

## Initial Setup

### 1. Clone the Repository

```bash
# Clone with submodules
git clone --recurse-submodules https://github.com/YOUR_USERNAME/prdx-server.git
cd prdx-server

# OR if you already cloned without --recurse-submodules
git submodule update --init --recursive
```

### 2. Configure Variables

```bash
# Copy example configuration
cp vars.yml.example vars.yml

# Edit with your settings
vim vars.yml
```

**Important:** Update these values in `vars.yml`:
- `mariadb_root_password` - Strong password for MariaDB root
- `qbcore_db_password` - Strong password for QBCore database
- `fivem_license_key` - Your FiveM license key
- `qbcore_repo_url` - Your repository URL
- `server_name` - Your server name

### 3. Initialize Submodules (First Time Only)

If resources are not yet added as submodules:

```bash
# Run the setup script
./scripts/setup-submodules.sh

# This will:
# - Add all QBCore resources as git submodules
# - Remove the [gameplay]/chat folder
# - Create .gitignore for resources
```

### 4. Commit Submodules Configuration

```bash
git add .gitmodules base/dicotomia/resources/ .gitignore
git commit -m "Add QBCore resources as git submodules"
git push
```

## Daily Development

### Working with the Repository

```bash
# Always update submodules when pulling
git pull
git submodule update --init --recursive

# Check submodule status
git submodule status

# View which commit each submodule is on
git submodule foreach 'git log -1 --oneline'
```

## Making Local Modifications

### The Overlay System

Resources are organized as:
- `base/dicotomia/resources/` - Git submodules (pristine upstream)
- `base/dicotomia/resources-local/` - Your local modifications (tracked in main repo)

### Example: Customize QBCore Config

```bash
# 1. Create directory structure
mkdir -p base/dicotomia/resources-local/[qb]/qb-core/shared/

# 2. Copy file you want to modify
cp base/dicotomia/resources/[qb]/qb-core/shared/config.lua \
   base/dicotomia/resources-local/[qb]/qb-core/shared/config.lua

# 3. Edit the local copy
vim base/dicotomia/resources-local/[qb]/qb-core/shared/config.lua

# 4. Test locally (overlays are applied during deployment)

# 5. Commit to main repo
git add base/dicotomia/resources-local/
git commit -m "Customize QBCore spawn locations and economy"
git push
```

### Best Practices for Local Modifications

✅ **DO:**
- Only copy files you're actually modifying
- Document why you made changes (in commits or comments)
- Keep modifications minimal
- Test locally before deploying
- Review upstream changes when updating submodules

❌ **DON'T:**
- Copy entire resources (only modified files)
- Modify files directly in `resources/` (they're submodules)
- Commit submodule changes unless intentional
- Forget to test after updating submodules

## Updating Resources

### Update All Submodules to Latest

```bash
# Update all submodules to their latest commit on their default branch
git submodule update --remote --merge

# Review what changed
git diff

# Commit the updates
git add base/dicotomia/resources/
git commit -m "Update all QBCore resources to latest versions"
git push
```

### Update Specific Submodule

```bash
# Update only qb-core
cd base/dicotomia/resources/[qb]/qb-core
git pull origin main
cd ../../../../..

# Commit the update
git add base/dicotomia/resources/[qb]/qb-core
git commit -m "Update qb-core to latest version"
git push
```

### After Updating Submodules

1. **Review Changes:** Check if upstream modified files you've customized
2. **Test Locally:** Ensure your overlays still work
3. **Update Overlays:** If upstream renamed/moved files, update your overlays
4. **Deploy:** Test on staging server before production

## Deployment

### Deploy to Server

```bash
# Run the Ansible playbook
ansible-playbook qbcore-installation.yml

# What happens:
# 1. System packages installed
# 2. MariaDB installed and configured
# 3. Repository cloned with submodules to /opt/fivem/txData/dicotomia
# 4. oxmysql downloaded and extracted
# 5. Local modifications overlaid from resources-local/
# 6. Database schema imported
# 7. server.cfg configured
# 8. Symlink created: /opt/fivem/server-data/resources -> txData/dicotomia/resources
# 9. FiveM server artifacts downloaded
# 10. Systemd service created
```

### Deployment Flow Diagram

```
┌─────────────────────────────────────────┐
│  Clone Main Repo with Submodules        │
│  /opt/fivem/txData/dicotomia/            │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│  Submodules at:                          │
│  resources/[qb]/*, resources/[voice]/*   │
│  (Pristine upstream code)                │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│  Download Non-Git Resources              │
│  oxmysql → resources/[standalone]/       │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│  Apply Overlays                          │
│  rsync resources-local/ → resources/     │
│  (Your customizations applied)           │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│  Configure & Start                       │
│  Import SQL, setup server.cfg, start     │
└─────────────────────────────────────────┘
```

### Update Deployed Server

```bash
# SSH to server
ssh user@server

# Pull latest changes
cd /opt/fivem/txData/dicotomia
sudo -u fivem git pull
sudo -u fivem git submodule update --init --recursive

# Reapply overlays
sudo rsync -av --exclude='.gitkeep' --exclude='README.md' \
  base/dicotomia/resources-local/ \
  base/dicotomia/resources/

# Restart FiveM
sudo systemctl restart fivem
```

## Common Operations

### Check Submodule Status

```bash
# See which commit each submodule is on
git submodule status

# See if submodules have uncommitted changes
git submodule foreach git status

# See detailed info about all submodules
git submodule foreach 'echo $name: && git log -1 --oneline && echo'
```

### Sync Submodules to Match .gitmodules

```bash
# If .gitmodules was updated, sync the configuration
git submodule sync
git submodule update --init --recursive
```

### Add New Resource as Submodule

```bash
# Add a new custom resource
git submodule add -b main \
  https://github.com/some-org/custom-resource \
  base/dicotomia/resources/[standalone]/custom-resource

# Update resources-mapping.yml for documentation
vim resources-mapping.yml

# Commit
git add .gitmodules base/dicotomia/resources/ resources-mapping.yml
git commit -m "Add custom-resource as submodule"
git push
```

### Remove a Submodule

```bash
# Remove from git
git submodule deinit -f base/dicotomia/resources/[qb]/qb-UNWANTED
git rm -f base/dicotomia/resources/[qb]/qb-UNWANTED
rm -rf .git/modules/base/dicotomia/resources/[qb]/qb-UNWANTED

# Commit
git commit -m "Remove qb-UNWANTED resource"
git push
```

## Troubleshooting

### Submodule Shows as Modified but No Changes

```bash
# This usually means submodule is on different commit
cd base/dicotomia/resources/[qb]/qb-core
git status
git log -1

# To reset to tracked commit:
cd ../../../../..
git submodule update --init base/dicotomia/resources/[qb]/qb-core
```

### Overlay Not Applied on Server

1. Check file path matches exactly (case-sensitive)
2. Verify rsync command in Ansible output
3. Check file permissions
4. Ensure `use_git_submodules: true` in vars.yml

### Submodule Update Failed

```bash
# Common issues:

# 1. Local changes in submodule
cd base/dicotomia/resources/[qb]/qb-core
git status
# Either commit or stash changes

# 2. Detached HEAD state
git checkout main

# 3. Merge conflicts
git pull origin main
# Resolve conflicts if any
```

### Deployment Failed to Clone Submodules

Check:
1. Server has internet access
2. Server can access GitHub (SSH keys if private repo)
3. Submodule URLs are correct in `.gitmodules`
4. Git version on server is >= 2.13

```bash
# On server, test git access
git ls-remote https://github.com/qbcore-framework/qb-core
```

### Local Modifications Lost After Update

Your modifications in `resources-local/` should never be affected by submodule updates. If lost:

```bash
# Check if files are still there
ls -la base/dicotomia/resources-local/[qb]/qb-core/

# Check git history
git log --all --full-history -- "base/dicotomia/resources-local/**"

# Restore from git
git checkout HEAD -- base/dicotomia/resources-local/
```

## Advanced Topics

### Using SSH Instead of HTTPS for Submodules

```bash
# Edit .gitmodules to use SSH URLs
vim .gitmodules
# Change: https://github.com/qbcore-framework/qb-core
# To:     git@github.com:qbcore-framework/qb-core.git

# Sync the changes
git submodule sync
```

### Pinning Specific Versions

```bash
# Pin qb-core to a specific version
cd base/dicotomia/resources/[qb]/qb-core
git checkout v1.2.3  # or specific commit SHA
cd ../../../../..

# Commit the pin
git add base/dicotomia/resources/[qb]/qb-core
git commit -m "Pin qb-core to v1.2.3"
git push
```

### Using Your Own Forks

```bash
# Fork repository on GitHub, then update submodule URL
cd base/dicotomia/resources/[qb]/qb-core
git remote set-url origin https://github.com/YOUR_USERNAME/qb-core.git
git remote add upstream https://github.com/qbcore-framework/qb-core.git

# Update .gitmodules
cd ../../../../..
vim .gitmodules
# Update URL for qb-core

git add .gitmodules
git commit -m "Switch qb-core to our fork"
```

## Resources

- [Git Submodules Documentation](https://git-scm.com/book/en/v2/Git-Tools-Submodules)
- [Ansible Git Module](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/git_module.html)
- [QBCore Framework](https://github.com/qbcore-framework)
- [FiveM Documentation](https://docs.fivem.net/)

## Getting Help

1. Check this workflow document
2. Review `base/dicotomia/resources-local/README.md`
3. Check Ansible playbook logs: `journalctl -u fivem`
4. Create an issue in the repository
