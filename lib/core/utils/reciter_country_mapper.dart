/// Reciter Country Mapper
/// Maps Quran reciters to their country of origin with flag emojis and recitation styles.

import '../../shared/models/quran_models.dart';

class ReciterCountry {
  final String name;
  final String flag;
  final int priority;

  const ReciterCountry({
    required this.name,
    required this.flag,
    this.priority = 100,
  });

  String get displayName => '$flag $name';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReciterCountry &&
          runtimeType == other.runtimeType &&
          name == other.name;

  @override
  int get hashCode => name.hashCode;
}

class ReciterCountryMapper {
  static const ReciterCountry kuwait = ReciterCountry(
    name: 'Kuwait',
    flag: '🇰🇼',
    priority: 1,
  );

  static const ReciterCountry saudiArabia = ReciterCountry(
    name: 'Saudi Arabia',
    flag: '🇸🇦',
    priority: 2,
  );

  static const ReciterCountry egypt = ReciterCountry(
    name: 'Egypt',
    flag: '🇪🇬',
    priority: 3,
  );

  static const ReciterCountry yemen = ReciterCountry(
    name: 'Yemen',
    flag: '🇾🇪',
    priority: 4,
  );

  static const ReciterCountry uae = ReciterCountry(
    name: 'United Arab Emirates',
    flag: '🇦🇪',
    priority: 5,
  );

  static const ReciterCountry other = ReciterCountry(
    name: 'Other',
    flag: '🌐',
    priority: 99,
  );

  /// Determine the country of a given reciter
  static ReciterCountry getCountry(ReciterInfo reciter) {
    final id = reciter.id.toLowerCase();
    final name = reciter.name.toLowerCase();

    // 1. Kuwait
    if (id == '7' ||
        id == 'ar.alafasy' ||
        name.contains('alafasy') ||
        name.contains('afasy') ||
        name.contains('mishari') ||
        name.contains('mishary')) {
      return kuwait;
    }

    // 2. Saudi Arabia
    if (id == '3' ||
        id == 'ar.sudais' ||
        name.contains('sudais') ||
        id == '4' ||
        name.contains('shatri') ||
        id == '5' ||
        name.contains('rifai') ||
        id == '10' ||
        id == 'ar.shuraim' ||
        name.contains('shuraym') ||
        name.contains('shuraim') ||
        id == 'ar.maher' ||
        name.contains('muaiqly') ||
        id == 'ar.dossari' ||
        id == 'ar.dosari' ||
        id == 'ar.dossary' ||
        name.contains('dossari') ||
        name.contains('dosari') ||
        name.contains('dussary') ||
        name.contains('yasser') ||
        id == 'ar.hudhaify' ||
        name.contains('hudhaify') ||
        id == 'ar.ghamdi' ||
        name.contains('ghamdi') ||
        id == 'ar.basfar' ||
        name.contains('basfar') ||
        id == 'ar.ayyoub' ||
        name.contains('ayyoub')) {
      return saudiArabia;
    }

    // 3. Egypt
    if (id == '1' ||
        id == '2' ||
        id == 'ar.abdulbasit' ||
        id == 'ar.abdulbasitmujawwad' ||
        name.contains('abdulbaset') ||
        name.contains('abdul basit') ||
        name.contains('abdus samad') ||
        id == '6' ||
        id == '12' ||
        id == 'ar.husary' ||
        id == 'ar.husarymujawwad' ||
        id == 'ar.husarymuallim' ||
        name.contains('husary') ||
        name.contains('al-husary') ||
        id == '8' ||
        id == '9' ||
        id == 'ar.minshawi' ||
        id == 'ar.minshawimujawwad' ||
        name.contains('minshawi') ||
        name.contains('al-minshawi') ||
        id == '11' ||
        name.contains('tablawi') ||
        name.contains('banna')) {
      return egypt;
    }

    // 4. Yemen
    if (name.contains('abbad') || name.contains('maqtari')) {
      return yemen;
    }

    // 5. UAE
    if (name.contains('ajmi')) {
      return uae;
    }

    return saudiArabia; // Default fallback
  }

  /// Maps string IDs or API IDs to the Quran.com numeric recitation ID (1-12)
  static int getReciterApiId(String reciterId) {
    switch (reciterId.toLowerCase()) {
      case '7':
      case 'ar.alafasy':
        return 7;
      case '1':
      case 'ar.abdulbasitmujawwad':
        return 1;
      case '2':
      case 'ar.abdulbasit':
        return 2;
      case '3':
      case 'ar.sudais':
        return 3;
      case '4':
      case 'ar.shatri':
        return 4;
      case '5':
      case 'ar.rifai':
        return 5;
      case '6':
      case 'ar.husary':
        return 6;
      case '8':
      case 'ar.minshawimujawwad':
        return 8;
      case '9':
      case 'ar.minshawi':
        return 9;
      case '10':
      case 'ar.shuraim':
        return 10;
      case '11':
      case 'ar.tablawi':
        return 11;
      case '12':
      case 'ar.husarymuallim':
        return 12;
      case 'ar.dossari':
      case 'ar.dosari':
      case 'ar.dossary':
        return 999;
      default:
        final parsed = int.tryParse(reciterId);
        if (parsed != null && parsed >= 1 && parsed <= 12) return parsed;
        return 7; // Default to Mishari Alafasy
    }
  }

  /// Standard fallback reciter list for offline or instant render
  static List<ReciterInfo> getStandardReciters() {
    return [
      const ReciterInfo(
        id: '7',
        name: 'Mishari Rashid al-`Afasy',
        nameArabic: 'مشاري بن راشد العفاسي',
        style: RecitationStyle.murattal,
        country: 'Kuwait',
      ),
      const ReciterInfo(
        id: '3',
        name: 'Abdur-Rahman as-Sudais',
        nameArabic: 'عبد الرحمن السديس',
        style: RecitationStyle.murattal,
        country: 'Saudi Arabia',
      ),
      const ReciterInfo(
        id: 'ar.dossari',
        name: 'Sheikh Yasser Al-Dosari',
        nameArabic: 'الشيخ ياسر الدوسري',
        style: RecitationStyle.murattal,
        country: 'Saudi Arabia',
      ),
      const ReciterInfo(
        id: '10',
        name: 'Sa`ud ash-Shuraym',
        nameArabic: 'سعود الشريم',
        style: RecitationStyle.murattal,
        country: 'Saudi Arabia',
      ),
      const ReciterInfo(
        id: '4',
        name: 'Abu Bakr al-Shatri',
        nameArabic: 'أبو بكر الشاطري',
        style: RecitationStyle.murattal,
        country: 'Saudi Arabia',
      ),
      const ReciterInfo(
        id: '5',
        name: 'Hani ar-Rifai',
        nameArabic: 'هاني الرفاعي',
        style: RecitationStyle.murattal,
        country: 'Saudi Arabia',
      ),
      const ReciterInfo(
        id: '2',
        name: 'AbdulBaset AbdulSamad (Murattal)',
        nameArabic: 'عبد الباسط عبد الصمد (مرتل)',
        style: RecitationStyle.murattal,
        country: 'Egypt',
      ),
      const ReciterInfo(
        id: '1',
        name: 'AbdulBaset AbdulSamad (Mujawwad)',
        nameArabic: 'عبد الباسط عبد الصمد (مجود)',
        style: RecitationStyle.mujawwad,
        country: 'Egypt',
      ),
      const ReciterInfo(
        id: '6',
        name: 'Mahmoud Khalil Al-Husary (Murattal)',
        nameArabic: 'محمود خليل الحصري (مرتل)',
        style: RecitationStyle.murattal,
        country: 'Egypt',
      ),
      const ReciterInfo(
        id: '12',
        name: 'Mahmoud Khalil Al-Husary (Muallim)',
        nameArabic: 'محمود خليل الحصري (معلم)',
        style: RecitationStyle.murattal,
        country: 'Egypt',
      ),
      const ReciterInfo(
        id: '9',
        name: 'Mohamed Siddiq al-Minshawi (Murattal)',
        nameArabic: 'محمد صديق المنشاوي (مرتل)',
        style: RecitationStyle.murattal,
        country: 'Egypt',
      ),
      const ReciterInfo(
        id: '8',
        name: 'Mohamed Siddiq al-Minshawi (Mujawwad)',
        nameArabic: 'محمد صديق المنشاوي (مجود)',
        style: RecitationStyle.mujawwad,
        country: 'Egypt',
      ),
      const ReciterInfo(
        id: '11',
        name: 'Mohamed al-Tablawi',
        nameArabic: 'محمد محمود الطبلاوي',
        style: RecitationStyle.murattal,
        country: 'Egypt',
      ),
    ];
  }
}

extension ReciterInfoCountryExtension on ReciterInfo {
  ReciterCountry get countryObj => ReciterCountryMapper.getCountry(this);
  String get countryName => countryObj.name;
  String get countryFlag => countryObj.flag;
  String get countryDisplayName => countryObj.displayName;
  int get apiId => ReciterCountryMapper.getReciterApiId(id);
}
