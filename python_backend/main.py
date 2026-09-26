"""
Quran Audio API - Python FastAPI Backend
Provides endpoints for reciter information, country mapping, and audio URL resolution.
"""

from contextlib import asynccontextmanager
from typing import Optional

from fastapi import FastAPI, HTTPException, Query
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
import httpx


# =============================================================================
# Data Models
# =============================================================================

class ReciterCountry(BaseModel):
    name: str
    flag: str
    priority: int = 100

    @property
    def display_name(self) -> str:
        return f"{self.flag} {self.name}"


class ReciterInfo(BaseModel):
    id: str
    name: str
    name_arabic: Optional[str] = None
    style: str = "murattal"
    country: str = "Saudi Arabia"


class AyahAudioRequest(BaseModel):
    reciter_id: str
    surah_number: int
    ayah_number: int


class AyahAudioResponse(BaseModel):
    audio_url: str
    reciter_id: str
    reciter_name: str
    surah_number: int
    ayah_number: int


class SurahAudioRequest(BaseModel):
    reciter_id: str
    surah_number: int
    surah_name: str


class SurahAudioResponse(BaseModel):
    audio_urls: list[str]
    reciter_id: str
    reciter_name: str
    surah_number: int
    surah_name: str
    total_ayahs: int


class RecitersResponse(BaseModel):
    reciters: list[ReciterInfo]
    countries: dict[str, ReciterCountry]


class HealthResponse(BaseModel):
    status: str = "ok"
    version: str = "1.0.0"


# =============================================================================
# Reciter Country Mapper (Ported from Dart)
# =============================================================================

class ReciterCountryMapper:
    COUNTRIES = {
        "kuwait": ReciterCountry(name="Kuwait", flag="🇰🇼", priority=1),
        "saudi_arabia": ReciterCountry(name="Saudi Arabia", flag="🇸🇦", priority=2),
        "egypt": ReciterCountry(name="Egypt", flag="🇪🇬", priority=3),
        "yemen": ReciterCountry(name="Yemen", flag="🇾🇪", priority=4),
        "uae": ReciterCountry(name="United Arab Emirates", flag="🇦🇪", priority=5),
        "other": ReciterCountry(name="Other", flag="🌐", priority=99),
    }

    @staticmethod
    def get_country(reciter: ReciterInfo) -> ReciterCountry:
        reciter_id = reciter.id.lower()
        name = reciter.name.lower()

        # 1. Kuwait
        if (reciter_id == "7" or reciter_id == "ar.alafasy" or
                "alafasy" in name or "afasy" in name or
                "mishari" in name or "mishary" in name):
            return ReciterCountryMapper.COUNTRIES["kuwait"]

        # 2. Saudi Arabia
        saudi_ids = {
            "3", "ar.sudais", "4", "ar.shatri", "5", "ar.rifai",
            "10", "ar.shuraim", "ar.maher", "ar.dossari", "ar.dosari",
            "ar.dossary", "ar.hudhaify", "ar.ghamdi", "ar.basfar", "ar.ayyoub"
        }
        saudi_names = [
            "sudais", "shatri", "rifai", "shuraym", "shuraim",
            "muaiqly", "dossari", "dosari", "dussary", "yasser",
            "hudhaify", "ghamdi", "basfar", "ayyoub"
        ]
        if (reciter_id in saudi_ids or any(n in name for n in saudi_names)):
            return ReciterCountryMapper.COUNTRIES["saudi_arabia"]

        # 3. Egypt
        egypt_ids = {
            "1", "2", "ar.abdulbasit", "ar.abdulbasitmujawwad",
            "6", "12", "ar.husary", "ar.husarymujawwad", "ar.husarymuallim",
            "8", "9", "ar.minshawi", "ar.minshawimujawwad", "11", "ar.tablawi"
        }
        egypt_names = [
            "abdulbaset", "abdul basit", "abdus samad",
            "husary", "al-husary", "minshawi", "al-minshawi",
            "tablawi", "banna"
        ]
        if (reciter_id in egypt_ids or any(n in name for n in egypt_names)):
            return ReciterCountryMapper.COUNTRIES["egypt"]

        # 4. Yemen
        if "abbad" in name or "maqtari" in name:
            return ReciterCountryMapper.COUNTRIES["yemen"]

        # 5. UAE
        if "ajmi" in name:
            return ReciterCountryMapper.COUNTRIES["uae"]

        return ReciterCountryMapper.COUNTRIES["saudi_arabia"]

    @staticmethod
    def get_reciter_api_id(reciter_id: str) -> int:
        mapping = {
            "7": 7, "ar.alafasy": 7,
            "1": 1, "ar.abdulbasitmujawwad": 1,
            "2": 2, "ar.abdulbasit": 2,
            "3": 3, "ar.sudais": 3,
            "4": 4, "ar.shatri": 4,
            "5": 5, "ar.rifai": 5,
            "6": 6, "ar.husary": 6,
            "8": 8, "ar.minshawimujawwad": 8,
            "9": 9, "ar.minshawi": 9,
            "10": 10, "ar.shuraim": 10,
            "11": 11, "ar.tablawi": 11,
            "12": 12, "ar.husarymuallim": 12,
            "ar.dossari": 999, "ar.dosari": 999, "ar.dossary": 999,
        }
        reciter_id_lower = reciter_id.lower()
        if reciter_id_lower in mapping:
            return mapping[reciter_id_lower]
        try:
            parsed = int(reciter_id)
            if 1 <= parsed <= 12:
                return parsed
        except ValueError:
            pass
        return 7  # Default to Mishari Alafasy

    @staticmethod
    def get_standard_reciters() -> list[ReciterInfo]:
        return [
            ReciterInfo(id="7", name="Mishari Rashid al-`Afasy", name_arabic="مشاري بن راشد العفاسي", style="murattal", country="Kuwait"),
            ReciterInfo(id="3", name="Abdur-Rahman as-Sudais", name_arabic="عبد الرحمن السديس", style="murattal", country="Saudi Arabia"),
            ReciterInfo(id="ar.dossari", name="Sheikh Yasser Al-Dosari", name_arabic="الشيخ ياسر الدوسري", style="murattal", country="Saudi Arabia"),
            ReciterInfo(id="10", name="Sa`ud ash-Shuraym", name_arabic="سعود الشريم", style="murattal", country="Saudi Arabia"),
            ReciterInfo(id="4", name="Abu Bakr al-Shatri", name_arabic="أبو بكر الشاطري", style="murattal", country="Saudi Arabia"),
            ReciterInfo(id="5", name="Hani ar-Rifai", name_arabic="هاني الرفاعي", style="murattal", country="Saudi Arabia"),
            ReciterInfo(id="2", name="AbdulBaset AbdulSamad (Murattal)", name_arabic="عبد الباسط عبد الصمد (مرتل)", style="murattal", country="Egypt"),
            ReciterInfo(id="1", name="AbdulBaset AbdulSamad (Mujawwad)", name_arabic="عبد الباسط عبد الصمد (مجود)", style="mujawwad", country="Egypt"),
            ReciterInfo(id="6", name="Mahmoud Khalil Al-Husary (Murattal)", name_arabic="محمود خليل الحصري (مرتل)", style="murattal", country="Egypt"),
            ReciterInfo(id="12", name="Mahmoud Khalil Al-Husary (Muallim)", name_arabic="محمود خليل الحصري (معلم)", style="murattal", country="Egypt"),
            ReciterInfo(id="9", name="Mohamed Siddiq al-Minshawi (Murattal)", name_arabic="محمد صديق المنشاوي (مرتل)", style="murattal", country="Egypt"),
            ReciterInfo(id="8", name="Mohamed Siddiq al-Minshawi (Mujawwad)", name_arabic="محمد صديق المنشاوي (مجود)", style="mujawwad", country="Egypt"),
            ReciterInfo(id="11", name="Mohamed al-Tablawi", name_arabic="محمد محمود الطبلاوي", style="murattal", country="Egypt"),
        ]


# =============================================================================
# Audio URL Resolver
# =============================================================================

class AudioURLResolver:
    def __init__(self):
        self.client = httpx.AsyncClient(
            timeout=httpx.Timeout(15.0),
            headers={"User-Agent": "QuranHadithApp/1.0"}
        )

    async def close(self):
        await self.client.aclose()

    async def resolve_ayah_audio_url(
        self,
        reciter_id: str,
        surah_number: int,
        ayah_number: int
    ) -> Optional[str]:
        lower_id = reciter_id.lower()
        s_str = str(surah_number).zfill(3)
        a_str = str(ayah_number).zfill(3)

        # 1. Sheikh Yasser Al-Dosari (direct URL from everyayah.com)
        if (lower_id == "ar.dossari" or lower_id == "ar.dosari" or
                lower_id == "ar.dossary" or "dosari" in lower_id or
                "dossari" in lower_id or "dussary" in lower_id or
                "yasser" in lower_id):
            return f"https://everyayah.com/data/Yasser_Ad-Dussary_128kbps/{s_str}{a_str}.mp3"

        # 2. Try Quran.com API for other reciters
        api_id = ReciterCountryMapper.get_reciter_api_id(reciter_id)
        if api_id != 999:  # Skip if it's the dosari special case
            try:
                response = await self.client.get(
                    f"https://api.quran.com/api/v4/recitations/{api_id}/by_ayah/{surah_number}:{ayah_number}"
                )
                if response.status_code == 200:
                    data = response.json()
                    if data.get("audio_files") and len(data["audio_files"]) > 0:
                        raw_url = data["audio_files"][0].get("url")
                        if raw_url:
                            if raw_url.startswith("http"):
                                return raw_url
                            if raw_url.startswith("//"):
                                return f"https:{raw_url}"
                            return f"https://verses.quran.com/{raw_url}"
            except Exception:
                pass  # Fall through to fallback

        # 3. Direct fallback (Alafasy)
        return f"https://verses.quran.com/Alafasy/mp3/{s_str}{a_str}.mp3"

    async def resolve_surah_audio_urls(
        self,
        reciter_id: str,
        surah_number: int
    ) -> list[str]:
        """Get audio URLs for all ayahs in a surah."""
        # For simplicity, we'll return the first ayah URL as a representative
        # In a real app, you'd get the verse count and return all URLs
        url = await self.resolve_ayah_audio_url(reciter_id, surah_number, 1)
        return [url] if url else []


# =============================================================================
# Global instances
# =============================================================================

audio_resolver: Optional[AudioURLResolver] = None


# =============================================================================
# Application Lifecycle
# =============================================================================

@asynccontextmanager
async def lifespan(app: FastAPI):
    global audio_resolver
    audio_resolver = AudioURLResolver()
    yield
    await audio_resolver.close()


# =============================================================================
# FastAPI App
# =============================================================================

app = FastAPI(
    title="Quran Audio API",
    description="Backend API for Quran audio playback and reciter management",
    version="1.0.0",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# =============================================================================
# Endpoints
# =============================================================================

@app.get("/health", response_model=HealthResponse)
async def health_check():
    """Health check endpoint."""
    return HealthResponse()


@app.get("/api/reciters", response_model=RecitersResponse)
async def get_reciters():
    """Get all available reciters with country information."""
    reciters = ReciterCountryMapper.get_standard_reciters()
    countries = {}
    for reciter in reciters:
        country = ReciterCountryMapper.get_country(reciter)
        countries[reciter.id] = country

    return RecitersResponse(
        reciters=reciters,
        countries={k: v for k, v in countries.items()}
    )


@app.get("/api/reciters/{reciter_id}", response_model=ReciterInfo)
async def get_reciter(reciter_id: str):
    """Get a specific reciter by ID."""
    reciters = ReciterCountryMapper.get_standard_reciters()
    for reciter in reciters:
        if reciter.id == reciter_id:
            return reciter
    raise HTTPException(status_code=404, detail="Reciter not found")


@app.post("/api/audio/ayah", response_model=AyahAudioResponse)
async def get_ayah_audio(request: AyahAudioRequest):
    """Get audio URL for a specific ayah."""
    if audio_resolver is None:
        raise HTTPException(status_code=503, detail="Service not initialized")

    reciters = ReciterCountryMapper.get_standard_reciters()
    reciter = next((r for r in reciters if r.id == request.reciter_id), None)
    reciter_name = reciter.name if reciter else request.reciter_id

    audio_url = await audio_resolver.resolve_ayah_audio_url(
        request.reciter_id,
        request.surah_number,
        request.ayah_number
    )

    if not audio_url:
        raise HTTPException(status_code=404, detail="Audio not available")

    return AyahAudioResponse(
        audio_url=audio_url,
        reciter_id=request.reciter_id,
        reciter_name=reciter_name,
        surah_number=request.surah_number,
        ayah_number=request.ayah_number
    )


@app.post("/api/audio/surah", response_model=SurahAudioResponse)
async def get_surah_audio(request: SurahAudioRequest):
    """Get audio URLs for all ayahs in a surah."""
    if audio_resolver is None:
        raise HTTPException(status_code=503, detail="Service not initialized")

    # Get verse count (simple approximation - in production use quran package)
    verse_counts = {
        1: 7, 2: 286, 3: 200, 4: 176, 5: 120, 6: 165, 7: 206, 8: 75,
        9: 129, 10: 109, 11: 123, 12: 111, 13: 43, 14: 52, 15: 99, 16: 128,
        17: 111, 18: 110, 19: 98, 20: 135, 21: 112, 22: 78, 23: 118, 24: 64,
        25: 77, 26: 227, 27: 93, 28: 88, 29: 69, 30: 60, 31: 34, 32: 30,
        33: 73, 34: 54, 35: 45, 36: 83, 37: 182, 38: 88, 39: 75, 40: 85,
        41: 54, 42: 53, 43: 89, 44: 59, 45: 37, 46: 35, 47: 38, 48: 29,
        49: 18, 50: 45, 51: 60, 52: 49, 53: 62, 54: 55, 55: 78, 56: 96,
        57: 29, 58: 22, 59: 24, 60: 13, 61: 14, 62: 11, 63: 11, 64: 18,
        65: 12, 66: 12, 67: 30, 68: 52, 69: 52, 70: 44, 71: 28, 72: 28,
        73: 20, 74: 56, 75: 40, 76: 31, 77: 50, 78: 40, 79: 46, 80: 42,
        81: 29, 82: 19, 83: 36, 84: 25, 85: 22, 86: 17, 87: 19, 88: 26,
        89: 30, 90: 20, 91: 15, 92: 21, 93: 11, 94: 8, 95: 8, 96: 19,
        97: 5, 98: 8, 99: 8, 100: 11, 101: 11, 102: 8, 103: 3, 104: 9,
        105: 5, 106: 4, 107: 7, 108: 3, 109: 6, 110: 3, 111: 5, 112: 4,
        113: 5, 114: 6
    }

    total_ayahs = verse_counts.get(request.surah_number, 286)

    # For the surah endpoint, we return just the first ayah URL as a placeholder
    # The Flutter app can request individual ayahs as needed
    audio_url = await audio_resolver.resolve_ayah_audio_url(
        request.reciter_id,
        request.surah_number,
        1
    )

    reciters = ReciterCountryMapper.get_standard_reciters()
    reciter = next((r for r in reciters if r.id == request.reciter_id), None)
    reciter_name = reciter.name if reciter else request.reciter_id

    return SurahAudioResponse(
        audio_urls=[audio_url] if audio_url else [],
        reciter_id=request.reciter_id,
        reciter_name=reciter_name,
        surah_number=request.surah_number,
        surah_name=request.surah_name,
        total_ayahs=total_ayahs
    )


@app.get("/api/countries", response_model=dict[str, ReciterCountry])
async def get_countries():
    """Get all available countries."""
    return ReciterCountryMapper.COUNTRIES


# =============================================================================
# Main entry point
# =============================================================================

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)