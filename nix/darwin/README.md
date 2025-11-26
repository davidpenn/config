# nix-darwin Configuration

This directory contains a [nix-darwin](https://github.com/nix-darwin/nix-darwin) flake configuration for managing macOS systems declaratively using Nix.

## What This Configuration Does

This flake provides a reproducible, declarative way to configure macOS systems. It manages:

- **System Packages**: CLI tools and development utilities installed via Nix
- **Homebrew Integration**: GUI applications (casks) and formulae not available in nixpkgs
- **macOS System Settings**: Dock, Finder, keyboard, trackpad, and global preferences
- **User Configuration**: Via home-manager integration for dotfiles and user-level settings

### Available Configurations

The flake defines two machine configurations:

1. **`ssc`**: Work machine configuration
   - User: `davidpenn`
   - Includes work-specific git settings
   - Configured with SecurityScorecard email and SSH signing key

2. **`titan`**: Personal machine configuration
   - User: `david`
   - Hostname: `titan`
   - Additional personal applications (Spotify, WhatsApp, gaming tools, etc.)

### Key Features

**Package Management**:
- Development tools (git, neovim, claude-code)
- Cloud/infrastructure tools (kubectl, k9s, terraform via tenv, vault)
- Programming languages (Go, Scala, Python via uv, Node.js via fnm)
- Data tools (duckdb, postgresql, spark, databricks-cli)
- Modern CLI replacements (eza, ripgrep, zoxide, fzf)

**System Preferences**:
- Dark mode enabled
- 24-hour time format
- Dock auto-hides with minimal size
- Fast key repeat rates
- Column view in Finder
- Tap-to-click enabled on trackpad

**Modular Design**:
- `mkDarwinConfiguration` helper function for shared configuration
- Machine-specific overrides via additional modules
- Home-manager integration for user dotfiles (imported from `../home`)

## Installation

### 1. Install Nix

Use the Determinate Systems installer (recommended for flakes support):

```sh
curl -fsSL https://install.determinate.systems/nix | sh -s -- install --prefer-upstream-nix
```

### 2. Initial Setup

On the first run, bootstrap nix-darwin using the flake from GitHub:

```sh
sudo nix run nix-darwin --extra-experimental-features "nix-command flakes" -- switch --flake "github:davidpenn/config?dir=nix/darwin#config_name"
```

Replace `config_name` with either `ssc` or `titan` depending on your machine.

### 3. Subsequent Updates

After initial setup, use the `darwin-rebuild` command:

```sh
sudo darwin-rebuild switch --flake "github:davidpenn/config?dir=nix/darwin#config_name"
```

Or if working with a local clone:

```sh
sudo darwin-rebuild switch --flake ./nix/darwin#config_name
```
