# Local Resource Modifications (Overlays)

This directory contains your **local modifications** to QBCore resources that override the upstream versions.

## How It Works

1. **Resources** in `resources/` are git submodules (pristine upstream code)
2. **Your local changes** go in `resources-local/` (this directory)
3. During deployment, Ansible **copies resources first**, then **overlays your changes**
4. Your local changes are tracked in the main repo, never pushed to upstream

## Directory Structure

Mirror the structure from `resources/`:

```
resources-local/
├── [qb]/
│   ├── qb-core/
│   │   └── shared/
│   │       └── config.lua      # Your customized config
│   ├── qb-inventory/
│   │   └── config.lua          # Your customized inventory config
│   └── qb-multicharacter/
│       └── html/
│           └── style.css       # Custom branding
├── [standalone]/
│   └── pma-voice/
│       └── config.lua          # Voice configuration
└── [voice]/
    └── qb-radio/
        └── config.lua          # Radio settings
```

## Usage Examples

### Example 1: Customize QBCore Config

```bash
# 1. Create directory structure
mkdir -p resources-local/[qb]/qb-core/shared/

# 2. Copy file you want to modify
cp resources/[qb]/qb-core/shared/config.lua \
   resources-local/[qb]/qb-core/shared/config.lua

# 3. Edit the local copy
vim resources-local/[qb]/qb-core/shared/config.lua

# 4. Commit to main repo
git add resources-local/
git commit -m "Customize QBCore server settings"
```

### Example 2: Custom Branding

```bash
# Add custom logo
mkdir -p resources-local/[qb]/qb-multicharacter/html/
cp my-logo.png resources-local/[qb]/qb-multicharacter/html/logo.png

git add resources-local/
git commit -m "Add custom server logo"
```

### Example 3: Modify Multiple Files

```bash
# Create overlay structure
mkdir -p resources-local/[qb]/qb-inventory/

# Copy files
cp resources/[qb]/qb-inventory/config.lua resources-local/[qb]/qb-inventory/
cp resources/[qb]/qb-inventory/server/main.lua resources-local/[qb]/qb-inventory/server/

# Make changes, then commit
git add resources-local/
git commit -m "Customize inventory weight limits"
```

## Best Practices

### ✅ DO
- Only include files you've actually modified
- Keep modifications minimal and documented
- Comment why you changed things
- Test changes locally before deploying
- Keep this README updated with common customizations

### ❌ DON'T
- Copy entire resources (only copy modified files)
- Modify files in `resources/` submodules directly
- Push submodule changes unless you forked the repo
- Forget to test after updating submodules

## Updating Upstream Resources

When you update submodules, your overlays remain intact:

```bash
# Update all submodules to latest
git submodule update --remote --merge

# Your overlays in resources-local/ are NOT affected
# They will be applied on top during next deployment
```

## Deployment Flow

When Ansible deploys to the server:

1. Clone main repo with submodules → `/opt/fivem/txData/dicotomia/`
2. Copy `resources/` → `/opt/fivem/txData/dicotomia/resources/`
3. Download non-git resources (oxmysql) → `resources/[standalone]/`
4. **Overlay** `resources-local/` → `resources/` (overwrites matching files)
5. Set proper permissions
6. Start FiveM server

## Common Customizations

Document your common customizations here:

### Server Settings
- `[qb]/qb-core/shared/config.lua` - Core server configuration
  - Changed server name to "Paradoxo RP"
  - Modified spawn locations
  - Adjusted economy settings

### Jobs Configuration
- `[qb]/qb-policejob/config.lua` - Police job settings
  - Custom ranks and salaries

### Voice Settings
- `[standalone]/pma-voice/config.lua` - Voice chat configuration
  - Adjusted voice ranges

## Troubleshooting

### My changes aren't being applied

1. Check file path matches exactly: `resources-local/[qb]/qb-core/config.lua`
2. Verify Ansible playbook includes overlay task
3. Check file permissions on server
4. Review Ansible deployment logs

### Submodule update broke my changes

Your overlays should be safe, but check:
1. Did upstream rename/move the file?
2. Are there new config options to add?
3. Review git diff on the submodule

### Want to contribute changes upstream

1. Fork the upstream repository
2. Make changes in your fork
3. Update submodule to point to your fork
4. Or submit PR to upstream project

## Notes

- This directory is tracked by git (not a submodule)
- Changes here only affect YOUR server, not upstream
- Keep this directory clean and organized
- Document major customizations in comments or this README
