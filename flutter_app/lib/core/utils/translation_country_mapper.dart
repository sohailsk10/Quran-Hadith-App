/// Translation Country Mapper
/// Maps Quran translations to their compiler/scholar's country of origin with flags.

import '../../shared/models/quran_models.dart';

class TranslationCountry {
  final String name;
  final String flag;
  final int priority; // Lower number = appears earlier

  const TranslationCountry({
    required this.name,
    required this.flag,
    this.priority = 100,
  });

  String get displayName => '$flag $name';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TranslationCountry &&
          runtimeType == other.runtimeType &&
          name == other.name;

  @override
  int get hashCode => name.hashCode;
}

class TranslationCountryMapper {
  static const TranslationCountry pakistan = TranslationCountry(
    name: 'Pakistan',
    flag: '🇵🇰',
    priority: 1,
  );

  static const TranslationCountry saudiArabia = TranslationCountry(
    name: 'Saudi Arabia',
    flag: '🇸🇦',
    priority: 2,
  );

  static const TranslationCountry unitedKingdom = TranslationCountry(
    name: 'United Kingdom',
    flag: '🇬🇧',
    priority: 3,
  );

  static const TranslationCountry india = TranslationCountry(
    name: 'India',
    flag: '🇮🇳',
    priority: 4,
  );

  static const TranslationCountry egypt = TranslationCountry(
    name: 'Egypt',
    flag: '🇪🇬',
    priority: 5,
  );

  static const TranslationCountry turkey = TranslationCountry(
    name: 'Turkey',
    flag: '🇹🇷',
    priority: 6,
  );

  static const TranslationCountry indonesia = TranslationCountry(
    name: 'Indonesia',
    flag: '🇮🇩',
    priority: 7,
  );

  static const TranslationCountry malaysia = TranslationCountry(
    name: 'Malaysia',
    flag: '🇲🇾',
    priority: 8,
  );

  static const TranslationCountry bangladesh = TranslationCountry(
    name: 'Bangladesh',
    flag: '🇧🇩',
    priority: 9,
  );

  static const TranslationCountry russia = TranslationCountry(
    name: 'Russia',
    flag: '🇷🇺',
    priority: 10,
  );

  static const TranslationCountry france = TranslationCountry(
    name: 'France',
    flag: '🇫🇷',
    priority: 11,
  );

  static const TranslationCountry germany = TranslationCountry(
    name: 'Germany',
    flag: '🇩🇪',
    priority: 12,
  );

  static const TranslationCountry spain = TranslationCountry(
    name: 'Spain',
    flag: '🇪🇸',
    priority: 13,
  );

  static const TranslationCountry italy = TranslationCountry(
    name: 'Italy',
    flag: '🇮🇹',
    priority: 14,
  );

  static const TranslationCountry netherlands = TranslationCountry(
    name: 'Netherlands',
    flag: '🇳🇱',
    priority: 15,
  );

  static const TranslationCountry maldives = TranslationCountry(
    name: 'Maldives',
    flag: '🇲🇻',
    priority: 16,
  );

  static const TranslationCountry japan = TranslationCountry(
    name: 'Japan',
    flag: '🇯🇵',
    priority: 17,
  );

  static const TranslationCountry china = TranslationCountry(
    name: 'China',
    flag: '🇨🇳',
    priority: 18,
  );

  static const TranslationCountry bosnia = TranslationCountry(
    name: 'Bosnia & Herzegovina',
    flag: '🇧🇦',
    priority: 19,
  );

  static const TranslationCountry albania = TranslationCountry(
    name: 'Albania',
    flag: '🇦🇱',
    priority: 20,
  );

  static const TranslationCountry iran = TranslationCountry(
    name: 'Iran',
    flag: '🇮🇷',
    priority: 21,
  );

  static const TranslationCountry uzbekistan = TranslationCountry(
    name: 'Uzbekistan',
    flag: '🇺🇿',
    priority: 22,
  );

  static const TranslationCountry tajikistan = TranslationCountry(
    name: 'Tajikistan',
    flag: '🇹🇯',
    priority: 23,
  );

  static const TranslationCountry afghanistan = TranslationCountry(
    name: 'Afghanistan',
    flag: '🇦🇫',
    priority: 24,
  );

  static const TranslationCountry kazakhstan = TranslationCountry(
    name: 'Kazakhstan',
    flag: '🇰🇿',
    priority: 25,
  );

  static const TranslationCountry azerbaijan = TranslationCountry(
    name: 'Azerbaijan',
    flag: '🇦🇿',
    priority: 26,
  );

  static const TranslationCountry nigeria = TranslationCountry(
    name: 'Nigeria',
    flag: '🇳🇬',
    priority: 27,
  );

  static const TranslationCountry tanzania = TranslationCountry(
    name: 'Tanzania',
    flag: '🇹🇿',
    priority: 28,
  );

  static const TranslationCountry somalia = TranslationCountry(
    name: 'Somalia',
    flag: '🇸🇴',
    priority: 29,
  );

  static const TranslationCountry southKorea = TranslationCountry(
    name: 'South Korea',
    flag: '🇰🇷',
    priority: 30,
  );

  static const TranslationCountry vietnam = TranslationCountry(
    name: 'Vietnam',
    flag: '🇻🇳',
    priority: 31,
  );

  static const TranslationCountry nepal = TranslationCountry(
    name: 'Nepal',
    flag: '🇳🇵',
    priority: 32,
  );

  static const TranslationCountry rwanda = TranslationCountry(
    name: 'Rwanda',
    flag: '🇷🇼',
    priority: 33,
  );

  static const TranslationCountry brazil = TranslationCountry(
    name: 'Brazil',
    flag: '🇧🇷',
    priority: 34,
  );

  static const TranslationCountry sweden = TranslationCountry(
    name: 'Sweden',
    flag: '🇸🇪',
    priority: 35,
  );

  static const TranslationCountry norway = TranslationCountry(
    name: 'Norway',
    flag: '🇳🇴',
    priority: 36,
  );

  static const TranslationCountry poland = TranslationCountry(
    name: 'Poland',
    flag: '🇵🇱',
    priority: 37,
  );

  static const TranslationCountry czechRepublic = TranslationCountry(
    name: 'Czech Republic',
    flag: '🇨🇿',
    priority: 38,
  );

  static const TranslationCountry finland = TranslationCountry(
    name: 'Finland',
    flag: '🇫🇮',
    priority: 39,
  );

  static const TranslationCountry ukraine = TranslationCountry(
    name: 'Ukraine',
    flag: '🇺🇦',
    priority: 40,
  );

  static const TranslationCountry bulgaria = TranslationCountry(
    name: 'Bulgaria',
    flag: '🇧🇬',
    priority: 41,
  );

  static const TranslationCountry romania = TranslationCountry(
    name: 'Romania',
    flag: '🇷🇴',
    priority: 42,
  );

  static const TranslationCountry iraq = TranslationCountry(
    name: 'Iraq',
    flag: '🇮🇶',
    priority: 43,
  );

  static const TranslationCountry ethiopia = TranslationCountry(
    name: 'Ethiopia',
    flag: '🇪🇹',
    priority: 44,
  );

  static const TranslationCountry philippines = TranslationCountry(
    name: 'Philippines',
    flag: '🇵🇭',
    priority: 45,
  );

  static const TranslationCountry cambodia = TranslationCountry(
    name: 'Cambodia',
    flag: '🇰🇭',
    priority: 46,
  );

  static const TranslationCountry thailand = TranslationCountry(
    name: 'Thailand',
    flag: '🇹🇭',
    priority: 47,
  );

  static const TranslationCountry uganda = TranslationCountry(
    name: 'Uganda',
    flag: '🇺🇬',
    priority: 48,
  );

  static const TranslationCountry other = TranslationCountry(
    name: 'Other',
    flag: '🌐',
    priority: 99,
  );

  /// Determine the country of a given translation
  static TranslationCountry getCountry(TranslationInfo translation) {
    final id = translation.id.toLowerCase();
    final name = translation.name.toLowerCase();
    final author = translation.author.toLowerCase();
    final lang = translation.language.toLowerCase();
    final langName = translation.languageName.toLowerCase();

    // 1. Pakistan
    if (id == '84' ||
        name.contains('usmani') ||
        author.contains('usmani') ||
        name.contains('taqi') ||
        author.contains('taqi') ||
        id == '95' ||
        id == '97' ||
        id == '831' ||
        name.contains('maududi') ||
        author.contains('maududi') ||
        id == '234' ||
        name.contains('jalandhari') ||
        author.contains('jalandhari') ||
        id == '54' ||
        name.contains('junagarhi') ||
        author.contains('junagarhi') ||
        id == '158' ||
        name.contains('israr') ||
        author.contains('israr') ||
        name.contains('bayan-ul-quran') ||
        id == '151' ||
        name.contains('mahmud al-hasan') ||
        author.contains('mahmud al-hasan') ||
        id == '238' ||
        name.contains('amroti') ||
        author.contains('amroti') ||
        id == 'ur.junagarhi' ||
        id == 'ur.maududi') {
      return pakistan;
    }

    // 2. Saudi Arabia
    if (id == '20' ||
        name.contains('saheeh') ||
        author.contains('saheeh') ||
        id == '203' ||
        name.contains('hilali') ||
        author.contains('hilali') ||
        name.contains('muhsin khan') ||
        author.contains('muhsin khan') ||
        id == '134' ||
        name.contains('king fahad') ||
        author.contains('king fahad') ||
        id == 'en.sahih' ||
        id == 'en.muhsin' ||
        name.contains('dar al-salam') ||
        author.contains('dar al-salam') ||
        name.contains('ruwwad') ||
        author.contains('ruwwad') ||
        name.contains('noor international') ||
        author.contains('noor international')) {
      return saudiArabia;
    }

    // 3. United Kingdom
    if (id == '85' ||
        name.contains('abdel haleem') ||
        author.contains('abdel haleem') ||
        author.contains('haleem') ||
        id == '19' ||
        name.contains('pickthall') ||
        author.contains('pickthall') ||
        id == 'en.pickthall') {
      return unitedKingdom;
    }

    // 4. India
    if (id == '22' ||
        name.contains('yusuf ali') ||
        author.contains('yusuf ali') ||
        id == 'en.yusufali' ||
        id == '819' ||
        name.contains('wahiduddin') ||
        author.contains('wahiduddin') ||
        id == '122' ||
        name.contains('azizul haque') ||
        author.contains('azizul haque') ||
        id == '80' ||
        id == '37' ||
        id == '224' ||
        name.contains('karakunnu') ||
        author.contains('karakunnu') ||
        name.contains('malayalam') ||
        id == '133' ||
        id == '229' ||
        id == '50' ||
        name.contains('baqavi') ||
        author.contains('baqavi') ||
        name.contains('tamil') ||
        id == '226' ||
        name.contains('ansari') ||
        author.contains('ansari') ||
        name.contains('marathi') ||
        id == '225' ||
        name.contains('al-umry') ||
        author.contains('al-umry') ||
        name.contains('gujarati') ||
        id == '227' ||
        name.contains('telugu') ||
        id == '120' ||
        name.contains('habibur-rahman') ||
        name.contains('assamese') ||
        id == '771' ||
        name.contains('kannada') ||
        id == 'ta.tamil' ||
        id == 'ml.malayalam') {
      return india;
    }

    // 5. Egypt
    if (id == '149' ||
        name.contains('fadel soliman') ||
        author.contains('fadel soliman') ||
        name.contains('bridges') ||
        id == '78' ||
        name.contains('awqaf') ||
        author.contains('awqaf') ||
        id == '156' ||
        name.contains('qutb') ||
        author.contains('qutb')) {
      return egypt;
    }

    // 6. Turkey
    if (id == '77' ||
        name.contains('diyanet') ||
        author.contains('diyanet') ||
        id == '52' ||
        name.contains('elmalili') ||
        author.contains('elmalili') ||
        id == '124' ||
        name.contains('muslim shahin') ||
        author.contains('muslim shahin') ||
        id == '112' ||
        name.contains('shaban britch') ||
        author.contains('shaban britch') ||
        id == 'tr.diyanet' ||
        id == 'tr.ozeley' ||
        lang.contains('turkish') ||
        langName.contains('turkish')) {
      return turkey;
    }

    // 7. Indonesia
    if (id == '33' ||
        name.contains('indonesian') ||
        author.contains('indonesian') ||
        id == '141' ||
        name.contains('sabiq') ||
        author.contains('sabiq') ||
        id == 'id.kemenag' ||
        lang.contains('indonesian') ||
        langName.contains('indonesian')) {
      return indonesia;
    }

    // 8. Malaysia
    if (id == '39' ||
        name.contains('basmeih') ||
        author.contains('basmeih') ||
        id == 'ms.basmeih' ||
        lang.contains('malay') ||
        langName.contains('malay')) {
      return malaysia;
    }

    // 9. Bangladesh
    if (id == '161' ||
        id == '162' ||
        id == '163' ||
        id == '213' ||
        name.contains('zakaria') ||
        author.contains('zakaria') ||
        name.contains('bengali') ||
        id == 'bn.bengali' ||
        lang.contains('bengali') ||
        langName.contains('bengali')) {
      return bangladesh;
    }

    // 10. Russia
    if (id == '45' ||
        name.contains('kuliev') ||
        author.contains('kuliev') ||
        id == '79' ||
        name.contains('abu adel') ||
        author.contains('abu adel') ||
        id == '106' ||
        name.contains('magomed') ||
        id == '53' ||
        name.contains('tatar') ||
        id == 'ru.kuliev' ||
        lang.contains('russian') ||
        langName.contains('russian') ||
        lang.contains('tatar') ||
        langName.contains('tatar') ||
        lang.contains('chechen') ||
        langName.contains('chechen')) {
      return russia;
    }

    // 11. France
    if (id == '31' ||
        name.contains('hamidullah') ||
        author.contains('hamidullah') ||
        id == '779' ||
        name.contains('maash') ||
        author.contains('maash') ||
        id == '136' ||
        id == 'fr.hamidullah' ||
        lang.contains('french') ||
        langName.contains('french')) {
      return france;
    }

    // 12. Germany
    if (id == '27' ||
        name.contains('bubenheim') ||
        author.contains('bubenheim') ||
        id == '208' ||
        name.contains('abu reda') ||
        id == 'de.bubenheim' ||
        lang.contains('german') ||
        langName.contains('german')) {
      return germany;
    }

    // 13. Spain
    if (id == '83' ||
        name.contains('garcia') ||
        author.contains('garcia') ||
        id == '140' ||
        id == 'es.garcia' ||
        lang.contains('spanish') ||
        langName.contains('spanish')) {
      return spain;
    }

    // 14. Italy
    if (id == '153' ||
        name.contains('piccardo') ||
        author.contains('piccardo') ||
        id == '209' ||
        name.contains('al-sharif') ||
        id == 'it.piccardo' ||
        lang.contains('italian') ||
        langName.contains('italian')) {
      return italy;
    }

    // 15. Netherlands
    if (id == '144' ||
        name.contains('siregar') ||
        author.contains('siregar') ||
        id == '235' ||
        name.contains('abdalsalaam') ||
        id == 'nl.keyzer' ||
        lang.contains('dutch') ||
        langName.contains('dutch')) {
      return netherlands;
    }

    // 16. Maldives
    if (id == '86' ||
        id == '840' ||
        name.contains('maldives') ||
        name.contains('bakurube') ||
        lang.contains('divehi') ||
        langName.contains('divehi') ||
        langName.contains('maldivian')) {
      return maldives;
    }

    // 17. Japan
    if (id == '35' ||
        name.contains('mita') ||
        author.contains('mita') ||
        id == '218' ||
        name.contains('sato') ||
        author.contains('sato') ||
        lang.contains('japanese') ||
        langName.contains('japanese')) {
      return japan;
    }

    // 18. China
    if (id == '56' ||
        name.contains('ma jian') ||
        author.contains('ma jian') ||
        id == '109' ||
        name.contains('makin') ||
        author.contains('makin') ||
        id == '76' ||
        name.contains('muhammad saleh') ||
        author.contains('muhammad saleh') ||
        id == 'zh.chinese' ||
        lang.contains('chinese') ||
        langName.contains('chinese') ||
        lang.contains('uighur') ||
        langName.contains('uighur') ||
        langName.contains('uyghur')) {
      return china;
    }

    // 19. Bosnia & Herzegovina
    if (id == '126' ||
        name.contains('korkut') ||
        author.contains('korkut') ||
        id == '25' ||
        id == '214' ||
        name.contains('mehanovi') ||
        author.contains('mehanovi') ||
        lang.contains('bosnian') ||
        langName.contains('bosnian')) {
      return bosnia;
    }

    // 20. Albania
    if (id == '88' ||
        id == '89' ||
        id == '47' ||
        name.contains('nahi') ||
        name.contains('ahmeti') ||
        lang.contains('albanian') ||
        langName.contains('albanian')) {
      return albania;
    }

    // 21. Iran
    if (id == '74' ||
        id == '29' ||
        id == '135' ||
        id == 'fa.ayati' ||
        name.contains('ayati') ||
        author.contains('ayati') ||
        name.contains('dari') ||
        lang.contains('persian') ||
        langName.contains('persian')) {
      return iran;
    }

    // 22. Uzbekistan
    if (id == '101' ||
        id == '55' ||
        id == '127' ||
        name.contains('mansour') ||
        author.contains('mansour') ||
        name.contains('sodik') ||
        lang.contains('uzbek') ||
        langName.contains('uzbek')) {
      return uzbekistan;
    }

    // 23. Tajikistan
    if (id == '139' ||
        id == '223' ||
        name.contains('mirof') ||
        author.contains('mirof') ||
        lang.contains('tajik') ||
        langName.contains('tajik')) {
      return tajikistan;
    }

    // 24. Afghanistan
    if (id == '785' ||
        id == '118' ||
        name.contains('badkhashani') ||
        name.contains('abulsalam') ||
        lang.contains('dari') ||
        langName.contains('dari') ||
        lang.contains('pashto') ||
        langName.contains('pashto')) {
      return afghanistan;
    }

    // 25. Kazakhstan
    if (id == '113' ||
        id == '222' ||
        name.contains('altai') ||
        author.contains('altai') ||
        lang.contains('kazakh') ||
        langName.contains('kazakh')) {
      return kazakhstan;
    }

    // 26. Azerbaijan
    if (id == '75' ||
        id == '23' ||
        name.contains('musayev') ||
        author.contains('musayev') ||
        lang.contains('azeri') ||
        langName.contains('azeri') ||
        lang.contains('azerbaijani') ||
        langName.contains('azerbaijani')) {
      return azerbaijan;
    }

    // 27. Nigeria
    if (id == '32' ||
        id == '115' ||
        id == '125' ||
        name.contains('gumi') ||
        author.contains('gumi') ||
        name.contains('jummi') ||
        name.contains('aykyuni') ||
        lang.contains('hausa') ||
        langName.contains('hausa') ||
        lang.contains('yoruba') ||
        langName.contains('yoruba')) {
      return nigeria;
    }

    // 28. Tanzania / East Africa
    if (id == '49' ||
        id == '231' ||
        name.contains('barwani') ||
        author.contains('barwani') ||
        id == 'sw.barwani' ||
        lang.contains('swahili') ||
        langName.contains('swahili')) {
      return tanzania;
    }

    // 29. Somalia
    if (id == '46' ||
        name.contains('abduh') ||
        author.contains('abduh') ||
        lang.contains('somali') ||
        langName.contains('somali')) {
      return somalia;
    }

    // 30. South Korea
    if (id == '219' ||
        id == '36' ||
        name.contains('choi') ||
        author.contains('choi') ||
        lang.contains('korean') ||
        langName.contains('korean')) {
      return southKorea;
    }

    // 31. Vietnam
    if (id == '221' ||
        id == '220' ||
        name.contains('abdul-karim') ||
        author.contains('abdul-karim') ||
        lang.contains('vietnamese') ||
        langName.contains('vietnamese')) {
      return vietnam;
    }

    // 32. Nepal
    if (id == '108' ||
        name.contains('nepal') ||
        lang.contains('nepali') ||
        langName.contains('nepali')) {
      return nepal;
    }

    // 33. Rwanda
    if (id == '774' ||
        name.contains('rwanda') ||
        lang.contains('kinyarwanda') ||
        langName.contains('kinyarwanda')) {
      return rwanda;
    }

    // 34. Brazil / Portugal
    if (id == '43' ||
        id == '103' ||
        name.contains('samir') ||
        name.contains('el-hayek') ||
        name.contains('helmi nasr') ||
        id == 'pt.elhayek' ||
        lang.contains('portuguese') ||
        langName.contains('portuguese')) {
      return brazil;
    }

    // 35. Sweden
    if (id == '48' ||
        name.contains('bernström') ||
        lang.contains('swedish') ||
        langName.contains('swedish')) {
      return sweden;
    }

    // 36. Norway
    if (id == '41' ||
        name.contains('norwegian') ||
        lang.contains('norwegian') ||
        langName.contains('norwegian')) {
      return norway;
    }

    // 37. Poland
    if (id == '42' ||
        name.contains('bielawski') ||
        lang.contains('polish') ||
        langName.contains('polish')) {
      return poland;
    }

    // 38. Czech Republic
    if (id == '26' ||
        name.contains('czech') ||
        lang.contains('czech') ||
        langName.contains('czech')) {
      return czechRepublic;
    }

    // 39. Finland
    if (id == '30' ||
        name.contains('finnish') ||
        lang.contains('finnish') ||
        langName.contains('finnish')) {
      return finland;
    }

    // 40. Ukraine
    if (id == '217' ||
        name.contains('yaqubovic') ||
        lang.contains('ukrainian') ||
        langName.contains('ukrainian')) {
      return ukraine;
    }

    // 41. Bulgaria
    if (id == '237' ||
        name.contains('theophanov') ||
        lang.contains('bulgarian') ||
        langName.contains('bulgarian')) {
      return bulgaria;
    }

    // 42. Romania
    if (id == '44' ||
        id == '782' ||
        name.contains('grigore') ||
        lang.contains('romanian') ||
        langName.contains('romanian')) {
      return romania;
    }

    // 43. Iraq / Kurdistan
    if (id == '81' ||
        id == '143' ||
        name.contains('kurdish') ||
        lang.contains('kurdish') ||
        langName.contains('kurdish')) {
      return iraq;
    }

    // 44. Ethiopia
    if (id == '87' ||
        id == '111' ||
        lang.contains('amharic') ||
        langName.contains('amharic') ||
        lang.contains('oromo') ||
        langName.contains('oromo')) {
      return ethiopia;
    }

    // 45. Philippines
    if (id == '38' ||
        id == '211' ||
        lang.contains('tagalog') ||
        langName.contains('tagalog') ||
        lang.contains('maranao') ||
        langName.contains('maranao')) {
      return philippines;
    }

    // 46. Cambodia
    if (id == '128' ||
        lang.contains('khmer') ||
        langName.contains('khmer')) {
      return cambodia;
    }

    // 47. Thailand
    if (id == '51' ||
        id == '230' ||
        lang.contains('thai') ||
        langName.contains('thai')) {
      return thailand;
    }

    // 48. Uganda
    if (id == '232' ||
        lang.contains('ganda') ||
        langName.contains('ganda')) {
      return uganda;
    }

    // If Urdu language, default to Pakistan
    if (lang.contains('urdu') || langName.contains('urdu')) {
      return pakistan;
    }

    // If English language and unmapped, categorize by general
    if (lang.contains('english') || langName.contains('english')) {
      return unitedKingdom;
    }

    return other;
  }
}

extension TranslationInfoCountryExtension on TranslationInfo {
  TranslationCountry get countryObj =>
      TranslationCountryMapper.getCountry(this);

  String get countryName => countryObj.name;
  String get countryFlag => countryObj.flag;
  String get countryDisplayName => countryObj.displayName;
}
