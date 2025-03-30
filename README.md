# SimpleBTP - Italian Government Bonds Tracker

A Human-Computer Interaction project for the ACSAI course at Sapienza University of Rome. This application provides an interface for tracking and analyzing Italian Government Bonds (BTP - Buoni del Tesoro Poliennali).

## Project Structure

- `frontend/` - Contains the Flutter application interface
  - `simpleBTP/` - Main Flutter application with cross-platform support
- `scripts/` - Python scripts for data collection and processing
  - `btp_list_scraper.py` - Scrapes BTP listings from Borsa Italiana website
  - `btp_name_parser.py` - Extracts and processes BTP names and attributes
  - `btp_price_api.py` - Fetches real-time BTP prices from Il Sole 24 Ore API
- `designs/` - Contains design assets and mockups
  - `ios/` - iOS-specific design elements

## Features

- Real-time BTP data tracking and visualization
- Price history monitoring with different time windows
- Bond details including maturity date and coupon information
- Portfolio management for your BTP investments
- Cross-platform support (iOS, Android, Web, Windows, macOS, Linux)
- Offline data storage with Hive database

## Technologies Used

- Flutter framework for cross-platform frontend development
- Dart programming language
- Python for data scraping and API integration
- Hive for local data persistence
- HTTP requests for API communication
- Syncfusion and FL Chart libraries for data visualization

## Getting Started

### Prerequisites
- Flutter SDK (version 3.0.6 or higher)
- Dart SDK (compatible with Flutter version)
- Python 3.6 or higher
- pip (Python package manager)

### Frontend Setup
1. Clone the repository:
   ```
   git clone https://github.com/yourusername/simpleBTP.git
   cd simpleBTP
   ```

2. Install Flutter dependencies:
   ```
   cd frontend/simpleBTP
   flutter pub get
   ```

3. Run the application:
   ```
   flutter run
   ```
   
   This will launch the app on your connected device or emulator.

### Python Scripts Setup
1. Install Python dependencies:
   ```
   pip install requests
   ```

2. Run the scripts individually as needed:
   ```
   python scripts/btp_list_scraper.py  # Scrape BTP listings
   python scripts/btp_price_api.py     # Fetch BTP prices
   ```

## Building for Production

### Android
```
flutter build apk --release
```

### iOS
```
flutter build ios --release
```

### Web
```
flutter build web --release
```

## Contributing

This project is part of the Human-Computer Interaction course at Sapienza University of Rome.
