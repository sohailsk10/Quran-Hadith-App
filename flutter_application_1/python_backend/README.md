# Quran Audio API - Python FastAPI Backend

A Python FastAPI backend that provides Quran audio URL resolution, reciter information, and country mapping for the Flutter Hadith App.

## Features

- **Reciter Management**: Get list of all available Quran reciters with Arabic names and recitation styles
- **Country Mapping**: Automatic country detection for reciters with flag emojis
- **Audio URL Resolution**: Resolve audio URLs for specific ayahs/surahs from multiple sources:
  - Quran.com API (primary)
  - everyayah.com (for Sheikh Yasser Al-Dosari)
  - verses.quran.com (fallback)
- **CORS Enabled**: Ready for Flutter web/mobile integration

## Quick Start

### 1. Install Dependencies

```bash
cd python_backend
pip install -r requirements.txt
```

### 2. Run the Server

```bash
# Development mode with auto-reload
uvicorn main:app --reload --host 0.0.0.0 --port 8000

# Production mode
uvicorn main:app --host 0.0.0.0 --port 8000
```

The API will be available at `http://localhost:8000`

### 3. API Documentation

- Swagger UI: `http://localhost:8000/docs`
- ReDoc: `http://localhost:8000/redoc`

## API Endpoints

### Health Check
```
GET /health
```

### Get All Reciters
```
GET /api/reciters
```

### Get Specific Reciter
```
GET /api/reciters/{reciter_id}
```

### Get Audio URL for Ayah
```
POST /api/audio/ayah
Content-Type: application/json

{
  "reciter_id": "7",
  "surah_number": 1,
  "ayah_number": 1
}
```

### Get Audio URLs for Surah
```
POST /api/audio/surah
Content-Type: application/json

{
  "reciter_id": "7",
  "surah_number": 1,
  "surah_name": "Al-Fatihah"
}
```

### Get Countries
```
GET /api/countries
```

## Integration with Flutter

Update your Flutter app to call these API endpoints instead of using local logic. See the updated `quran_audio_service.dart` in the Flutter project.

## Environment Variables

Create a `.env` file (see `.env.example`):

```env
API_HOST=0.0.0.0
API_PORT=8000
API_RELOAD=true
```

## Project Structure

```
python_backend/
├── main.py           # FastAPI application
├── requirements.txt  # Python dependencies
├── .env              # Environment variables
└── README.md         # This file
```

## Reciters Supported

| ID | Name | Country | Style |
|----|------|---------|-------|
| 7 | Mishari Rashid al-`Afasy | Kuwait 🇰🇼 | Murattal |
| 3 | Abdur-Rahman as-Sudais | Saudi Arabia 🇸🇦 | Murattal |
| ar.dossari | Sheikh Yasser Al-Dosari | Saudi Arabia 🇸🇦 | Murattal |
| 10 | Sa`ud ash-Shuraym | Saudi Arabia 🇸🇦 | Murattal |
| 4 | Abu Bakr al-Shatri | Saudi Arabia 🇸🇦 | Murattal |
| 5 | Hani ar-Rifai | Saudi Arabia 🇸🇦 | Murattal |
| 2 | AbdulBaset AbdulSamad | Egypt 🇪🇬 | Murattal |
| 1 | AbdulBaset AbdulSamad | Egypt 🇪🇬 | Mujawwad |
| 6 | Mahmoud Khalil Al-Husary | Egypt 🇪🇬 | Murattal |
| 12 | Mahmoud Khalil Al-Husary | Egypt 🇪🇬 | Muallim |
| 9 | Mohamed Siddiq al-Minshawi | Egypt 🇪🇬 | Murattal |
| 8 | Mohamed Siddiq al-Minshawi | Egypt 🇪🇬 | Mujawwad |
| 11 | Mohamed al-Tablawi | Egypt 🇪🇬 | Murattal |