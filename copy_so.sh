#! /bin/bash

# NOTE nvim-treesitter installing is handled by RHEL so doesnt need to copy
# cp -r ../plugged/nvim-treesitter/parser/ /mnt/c/tools/neovim/plugged/linux-treesitter/
# cp -r ../plugged/nvim-treesitter/parser-info/ /mnt/c/tools/neovim/plugged/linux-treesitter/
# rm /mnt/c/tools/neovim/plugged/linux-treesitter/parser/.gitignore
# rm /mnt/c/tools/neovim/plugged/linux-treesitter/parser-info/.gitignore

# Configuration: Base paths
SRC_BASE="/home/z/.local/share/nvim/site/pack/deps/opt"
DEST_BASE="/mnt/c/Users/echay/AppData/Local/nvim-data/site/pack/deps/opt"

# Function: sync_libs()
# Arguments:
#   $1: Plugin Name
#   $2: Relative Subpath (use "" for root of plugin)
#   $3: File Pattern
sync_libs() {
    local plugin="$1"
    local subpath="$2"
    local pattern="$3"

    # Construct the base directory for this specific plugin/subpath
    # We strip trailing slashes to ensure paths build cleanly
    local src_dir="${SRC_BASE}/${plugin}/${subpath}"
    local dest_dir="${DEST_BASE}/${plugin}/${subpath}"

    # 1. Ensure destination exists
    if [ ! -d "$dest_dir" ]; then
        echo "Creating dir: $dest_dir"
        mkdir -p "$dest_dir"
    fi

    # 2. Check source existence
    # We use 'ls' to allow the $pattern (like *.so) to expand.
    # Redirecting stderr/stdout to null keeps it quiet.
    if ls "${src_dir}"/$pattern 1> /dev/null 2>&1; then
        echo "Syncing ${plugin}..."

        # 3. Clean Destination
        # Remove existing files matching the pattern in the destination.
        echo "  - Cleaning existing files in destination..."
        rm -f "${dest_dir}"/$pattern

        # 4. Copy New Files
        echo "  - Copying new files..."
        cp "${src_dir}"/$pattern "${dest_dir}/"
    else
        echo "Warning: No files found in: ${src_dir}/$pattern"
    fi
}

# --- Execution ---

# 1. blink.cmp
# Deletes 'libblink_cmp_fuzzy.so' in dest if exists, then copies new one.
sync_libs "blink.cmp" "target/release" "libblink_cmp_fuzzy.so"

# 2. vscode-diff.nvim
# Deletes any '*.so' files in dest, then copies new ones.
sync_libs "codediff.nvim" "" "*.so"

echo "Sync complete."
