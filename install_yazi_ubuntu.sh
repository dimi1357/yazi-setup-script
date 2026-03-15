#!/bin/bash

set -e  # Exit on error

echo "=== Installing Yazi on Ubuntu ==="

# Install required dependencies
echo "Installing dependencies..."
sudo apt update
sudo apt install -y curl git python3 python3-pip python3-venv file unzip pipx

# Install optional dependencies for enhanced functionality
echo "Installing optional dependencies (ffmpeg, 7zip, jq, poppler-utils, fd-find, ripgrep, fzf, zoxide, imagemagick)..."
sudo apt install -y ffmpeg 7zip jq poppler-utils fd-find ripgrep fzf zoxide imagemagick f3d || echo "Some optional dependencies may not be available on your system"

# Install cb (ClipBoard) for system-clipboard plugin
echo "Installing ClipBoard (cb) for system-clipboard plugin..."
if ! command -v cb &> /dev/null; then
    curl -sSL https://raw.githubusercontent.com/Slackadays/Clipboard/main/install.sh | bash
else
    echo "ClipBoard (cb) already installed"
fi

# Install Yazi - Download latest pre-built binary
echo "Downloading latest Yazi release..."
YAZI_VERSION=$(curl -s https://api.github.com/repos/sxyazi/yazi/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')
echo "Latest version: $YAZI_VERSION"

# Detect architecture
ARCH=$(uname -m)
case $ARCH in
    x86_64)
        YAZI_ARCH="x86_64-unknown-linux-gnu"
        ;;
    aarch64|arm64)
        YAZI_ARCH="aarch64-unknown-linux-gnu"
        ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

# Download and extract
YAZI_URL="https://github.com/sxyazi/yazi/releases/download/${YAZI_VERSION}/yazi-${YAZI_ARCH}.zip"
echo "Downloading from: $YAZI_URL"
cd /tmp
curl -LO "$YAZI_URL"
unzip -o "yazi-${YAZI_ARCH}.zip"

# Install binaries
echo "Installing Yazi binaries to /usr/local/bin..."
sudo mv "yazi-${YAZI_ARCH}/yazi" /usr/local/bin/
sudo mv "yazi-${YAZI_ARCH}/ya" /usr/local/bin/
sudo chmod +x /usr/local/bin/yazi /usr/local/bin/ya

# Clean up
rm -rf "yazi-${YAZI_ARCH}" "yazi-${YAZI_ARCH}.zip"

# Verify installation
if command -v yazi &> /dev/null; then
    echo "Yazi installed successfully: $(yazi --version)"
else
    echo "Error: Yazi installation failed"
    exit 1
fi

# Install rich-cli for rich-preview plugin
echo ""
echo "Installing rich-cli for rich-preview plugin..."
pipx ensurepath
pipx install rich-cli

echo ""
echo "=== Installing Yazi Plugins ==="

# Create plugins directory
PLUGINS_DIR="$HOME/.config/yazi/plugins"
mkdir -p "$PLUGINS_DIR"

# Install rich-preview.yazi
echo "Installing rich-preview.yazi..."
cd "$PLUGINS_DIR"
if [ -d "rich-preview.yazi" ]; then
    echo "rich-preview.yazi already exists, updating..."
    cd rich-preview.yazi && git pull && cd ..
else
    git clone https://github.com/AnirudhG07/rich-preview.yazi
fi

# Install pickle.yazi
echo "Installing pickle.yazi..."
cd "$PLUGINS_DIR"
if [ -d "pickle.yazi" ]; then
    echo "pickle.yazi already exists, updating..."
    cd pickle.yazi && git pull && cd ..
else
    git clone https://github.com/dimi1357/pickle.yazi
fi

# Install mesh-preview.yazi
echo "Installing mesh-preview.yazi..."
cd "$PLUGINS_DIR"
if [ -d "mesh-preview.yazi" ]; then
    echo "mesh-preview.yazi already exists, updating..."
    cd mesh-preview.yazi && git pull && cd ..
else
    git clone https://github.com/dimi1357/mesh-preview.yazi
fi

# Install f3d-preview.yazi
echo "Installing f3d-preview.yazi..."
cd "$PLUGINS_DIR"
if [ -d "f3d-preview.yazi" ]; then
    echo "f3d-preview.yazi already exists, updating..."
    cd f3d-preview.yazi && git pull && cd ..
else
    git clone https://github.com/ruudjhuu/f3d-preview.yazi
fi

# Install system-clipboard.yazi
echo "Installing system-clipboard.yazi..."
cd "$PLUGINS_DIR"
if [ -d "system-clipboard.yazi" ]; then
    echo "system-clipboard.yazi already exists, updating..."
    cd system-clipboard.yazi && git pull && cd ..
else
    git clone https://github.com/orhnk/system-clipboard.yazi
fi

# Setup virtual environment for mesh-preview
echo "Setting up Python virtual environment for mesh-preview..."
cd "$PLUGINS_DIR/mesh-preview.yazi"
python3 -m venv .venv
.venv/bin/pip install --upgrade pip
.venv/bin/pip install trimesh pillow numpy matplotlib fast-simplification
echo "mesh-preview.yazi virtual environment setup complete"
cd "$PLUGINS_DIR"

echo ""
echo "=== Configuring Yazi ==="

# Create or update yazi.toml
CONFIG_FILE="$HOME/.config/yazi/yazi.toml"

# Backup existing config if it exists
if [ -f "$CONFIG_FILE" ]; then
    echo "Backing up existing yazi.toml to yazi.toml.backup"
    cp "$CONFIG_FILE" "$CONFIG_FILE.backup"
fi

# Create the configuration
cat > "$CONFIG_FILE" << 'EOF'
[opener]
edit = [
    { run = '${EDITOR:-vi} "$@"', block = true, for = "unix" }
]

[plugin]
prepend_preloaders = [
    { url = "*.{3mf,obj,pts,ply,stl,step,stp}", run = "f3d-preview" },
]

prepend_previewers = [
    { url = "*.pkl", run = "pickle" },
    { url = "*.pickle", run = "pickle" },
    { url = "*.{3mf,obj,pts,ply,stl,step,stp}", run = "f3d-preview" },
    { url = "*.gltf", run = "mesh-preview" },
    { url = "*.glb", run = "mesh-preview" },
    { url = "*.fbx", run = "mesh-preview" },
    { url = "*.3ds", run = "mesh-preview" },
    { url = "*.off", run = "mesh-preview" },
    { url = "*.dae", run = "mesh-preview" },
    { url = "*.csv", run = "rich-preview"}, # for csv files
    { url = "*.md", run = "rich-preview" }, # for markdown (.md) files
    { url = "*.rst", run = "rich-preview"}, # for restructured text (.rst) files
    { url = "*.ipynb", run = "rich-preview"}, # for jupyter notebooks (.ipynb)
    { url = "*.json", run = "rich-preview"}, # for json (.json) files
]
EOF

echo "Configuration written to $CONFIG_FILE"

# Create or update keymap.toml for system-clipboard
KEYMAP_FILE="$HOME/.config/yazi/keymap.toml"

if [ -f "$KEYMAP_FILE" ]; then
    echo "Backing up existing keymap.toml to keymap.toml.backup"
    cp "$KEYMAP_FILE" "$KEYMAP_FILE.backup"
fi

cat > "$KEYMAP_FILE" << 'EOF'
[manager]
prepend_keymap = [
    { on = "<C-y>", run = "plugin system-clipboard", desc = "Copy to system clipboard" },
]
EOF

echo "Keymap configuration written to $KEYMAP_FILE"
echo ""
echo "=== Installation Complete ==="
echo ""
echo "Installed components:"
echo "  ✓ Yazi file manager"
echo "  ✓ rich-cli (for rich-preview plugin)"
echo "  ✓ f3d (for f3d-preview plugin)"
echo "  ✓ ClipBoard/cb (for system-clipboard plugin)"
echo ""
echo "Installed plugins:"
ls -1 "$PLUGINS_DIR"
echo ""
echo "Plugin details:"
echo "  • rich-preview.yazi - Enhanced preview for code/text files (CSV, Markdown, JSON, etc.)"
echo "  • pickle.yazi - Preview Python pickle files"
echo "  • mesh-preview.yazi - Preview 3D mesh files (GLTF, GLB, FBX, 3DS, OFF, DAE)"
echo "  • f3d-preview.yazi - Preview 3D files via f3d (3MF, OBJ, PTS, PLY, STL, STEP, STP)"
echo "  • system-clipboard.yazi - Copy files to system clipboard (Ctrl+Y)"
echo ""
echo "Configuration files:"
echo "  $CONFIG_FILE"
echo "  $KEYMAP_FILE"
echo ""
echo "IMPORTANT: You need to restart your shell for pipx and yazi PATH changes to take effect"
echo "After restarting, you can start yazi by typing: yazi"
