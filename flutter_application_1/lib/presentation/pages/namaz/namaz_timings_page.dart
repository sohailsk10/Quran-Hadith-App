import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../widgets/common/app_scaffold.dart';

class NamazTimingsPage extends StatefulWidget {
  const NamazTimingsPage({super.key});

  @override
  State<NamazTimingsPage> createState() => _NamazTimingsPageState();
}

class _NamazTimingsPageState extends State<NamazTimingsPage> {
  String _selectedCity = 'Karachi';
  String _selectedCountry = 'Pakistan';
  bool _isLoading = true;
  Timer? _clockTimer;
  DateTime _now = DateTime.now();

  Map<String, String> _prayerTimes = {
    'Fajr': '05:00',
    'Sunrise': '06:18',
    'Dhuhr': '12:28',
    'Asr': '15:52',
    'Maghrib': '18:32',
    'Isha': '19:48',
  };

  String _hijriDate = '';

  final List<Map<String, String>> _popularCities = [
    {'city': 'Karachi', 'country': 'Pakistan'},
    {'city': 'Lahore', 'country': 'Pakistan'},
    {'city': 'Islamabad', 'country': 'Pakistan'},
    {'city': 'Makkah', 'country': 'Saudi Arabia'},
    {'city': 'Madinah', 'country': 'Saudi Arabia'},
    {'city': 'Dubai', 'country': 'United Arab Emirates'},
    {'city': 'Cairo', 'country': 'Egypt'},
    {'city': 'Istanbul', 'country': 'Turkey'},
    {'city': 'London', 'country': 'United Kingdom'},
    {'city': 'New York', 'country': 'United States'},
    {'city': 'Toronto', 'country': 'Canada'},
    {'city': 'Kuala Lumpur', 'country': 'Malaysia'},
    {'city': 'Jakarta', 'country': 'Indonesia'},
    {'city': 'Dhaka', 'country': 'Bangladesh'},
    {'city': 'Delhi', 'country': 'India'},
    {'city': 'Mumbai', 'country': 'India'},
  ];

  @override
  void initState() {
    super.initState();
    _fetchPrayerTimes();
    _clockTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) {
        setState(() {
          _now = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchPrayerTimes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final dio = Dio();
      final response = await dio.get(
        'https://api.aladhan.com/v1/timingsByCity',
        queryParameters: {
          'city': _selectedCity,
          'country': _selectedCountry,
          'method': 1, // University of Islamic Sciences, Karachi or standard
        },
      );

      if (response.statusCode == 200 && response.data['data'] != null) {
        final data = response.data['data'];
        final timings = data['timings'] as Map<String, dynamic>;
        final hijri = data['date']?['hijri'];

        String hijriStr = '';
        if (hijri != null) {
          final day = hijri['day'] ?? '';
          final month = hijri['month']?['en'] ?? '';
          final year = hijri['year'] ?? '';
          hijriStr = '$day $month $year AH';
        }

        setState(() {
          _prayerTimes = {
            'Fajr': _formatTime(timings['Fajr']),
            'Sunrise': _formatTime(timings['Sunrise']),
            'Dhuhr': _formatTime(timings['Dhuhr']),
            'Asr': _formatTime(timings['Asr']),
            'Maghrib': _formatTime(timings['Maghrib']),
            'Isha': _formatTime(timings['Isha']),
          };
          _hijriDate = hijriStr;
          _isLoading = false;
        });
        return;
      }
    } catch (e) {
      // Fallback with graceful message
      debugPrint('Failed to load prayer times: $e');
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatTime(dynamic rawTime) {
    if (rawTime == null) return '--:--';
    final str = rawTime.toString().split(' ')[0]; // remove timezone if any
    return str;
  }

  String _getNextPrayer() {
    final nowTime = DateFormat('HH:mm').format(_now);
    for (final entry in _prayerTimes.entries) {
      if (entry.key == 'Sunrise') continue;
      if (entry.value.compareTo(nowTime) > 0) {
        return entry.key;
      }
    }
    return 'Fajr'; // Next day Fajr
  }

  String _getTimeRemaining() {
    final nextPrayer = _getNextPrayer();
    final timeStr = _prayerTimes[nextPrayer] ?? '05:00';
    try {
      final parts = timeStr.split(':');
      final prayerHour = int.parse(parts[0]);
      final prayerMinute = int.parse(parts[1]);

      var prayerDateTime = DateTime(
          _now.year, _now.month, _now.day, prayerHour, prayerMinute);
      if (prayerDateTime.isBefore(_now)) {
        prayerDateTime = prayerDateTime.add(const Duration(days: 1));
      }

      final diff = prayerDateTime.difference(_now);
      final hours = diff.inHours;
      final minutes = diff.inMinutes % 60;
      if (hours > 0) {
        return 'in ${hours}h ${minutes}m';
      }
      return 'in ${minutes}m';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final nextPrayer = _getNextPrayer();
    final remainingTime = _getTimeRemaining();

    return AppScaffold(
      title: 'Namaz Timings',
      showBackButton: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.location_on_outlined),
          tooltip: 'Select City',
          onPressed: _showCityPicker,
        ),
        IconButton(
          icon: const Icon(Icons.refresh_rounded),
          tooltip: 'Refresh',
          onPressed: _fetchPrayerTimes,
        ),
      ],
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchPrayerTimes,
              child: ListView(
                padding: const EdgeInsets.all(AppConstants.spacingMD),
                children: [
                  // Location and Date Card
                  Container(
                    padding: const EdgeInsets.all(AppConstants.spacingLG),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.primary.withValues(alpha: 0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusLG),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: _showCityPicker,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    size: 18,
                                    color: theme.colorScheme.onPrimary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$_selectedCity, $_selectedCountry',
                                    style:
                                        theme.textTheme.titleMedium?.copyWith(
                                      color: theme.colorScheme.onPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.arrow_drop_down,
                                    color: theme.colorScheme.onPrimary,
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              DateFormat('hh:mm a').format(_now),
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppConstants.spacingMD),
                        Text(
                          'Next Prayer',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color:
                                theme.colorScheme.onPrimary.withValues(alpha: 0.8),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$nextPrayer $remainingTime',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppConstants.spacingSM),
                        Text(
                          _hijriDate.isNotEmpty
                              ? '$_hijriDate • ${DateFormat('EEEE, d MMM yyyy').format(_now)}'
                              : DateFormat('EEEE, d MMM yyyy').format(_now),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color:
                                theme.colorScheme.onPrimary.withValues(alpha: 0.85),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppConstants.spacingLG),

                  // Prayer list
                  ..._prayerTimes.entries.map((entry) {
                    final prayerName = entry.key;
                    final time = entry.value;
                    final isNext = prayerName == nextPrayer;

                    return _PrayerTimeTile(
                      name: prayerName,
                      arabicName: _getArabicName(prayerName),
                      time: time,
                      icon: _getPrayerIcon(prayerName),
                      isNext: isNext,
                    );
                  }),
                ],
              ),
            ),
    );
  }

  String _getArabicName(String name) {
    switch (name) {
      case 'Fajr':
        return 'الفجر';
      case 'Sunrise':
        return 'الشروق';
      case 'Dhuhr':
        return 'الظهر';
      case 'Asr':
        return 'العصر';
      case 'Maghrib':
        return 'المغرب';
      case 'Isha':
        return 'العشاء';
      default:
        return '';
    }
  }

  IconData _getPrayerIcon(String name) {
    switch (name) {
      case 'Fajr':
        return Icons.wb_twilight_rounded;
      case 'Sunrise':
        return Icons.wb_sunny_outlined;
      case 'Dhuhr':
        return Icons.wb_sunny_rounded;
      case 'Asr':
        return Icons.cloud_outlined;
      case 'Maghrib':
        return Icons.nightlight_round;
      case 'Isha':
        return Icons.bedtime_rounded;
      default:
        return Icons.access_time_rounded;
    }
  }

  void _showCityPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(AppConstants.spacingMD),
                child: Text(
                  'Select City',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  itemCount: _popularCities.length,
                  itemBuilder: (context, index) {
                    final item = _popularCities[index];
                    final isSelected = item['city'] == _selectedCity;
                    return ListTile(
                      leading: Icon(
                        Icons.location_city_rounded,
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                      title: Text(item['city']!),
                      subtitle: Text(item['country']!),
                      trailing: isSelected
                          ? Icon(
                              Icons.check_circle,
                              color: Theme.of(context).colorScheme.primary,
                            )
                          : null,
                      onTap: () {
                        setState(() {
                          _selectedCity = item['city']!;
                          _selectedCountry = item['country']!;
                        });
                        Navigator.pop(context);
                        _fetchPrayerTimes();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PrayerTimeTile extends StatelessWidget {
  final String name;
  final String arabicName;
  final String time;
  final IconData icon;
  final bool isNext;

  const _PrayerTimeTile({
    required this.name,
    required this.arabicName,
    required this.time,
    required this.icon,
    required this.isNext,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingMD),
      decoration: BoxDecoration(
        color: isNext
            ? theme.colorScheme.primaryContainer
            : theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppConstants.radiusMD),
        border: Border.all(
          color: isNext
              ? theme.colorScheme.primary
              : theme.colorScheme.outlineVariant,
          width: isNext ? 1.5 : 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingMD,
          vertical: AppConstants.spacingXS,
        ),
        leading: Container(
          padding: const EdgeInsets.all(AppConstants.spacingSM),
          decoration: BoxDecoration(
            color: isNext
                ? theme.colorScheme.primary
                : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppConstants.radiusSM),
          ),
          child: Icon(
            icon,
            color: isNext
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurfaceVariant,
            size: 24,
          ),
        ),
        title: Row(
          children: [
            Text(
              name,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: isNext ? FontWeight.bold : FontWeight.w600,
                color: isNext
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: AppConstants.spacingSM),
            Text(
              arabicName,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isNext
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (isNext) ...[
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                ),
                child: Text(
                  'Next',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        trailing: Text(
          time,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: isNext
                ? theme.colorScheme.onPrimaryContainer
                : theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
