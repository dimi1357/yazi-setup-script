# Yazi Setup Script for Ubuntu

Automated installation script for [Yazi](https://github.com/sxyazi/yazi) file manager with custom plugins on Ubuntu/Debian systems.

## Features

This script installs:

- **Yazi** - Terminal file manager (latest release from GitHub)
- **rich-cli** - For enhanced text/code previews
- **Yazi Plugins**:
  - [rich-preview.yazi](https://github.com/AnirudhG07/rich-preview.yazi) - Enhanced preview for code, markdown, JSON, CSV files
  - [pickle.yazi](https://github.com/dimi1357/pickle.yazi) - Preview Python pickle files
  - [mesh-preview.yazi](https://github.com/dimi1357/mesh-preview.yazi) - Preview 3D mesh files (OBJ, STL, PLY, GLTF, etc.)

## Prerequisites

- Ubuntu/Debian-based system
- `sudo` privileges
- Internet connection

## Usage

```bash
chmod +x install_yazi_ubuntu.sh
./install_yazi_ubuntu.sh
```

After installation, restart your shell:
```bash
exec $SHELL
```

Then start Yazi:
```bash
yazi
```

## What Gets Installed

### Required Dependencies
- curl, git
- python3, python3-pip, python3-venv
- file (for file type detection)
- unzip
- pipx

### Optional Dependencies (for enhanced functionality)
- ffmpeg (video thumbnails)
- 7zip (archive handling)
- jq (JSON processing)
- poppler-utils (PDF handling)
- fd-find (fast file finding)
- ripgrep (fast searching)
- fzf (fuzzy finder)
- zoxide (smart directory jumping)
- imagemagick (image processing)

### Plugins Setup
- Creates `~/.config/yazi/plugins/` directory
- Clones plugin repositories
- Sets up Python virtual environment for mesh-preview with required packages:
  - trimesh
  - pillow
  - numpy
  - matplotlib
  - fast-simplification

### Configuration
Creates `~/.config/yazi/yazi.toml` with:
- Editor configuration (uses $EDITOR or vi)
- Preview handlers for all supported file types

## Supported File Previews

- **Code/Text**: CSV, Markdown, reStructuredText, Jupyter notebooks, JSON
- **Python**: Pickle files (.pkl, .pickle)
- **3D Models**: OBJ, STL, PLY, GLTF, GLB, FBX, 3DS, OFF, DAE

## Notes

- The script will backup any existing `yazi.toml` to `yazi.toml.backup`
- If plugins already exist, the script will update them via `git pull`
- Yazi binaries are installed to `/usr/local/bin`

## License

This script is provided as-is for setting up Yazi and its plugins. Each component has its own license:
- Yazi: [MIT License](https://github.com/sxyazi/yazi/blob/main/LICENSE)
- Plugins: See individual plugin repositories
