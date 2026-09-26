import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_hadith_app/data/datasources/remote/quran_remote_datasource.dart';
import 'package:dio/dio.dart';

void main() {
  test('QuranRemoteDataSource search parses Quran.com v4 search results', () async {
    final dio = Dio();
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (options.path == '/search') {
          return handler.resolve(Response(
            requestOptions: options,
            statusCode: 200,
            data: {
              'search': {
                'query': 'bow',
                'total_results': 1,
                'current_page': 1,
                'total_pages': 1,
                'results': [
                  {
                    'verse_key': '17:61',
                    'verse_id': 2090,
                    'text': 'وَإِذْ قُلْنَا لِلْمَلَائِكَةِ اسْجُدُوا لِآدَمَ فَسَجَدُوا إِلَّا إِبْلِيسَ قَالَ أَأَسْجُدُ لِمَنْ خَلَقْتَ طِينًا',
                    'highlight': null,
                    'words': [],
                    'translations': [
                      {
                        'text': 'And when We said to the angels, <em>Bow</em> to Adam...',
                        'resource_id': 20,
                        'name': 'Saheeh International',
                        'language_name': 'english'
                      }
                    ]
                  }
                ]
              }
            },
          ));
        }
        return handler.next(options);
      },
    ));

    final ds = QuranRemoteDataSource(dio: dio);
    final results = await ds.search(query: 'bow');

    expect(results.length, equals(1));
    expect(results.first.ayah.surahNumber, equals(17));
    expect(results.first.ayah.ayahInSurah, equals(61));
    expect(results.first.matchedText, equals('And when We said to the angels, Bow to Adam...'));
    expect(results.first.surah.nameTransliteration, isNotEmpty);
    expect(results.first.ayah.textUthmani, isNotEmpty);
  });

  test('QuranRemoteDataSource search handles empty/null search results safely', () async {
    final dio = Dio();
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        return handler.resolve(Response(
          requestOptions: options,
          statusCode: 200,
          data: {
            'search': {
              'query': 'nonexistenttermxyz',
              'total_results': 0,
              'results': []
            }
          },
        ));
      },
    ));

    final ds = QuranRemoteDataSource(dio: dio);
    final results = await ds.search(query: 'nonexistenttermxyz');
    expect(results, isEmpty);
  });
}
