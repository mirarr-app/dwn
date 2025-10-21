# DWN - Download Manager

A modern, Material 3 design download manager for Linux desktop built with Flutter.

## Features

### Download Management
- **Add Downloads**: Add single or multiple URLs (batch download)
- **Real-time Progress**: Live progress tracking with percentage and visual indicators
- **Download Control**: Pause, resume, and cancel downloads
- **Queue System**: Automatic queuing with configurable concurrent downloads
- **Resume Support**: Pause and resume downloads with partial file support
- **Download History**: Track completed downloads with timestamps and file sizes

### User Interface
- **Material 3 Design**: Modern, adaptive color schemes with light/dark mode support
- **Desktop-Optimized**: NavigationRail layout optimized for desktop use
- **Three Main Screens**:
  - **Active Downloads**: View and manage ongoing, paused, and queued downloads
  - **Completed Downloads**: Browse download history with quick access to files
  - **Settings**: Customize download directory, concurrent downloads, and theme

### Additional Features
- **Default Download Location**: ~/Downloads/dwn (configurable)
- **File Operations**: Open downloaded files or their containing folders
- **Configurable Concurrency**: Set max concurrent downloads (1-10)
- **Theme Support**: Light, dark, and system theme modes
- **History Management**: Clear download history (files remain intact)

## Installation

### Prerequisites
- Flutter SDK (3.9.2 or higher)
- Linux desktop environment

### Setup
1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Build the application:
   ```bash
   flutter build linux --release
   ```
4. Run the application:
   ```bash
   flutter run -d linux
   ```

## Usage

### Adding Downloads
1. Click the "+" button or FAB in Active Downloads screen
2. Choose between single URL or batch mode
3. Enter URL(s) and click "Add"
4. Downloads will automatically start based on queue settings

### Managing Downloads
- **Pause**: Click pause button on any downloading item
- **Resume**: Click play button on any paused item
- **Cancel**: Click close button to cancel and remove from queue
- **Remove**: Delete failed or canceled downloads from the list

### Viewing Completed Downloads
1. Navigate to "Completed" section
2. View download history with file information
3. Click folder icon to open containing folder
4. Click launch icon to open the file
5. Remove individual items from history as needed

### Customizing Settings
- **Theme**: Switch between light, dark, or system theme
- **Download Directory**: Choose custom location for downloads
- **Max Concurrent Downloads**: Adjust simultaneous download limit (1-10)
- **Clear History**: Remove all completed download records

## Project Structure

```
lib/
├── main.dart                          # App entry point and main layout
├── theme/
│   └── app_theme.dart                 # Material 3 theme configuration
├── screens/
│   ├── active_downloads_screen.dart   # Active downloads view
│   ├── completed_downloads_screen.dart # Download history view
│   └── settings_screen.dart           # App settings
├── widgets/
│   ├── add_download_dialog.dart       # URL input dialog
│   └── download_item_card.dart        # Download item UI component
├── providers/
│   ├── download_provider.dart         # Download state management
│   └── settings_provider.dart         # Settings state management
└── services/
    └── download_manager/              # Core download logic
        ├── download_request.dart      # Download request model
        ├── download_status.dart       # Download status enum
        ├── download_task.dart         # Download task model
        └── downloader.dart            # Download manager singleton
```

## Technologies

- **Flutter**: Cross-platform UI framework
- **Dio**: HTTP client for downloads with progress tracking
- **Provider**: State management
- **Material 3**: Modern design system
- **SharedPreferences**: Settings persistence
- **path_provider**: System directory access
- **file_picker**: Directory selection
- **url_launcher**: File/folder opening

## License

This project is open source and available under the MIT License.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
