import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/material.dart' show Color;

/// Consolidated result of an event read: chronologically sorted events plus
/// the color map indexed by `calendarId`.
class CalendarFetchResult {
  const CalendarFetchResult({
    required this.events,
    required this.calendarColors,
  });

  final List<Event> events;
  final Map<String, Color> calendarColors;

  bool get isEmpty => events.isEmpty;
}

/// Domain failures surfaced by the service for the UI to translate into copy.
enum CalendarFailure { permissionDenied, readError, unknown }

class CalendarException implements Exception {
  const CalendarException(this.failure, [this.message]);
  final CalendarFailure failure;
  final String? message;

  @override
  String toString() => 'CalendarException($failure): ${message ?? ''}';
}

/// Abstraction layer over `device_calendar`. Keeps the UI decoupled from the
/// native API and centralizes permission checks plus event reads.
class CalendarService {
  CalendarService({DeviceCalendarPlugin? plugin})
      : _plugin = plugin ?? DeviceCalendarPlugin();

  final DeviceCalendarPlugin _plugin;

  /// Checks, without prompting, whether the app already has calendar access.
  Future<bool> hasPermissions() async {
    final result = await _plugin.hasPermissions();
    return result.isSuccess && (result.data ?? false);
  }

  /// Prompts the user for read access. Returns `true` if granted.
  Future<bool> requestPermissions() async {
    final result = await _plugin.requestPermissions();
    return result.isSuccess && (result.data ?? false);
  }

  /// Reads events from the next [window] days across every user calendar.
  /// Throws [CalendarException] on relevant failures.
  Future<CalendarFetchResult> fetchUpcomingEvents({
    Duration window = const Duration(days: 30),
  }) async {
    final calendarsResult = await _plugin.retrieveCalendars();
    if (!calendarsResult.isSuccess || calendarsResult.data == null) {
      throw CalendarException(
        CalendarFailure.readError,
        calendarsResult.errors.map((e) => e.errorMessage).join('; '),
      );
    }

    final calendars = calendarsResult.data!;
    final colors = <String, Color>{
      for (final cal in calendars)
        if (cal.id != null && cal.color != null)
          cal.id!: Color(cal.color!),
    };

    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(window);
    final params = RetrieveEventsParams(startDate: start, endDate: end);

    final aggregated = <Event>[];
    for (final calendar in calendars) {
      if (calendar.id == null) continue;
      final eventsResult =
          await _plugin.retrieveEvents(calendar.id, params);
      if (eventsResult.isSuccess && eventsResult.data != null) {
        aggregated.addAll(eventsResult.data!);
      }
    }

    aggregated.sort((a, b) {
      final aStart = a.start;
      final bStart = b.start;
      if (aStart == null && bStart == null) return 0;
      if (aStart == null) return 1;
      if (bStart == null) return -1;
      return aStart.compareTo(bStart);
    });

    return CalendarFetchResult(events: aggregated, calendarColors: colors);
  }
}
