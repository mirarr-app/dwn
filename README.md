# DWN - Download Manager

A Simple Linux download manager that looks good, powered by the fast and lightweight `aria2c` download engine. With Omarchy theme support!

## Features

### Download Management
- **Add Downloads**: Add single or multiple URLs (batch download)
- **Real-time Progress**: Live progress tracking with percentage and visual indicators
- **Download Control**: Pause, resume, and cancel downloads
- **Queue System**: Automatic queuing with configurable concurrent downloads
- **Resume Support**: Pause and resume downloads with partial file support
- **Download History**: Track completed downloads with timestamps and file sizes


- **Theme Support**: Light, dark, and system theme modes


## Installation

### Arch Linux (AUR)
```bash
yay -S dwn-bin
```

### Prerequisites
- `aria2c` installed on the system


## Technologies

- **Flutter**: Cross-platform UI framework
- **aria2c**: Fast and lightweight command-line download utility used as the core engine
- **Provider**: State management
- **SharedPreferences**: Settings persistence
- **path_provider**: System directory access
- **file_selector**: Directory selection
- **url_launcher**: File/folder opening



