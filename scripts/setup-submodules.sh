#!/bin/bash

# QBCore Resources Submodules Setup Script
# This script initializes all resources as git submodules based on resources-mapping.yml

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
MAPPING_FILE="$PROJECT_ROOT/resources-mapping.yml"

echo "╔════════════════════════════════════════════════════════════╗"
echo "║      QBCore Resources Submodules Setup                    ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

if [ ! -f "$MAPPING_FILE" ]; then
    echo "Error: resources-mapping.yml not found at $MAPPING_FILE"
    exit 1
fi

echo "✓ Found resources mapping file"
echo ""

check_dependencies() {
    echo "Checking dependencies..."

    if ! command -v git &> /dev/null; then
        echo "Error: git is not installed"
        exit 1
    fi

    if ! command -v yq &> /dev/null; then
        echo "Warning: yq is not installed. Install it for YAML parsing:"
        echo "  brew install yq  (macOS)"
        echo "  apt-get install yq  (Debian/Ubuntu)"
        echo ""
        echo "Falling back to manual parsing..."
        return 1
    fi

    return 0
}

add_submodule_manual() {
    local name=$1
    local url=$2
    local branch=$3
    local path=$4

    echo "  → Adding $name..."

    if [ -d "$PROJECT_ROOT/$path/.git" ] || grep -q "path = $path" "$PROJECT_ROOT/.gitmodules" 2>/dev/null; then
        echo "    ⚠ Submodule already exists, skipping..."
        return
    fi

    mkdir -p "$(dirname "$PROJECT_ROOT/$path")"

    if ! git -C "$PROJECT_ROOT" submodule add -b "$branch" "$url" "$path" 2>/dev/null; then
        echo "    ⚠ Failed to add submodule (might already exist)"
    else
        echo "    ✓ Added successfully"
    fi
}

manual_setup() {
    echo "Setting up submodules manually..."
    echo ""

    # CFX Default
    add_submodule_manual "cfx-server-data" \
        "https://github.com/citizenfx/cfx-server-data" \
        "master" \
        "txData/server/resources/[cfx-default]"

    # Standalone resources
    echo ""
    echo "Standalone resources:"
    add_submodule_manual "bob74_ipl" \
        "https://github.com/qbcore-framework/bob74_ipl" \
        "master" \
        "txData/server/resources/[standalone]/bob74_ipl"

    add_submodule_manual "safecracker" \
        "https://github.com/qbcore-framework/safecracker" \
        "main" \
        "txData/server/resources/[standalone]/safecracker"

    add_submodule_manual "screenshot-basic" \
        "https://github.com/citizenfx/screenshot-basic" \
        "master" \
        "txData/server/resources/[standalone]/screenshot-basic"

    add_submodule_manual "progressbar" \
        "https://github.com/qbcore-framework/progressbar" \
        "main" \
        "txData/server/resources/[standalone]/progressbar"

    add_submodule_manual "interact-sound" \
        "https://github.com/qbcore-framework/interact-sound" \
        "master" \
        "txData/server/resources/[standalone]/interact-sound"

    add_submodule_manual "connectqueue" \
        "https://github.com/qbcore-framework/connectqueue" \
        "master" \
        "txData/server/resources/[standalone]/connectqueue"

    add_submodule_manual "PolyZone" \
        "https://github.com/qbcore-framework/PolyZone" \
        "master" \
        "txData/server/resources/[standalone]/PolyZone"

    # Voice resources
    echo ""
    echo "Voice resources:"
    add_submodule_manual "pma-voice" \
        "https://github.com/AvarianKnight/pma-voice" \
        "main" \
        "txData/server/resources/[voice]/pma-voice"

    add_submodule_manual "qb-radio" \
        "https://github.com/qbcore-framework/qb-radio" \
        "main" \
        "txData/server/resources/[voice]/qb-radio"

    # Maps
    echo ""
    echo "Map resources:"
    add_submodule_manual "hospital_map" \
        "https://github.com/qbcore-framework/hospital_map" \
        "main" \
        "txData/server/resources/[defaultmaps]/hospital_map"

    add_submodule_manual "dealer_map" \
        "https://github.com/qbcore-framework/dealer_map" \
        "main" \
        "txData/server/resources/[defaultmaps]/dealer_map"

    add_submodule_manual "prison_map" \
        "https://github.com/qbcore-framework/prison_map" \
        "main" \
        "txData/server/resources/[defaultmaps]/prison_map"

    # QBCore resources
    echo ""
    echo "QBCore resources (this may take a while)..."

    local qb_resources=(
        "qb-core"
        "qb-scoreboard"
        "qb-adminmenu"
        "qb-multicharacter"
        "qb-target"
        "qb-vehiclesales"
        "qb-vehicleshop"
        "qb-houserobbery"
        "qb-prison"
        "qb-hud"
        "qb-management"
        "qb-weed"
        "qb-lapraces"
        "qb-inventory"
        "qb-houses"
        "qb-garages"
        "qb-ambulancejob"
        "qb-radialmenu"
        "qb-crypto"
        "qb-weathersync"
        "qb-policejob"
        "qb-apartments"
        "qb-vehiclekeys"
        "qb-mechanicjob"
        "qb-phone"
        "qb-vineyard"
        "qb-weapons"
        "qb-scrapyard"
        "qb-towjob"
        "qb-streetraces"
        "qb-storerobbery"
        "qb-spawn"
        "qb-smallresources"
        "qb-recyclejob"
        "qb-crafting"
        "qb-diving"
        "qb-cityhall"
        "qb-truckrobbery"
        "qb-pawnshop"
        "qb-minigames"
        "qb-taxijob"
        "qb-busjob"
        "qb-newsjob"
        "qb-fuel"
        "qb-jewelery"
        "qb-bankrobbery"
        "qb-banking"
        "qb-clothing"
        "qb-hotdogjob"
        "qb-doorlock"
        "qb-garbagejob"
        "qb-drugs"
        "qb-shops"
        "qb-interior"
        "qb-menu"
        "qb-input"
        "qb-loading"
    )

    for resource in "${qb_resources[@]}"; do
        add_submodule_manual "$resource" \
            "https://github.com/qbcore-framework/$resource" \
            "main" \
            "txData/server/resources/[qb]/$resource"

        # Add small delay to avoid GitHub rate limiting
        sleep 0.5
    done
}

remove_chat_folder() {
    echo ""
    echo "Removing [gameplay]/chat from cfx-default..."
    local chat_path="$PROJECT_ROOT/txData/server/resources/[cfx-default]/[gameplay]/chat"

    if [ -d "$chat_path" ]; then
        rm -rf "$chat_path"
        echo "  ✓ Removed chat folder"
    else
        echo "  ⚠ Chat folder not found (already removed or not yet cloned)"
    fi
}

create_gitignore() {
    echo ""
    echo "Creating .gitignore for resources..."

    cat > "$PROJECT_ROOT/txData/server/resources/.gitignore" << 'EOF'
# Downloaded resources (not submodules)
[standalone]/oxmysql/

# Local development files
*.log
*.cache
EOF

    echo "  ✓ Created .gitignore"
}

main() {
    cd "$PROJECT_ROOT"

    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo "Error: Not in a git repository"
        exit 1
    fi

    echo "Working directory: $PROJECT_ROOT"
    echo ""

    if ! check_dependencies; then
        echo "Using manual setup mode"
        echo ""
    fi

    manual_setup
    remove_chat_folder
    create_gitignore

    echo ""
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║                 Setup Complete!                           ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo ""
    echo "Next steps:"
    echo "1. Review the changes:"
    echo "   git status"
    echo ""
    echo "2. Initialize and update submodules:"
    echo "   git submodule update --init --recursive"
    echo ""
    echo "3. Commit the .gitmodules file:"
    echo "   git add .gitmodules txData/server/"
    echo "   git commit -m 'Add QBCore resources as submodules'"
    echo ""
    echo "4. To update all submodules to latest:"
    echo "   git submodule update --remote --merge"
    echo ""
}

main "$@"
