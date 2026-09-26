# Quran & Hadith Application

A comprehensive, cross-platform Islamic application featuring Quran recitations, Hadith collections, prayer timings, and intelligent search. Built with a Flutter frontend and a Python FastAPI backend.

---

## Repository Structure

```
flutter_hadith_app/
├── flutter_app/                  # Flutter application (Mobile, Web, Desktop)
│   ├── android/                  # Android native project
│   ├── assets/                   # Fonts, audio, and static assets
│   ├── ios/                      # iOS native project
│   ├── lib/                      # Core Flutter/Dart source code
│   │   ├── core/                 # Constants, theme, audio services, utils
│   │   ├── data/                 # Datasources (local SQLite & remote REST) & repositories
│   │   ├── presentation/         # Pages, Riverpod providers, router, widgets
│   │   └── shared/               # Data models for Quran, Hadith, Settings
│   ├── linux/                    # Linux desktop runner
│   ├── macos/                    # macOS desktop runner
│   ├── test/                     # Unit and widget tests
│   ├── web/                      # Flutter Web runner
│   ├── windows/                  # Windows desktop runner
│   ├── pubspec.yaml              # Flutter dependencies and assets
│   └── analysis_options.yaml     # Dart analysis rules
│
├── python_backend/               # Python FastAPI backend service
│   ├── main.py                   # FastAPI application & audio endpoints
│   ├── requirements.txt          # Python dependencies
│   ├── .env                      # Environment configuration
│   └── README.md                 # Backend documentation & API spec
│
├── .gitignore                    # Unified gitignore for Flutter & Python
└── README.md                     # Repository overview & setup guide
```

---

## 1. Flutter Application (`flutter_app/`)

### Key Features
- **Quran Reader**: Surah and Juz views, Uthmani Arabic script, transliteration, and multiple translation languages.
- **Synchronized Audio Player**: Continuous verse-by-verse recitation with active verse highlighting, dynamic bolding, and auto-scrolling.
- **Reciter Selection**: Country-grouped reciters (e.g., Sheikh Mishari Rashid, Sheikh Yasser Al-Dosari, Sheikh Sudais, etc.).
- **Hadith Collections**: Sahih al-Bukhari, Sahih Muslim, Sunan Abi Dawud, Jami` at-Tirmidhi, and more with chapter navigation and narrator chains.
- **Prayer Timings**: Namaz timing integration with daily prayer schedules.
- **Reading Settings Panel**: Customizable font sizes and toggles for Arabic, Translation, and Transliteration.
- **Bookmarks & Offline Support**: Local caching for uninterrupted reading.

### Getting Started

```bash
cd flutter_app

# Fetch dependencies
flutter pub get

# Run on Chrome/Edge (Web)
flutter run -d chrome

# Run on Windows Desktop
flutter run -d windows

# Run on Mobile (connected device/emulator)
flutter run
```

### Testing

```bash
cd flutter_app
flutter test
```

---

## 2. Python Backend (`python_backend/`)

A lightweight FastAPI service providing Quran reciter discovery, country mapping, and audio URL resolution.

### Getting Started

```bash
cd python_backend

# Create virtual environment (optional)
python -m venv .venv
# Windows:
.venv\Scripts\activate
# Linux/macOS:
source .venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Run the API server
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

- API Documentation: `http://localhost:8000/docs`
- Health Check: `http://localhost:8000/health`