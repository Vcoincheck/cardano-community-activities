# 🟡 Tools & External Binaries

External Cardano tools and command-line utilities.

## Contents

### cardano-cli-win64/
**Purpose**: Cardano command-line interface

Native Windows executable for Cardano blockchain operations.

**Usage**:
```bash
./cardano-cli-win64/cardano-cli --version
```

### cardano-address.exe
**Purpose**: Address generation and validation

Standalone tool for Cardano address operations.

**Size**: ~55 MB

### cardano-signer.exe
**Purpose**: Message signing utility

Tool for signing messages with Cardano keys.

**Size**: ~42 MB

### install-all.sh
**Purpose**: Automated tool installation (Unix)

Bash script for downloading and installing all tools on Linux/macOS.

**Usage**:
```bash
bash install-all.sh
```

## Installation

### Windows

Tools are pre-downloaded. Add to PATH:

```powershell
$env:Path += ";$(pwd)\cardano-cli-win64"
```

### Linux/macOS

```bash
bash install-all.sh
source setup-env.sh
```

## Usage

### Verify Installation

```bash
./cardano-cli-win64/cardano-cli --version
./cardano-address --version
./cardano-signer --version
```

### Add to System PATH

**Windows (PowerShell)**:
```powershell
$ToolsPath = "$PSScriptRoot\tools"
$env:Path = "$ToolsPath;$env:Path"
```

**Linux/macOS**:
```bash
export PATH="$(pwd)/tools:$PATH"
source setup-env.sh
```

## Versions

| Tool | Version | Platform |
|------|---------|----------|
| Cardano CLI | 8.14.0+ | Windows x64, Linux, macOS |
| Cardano Address | 3.12.0+ | Multi-platform |
| Cardano Signer | 1.32.0+ | Multi-platform |

## Getting Help

### Tool Documentation

```bash
./cardano-cli-win64/cardano-cli --help
./cardano-address --help
./cardano-signer --help
```

### Official Resources

- [Cardano CLI Documentation](https://github.com/IntersectMBO/cardano-cli)
- [Cardano Address Tool](https://github.com/IntersectMBO/cardano-addresses)
- [Cardano Signer](https://github.com/gitmachtl/cardano-signer)

## Troubleshooting

### Tools Not Found

```bash
# Check if tools exist
ls -la cardano-cli-win64/
file cardano-address.exe

# Add to PATH
export PATH="$(pwd):$PATH"
```

### Permission Errors

```bash
# Make executable
chmod +x cardano-cli-win64/*
chmod +x cardano-address
chmod +x cardano-signer
```

### Version Conflicts

```bash
# Check installed version
./cardano-cli-win64/cardano-cli --version

# Download specific version
bash install-all.sh
```

## Related

- C# Applications: `../csharp/`
- PowerShell Scripts: `../powershell/`
- Documentation: `../docs/`
