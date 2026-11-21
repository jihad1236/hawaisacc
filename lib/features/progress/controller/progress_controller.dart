import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:hawiisaac/core/services/app_loading_service.dart';
import 'package:hawiisaac/features/authentication/services/auth_exception.dart';
import 'package:hawiisaac/features/progress/model/progress_analytics_models.dart';
import 'package:hawiisaac/features/progress/model/progress_summary_model.dart';
import 'package:hawiisaac/features/progress/services/progress_api_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ChartPoint {
  final double x;
  final double y;
  ChartPoint(this.x, this.y);
}

class ProgressController extends GetxController {
  ProgressController({ProgressApiService? apiService})
    : _progressApiService = apiService ?? ProgressApiService();

  final ProgressApiService _progressApiService;

  // ── Date Range ─────────────────────────────────────────────────
  final RxString dateRange = ''.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // ── Time Filter Tabs (Section 4.1 Specification) ───────────────
  // Maps to API periods: 'today', '1w', '1m', '3m'
  final List<String> filterTabs = ['Today', '1W', '1M', '3M'];
  static const List<String> apiPeriods = ['today', '1w', '1m', '3m'];
  final RxInt selectedFilterIndex = 1.obs; // Default to '1W' (7 days)

  void onFilterSelected(int index) {
    if (selectedFilterIndex.value == index) return;
    selectedFilterIndex.value = index;
    debugPrint(
      'Progress filter selected: tab=${filterTabs[index]}, period=${apiPeriods[index]}',
    );
    fetchProgress();
  }

  // ── v2.1 Summary Data Model ────────────────────────────────────
  final Rxn<ProgressSummaryResponse> progressSummary =
      Rxn<ProgressSummaryResponse>();
  final RxList<String> muscleGroupsTrained = <String>[].obs;
  final RxList<DailyBreakdownItem> dailyBreakdown = <DailyBreakdownItem>[].obs;
  final RxList<ProgressSessionItem> summarySessions =
      <ProgressSessionItem>[].obs;

  // ── Volume Card ────────────────────────────────────────────────
  final RxString totalVolume = '0'.obs;
  final RxString volumeUnit = 'kg'.obs;
  final RxString volumeSubtitle = 'Total Volume Lifted'.obs;
  final RxString volumeTrendDirection = 'stable'.obs;
  final RxString volumeDeltaDisplay = ''.obs;

  // ── Chart Data ─────────────────────────────────────────────────
  final RxList<ChartPoint> chartPoints = <ChartPoint>[].obs;
  final RxString chartStartLabel = ''.obs;
  final RxString chartEndLabel = ''.obs;

  // ── 2x2 Stat Cards (Workout, Avg Duration, Total Sets, Best Streak) ──
  final RxList<Map<String, String>> statCards = <Map<String, String>>[
    {
      'label': 'Workout',
      'value': '0',
      'change': 'Total sessions',
      'trendDirection': 'stable',
    },
    {
      'label': 'Duration',
      'value': '0m',
      'change': 'Total time',
      'trendDirection': 'stable',
    },
    {
      'label': 'Total Sets',
      'value': '0',
      'change': 'Completed sets',
      'trendDirection': 'stable',
    },
    {
      'label': 'Best Streak',
      'value': '0d',
      'change': 'Current streak',
      'trendDirection': 'stable',
    },
  ].obs;

  // ── Personal Records (Your Best) ───────────────────────────────
  final RxList<PersonalRecordItem> personalRecords = <PersonalRecordItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchProgress();
  }

  Future<void> fetchProgress() async {
    isLoading.value = true;
    errorMessage.value = '';

    final period = apiPeriods[selectedFilterIndex.value];
    debugPrint('fetchProgress: period=$period');

    try {
      // 1. Fetch v2.1 Progress Summary
      final summary = await _progressApiService.getProgressSummary(
        period: period,
      );
      _applySummaryData(summary);

      // 2. Try fetching analytics for charts / PRs
      try {
        final analytics = await _progressApiService.getProgress(period: period);
        _applyAnalyticsData(analytics);
      } catch (e) {
        debugPrint('Analytics extra fetch error: $e');
      }
    } on AuthException catch (error) {
      errorMessage.value = error.message;
      _showError(error.message);
    } catch (e) {
      debugPrint('Progress fetch error: $e');
      errorMessage.value = 'Failed to load progress. Please try again.';
      _showError(errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshProgress() async {
    final period = apiPeriods[selectedFilterIndex.value];
    try {
      final summary = await _progressApiService.getProgressSummary(
        period: period,
      );
      _applySummaryData(summary);

      final analytics = await _progressApiService.getProgress(period: period);
      _applyAnalyticsData(analytics);
    } catch (e) {
      debugPrint('Progress refresh error: $e');
    }
  }

  void _applySummaryData(ProgressSummaryResponse summary) {
    progressSummary.value = summary;
    dateRange.value = summary.dateRange.display;
    muscleGroupsTrained.assignAll(summary.summary.muscleGroupsTrained);
    dailyBreakdown.assignAll(summary.dailyBreakdown);
    summarySessions.assignAll(summary.sessions);

    // Total Volume
    final rawVol = summary.summary.totalVolumeDisplay.replaceAll(
      RegExp(r'\s*kg\s*$', caseSensitive: false),
      '',
    );
    totalVolume.value = rawVol.isNotEmpty
        ? rawVol
        : summary.summary.totalVolumeKg.toStringAsFixed(0);
    volumeUnit.value = 'kg';

    // 2x2 Stats Grid: Workouts, Duration, Sets, Streak
    final s = summary.summary;
    statCards.assignAll([
      {
        'label': 'Workout',
        'value': '${s.workoutsCount}',
        'change': s.workoutsCount == 1
            ? '1 session'
            : '${s.workoutsCount} sessions',
        'trendDirection': s.workoutsCount > 0 ? 'up' : 'stable',
      },
      {
        'label': 'Duration',
        'value': '${s.totalDurationMinutes}m',
        'change': 'Total time',
        'trendDirection': 'stable',
      },
      {
        'label': 'Total Sets',
        'value': '${s.totalSets}',
        'change': '${s.exerciseCount} exercises',
        'trendDirection': 'stable',
      },
      {
        'label': 'Best Streak',
        'value': '${summary.bestStreakDays}d',
        'change': 'Consecutive days',
        'trendDirection': summary.bestStreakDays > 0 ? 'up' : 'stable',
      },
    ]);

    // Build chart from daily breakdown if available
    if (summary.dailyBreakdown.isNotEmpty) {
      final breakdown = summary.dailyBreakdown;
      final maxVol = breakdown
          .map((d) => d.volumeKg)
          .fold<double>(0.0, (max, v) => v > max ? v : max);

      final denom = breakdown.length > 1 ? breakdown.length - 1 : 1;
      chartPoints.assignAll(
        breakdown.asMap().entries.map((entry) {
          final x = entry.key / denom;
          final y = maxVol == 0 ? 0.0 : entry.value.volumeKg / maxVol;
          return ChartPoint(x, y);
        }),
      );

      chartStartLabel.value = breakdown.first.dayName.isNotEmpty
          ? breakdown.first.dayName.substring(0, 3)
          : '';
      chartEndLabel.value = breakdown.last.dayName.isNotEmpty
          ? breakdown.last.dayName.substring(0, 3)
          : '';
    }
  }

  void _applyAnalyticsData(ProgressAnalyticsResponse response) {
    if (response.personalRecords.isNotEmpty) {
      personalRecords.assignAll(response.personalRecords);
    }
    if (response.volumeChart.isNotEmpty && chartPoints.isEmpty) {
      final chart = response.volumeChart;
      final maxVolume = chart
          .map((p) => p.volume)
          .fold<double>(0.0, (max, v) => v > max ? v : max);
      final denominator = chart.length > 1 ? chart.length - 1 : 1;

      chartPoints.assignAll(
        chart.asMap().entries.map((entry) {
          final x = entry.key / denominator;
          final y = maxVolume == 0 ? 0.0 : entry.value.volume / maxVolume;
          return ChartPoint(x, y);
        }),
      );

      chartStartLabel.value = chart.first.label;
      chartEndLabel.value = chart.last.label;
    }
    if (response.volumeDeltaDisplay.isNotEmpty) {
      volumeDeltaDisplay.value = response.volumeDeltaDisplay;
      volumeTrendDirection.value = response.volumeTrendDirection;
    }
  }

  // ── Share ──────────────────────────────────────────────────────

  Future<void> onShare() async {
    final context = Get.overlayContext;
    if (context == null) return;

    try {
      final key = GlobalKey();
      late OverlayEntry entry;

      entry = OverlayEntry(
        builder: (_) => Positioned(
          top: -9999,
          left: 0,
          width: 380,
          child: RepaintBoundary(
            key: key,
            child: ColoredBox(
              color: const Color(0xFF121417),
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: _buildShareWidget(),
              ),
            ),
          ),
        ),
      );

      Overlay.of(context).insert(entry);

      await WidgetsBinding.instance.endOfFrame;
      await WidgetsBinding.instance.endOfFrame;

      final boundary =
          key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        entry.remove();
        return;
      }

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      entry.remove();

      if (byteData == null) return;

      final bytes = byteData.buffer.asUint8List();
      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/progress_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(bytes);

      await Share.shareXFiles([XFile(file.path, mimeType: 'image/png')]);
    } catch (e) {
      debugPrint('Share failed: $e');
      AppLoadingService.showError('Share Failed', 'Could not generate image.');
    }
  }

  Widget _buildShareWidget() {
    const primary = Color(0xFF00E5FF);
    const textPrimary = Color(0xFFF8FBFF);
    const textSecondary = Color(0xFFD7E0EC);

    final filter = filterTabs[selectedFilterIndex.value];
    final range = dateRange.value;
    final stats = statCards.toList();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 340),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    color: primary,
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [
                      BoxShadow(
                        color: primary.withValues(alpha: 0.28),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'MY PROGRESS',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: textPrimary,
                    letterSpacing: 1.0,
                    shadows: _shareTextShadow,
                  ),
                ),
              ],
            ),
            if (range.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                '$filter  ·  $range',
                style: TextStyle(
                  fontSize: 12,
                  color: textSecondary,
                  shadows: _shareTextShadow,
                ),
              ),
            ],
            const SizedBox(height: 18),
            Text(
              volumeSubtitle.value,
              style: TextStyle(
                fontSize: 12,
                color: textSecondary,
                shadows: _shareTextShadow,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  totalVolume.value,
                  style: TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.w800,
                    color: textPrimary,
                    height: 1,
                    shadows: _shareStrongTextShadow,
                  ),
                ),
                const SizedBox(width: 6),
                Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Text(
                    volumeUnit.value,
                    style: TextStyle(
                      fontSize: 16,
                      color: textSecondary,
                      shadows: _shareTextShadow,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (stats.length >= 4) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _shareStatCard(
                      stats[0],
                      textPrimary,
                      textSecondary,
                      primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _shareStatCard(
                      stats[1],
                      textPrimary,
                      textSecondary,
                      primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _shareStatCard(
                      stats[2],
                      textPrimary,
                      textSecondary,
                      primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _shareStatCard(
                      stats[3],
                      textPrimary,
                      textSecondary,
                      primary,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 18),
            const Center(
              child: Image(
                image: AssetImage('assets/icons/app_icon.png'),
                width: 44,
                height: 44,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _shareStatCard(
    Map<String, String> data,
    Color textDark,
    Color textGrey,
    Color primary,
  ) {
    final trend = data['trendDirection'] ?? 'stable';
    final changeColor = trend == 'up'
        ? primary
        : trend == 'down'
        ? Colors.red
        : textGrey;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          data['label']!,
          style: TextStyle(
            fontSize: 11,
            color: textGrey,
            shadows: _shareTextShadow,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          data['value']!,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: textDark,
            shadows: _shareStrongTextShadow,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          data['change']!,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: changeColor,
            shadows: _shareTextShadow,
          ),
        ),
      ],
    );
  }

  List<Shadow> get _shareTextShadow => const [
    Shadow(color: Color(0xA6000000), blurRadius: 8, offset: Offset(0, 2)),
  ];

  List<Shadow> get _shareStrongTextShadow => const [
    Shadow(color: Color(0xBF000000), blurRadius: 10, offset: Offset(0, 3)),
  ];

  void _showError(String message) {
    AppLoadingService.showError('Progress Failed', message);
  }
}
