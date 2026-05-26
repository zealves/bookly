import 'package:device_calendar/device_calendar.dart';
import 'package:intl/intl.dart';

/// One day of the list, with the events that belong to it.
class EventSection {
  const EventSection({required this.day, required this.events});

  final DateTime day;
  final List<Event> events;

  /// Human-readable header label (Today / Tomorrow / weekday / date).
  String label(DateTime now, {String locale = 'en_US'}) {
    final today = DateTime(now.year, now.month, now.day);
    final diff = day.difference(today).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    if (diff > 1 && diff < 7) {
      return DateFormat('EEEE', locale).format(day);
    }
    return DateFormat.MMMMd(locale).format(day);
  }
}

/// Buckets a flat list of events into per-day [EventSection]s.
List<EventSection> groupEventsByDay(List<Event> events) {
  final buckets = <DateTime, List<Event>>{};
  for (final event in events) {
    final start = event.start;
    if (start == null) continue;
    final key = DateTime(start.year, start.month, start.day);
    buckets.putIfAbsent(key, () => []).add(event);
  }
  final sortedKeys = buckets.keys.toList()..sort();
  return [
    for (final key in sortedKeys)
      EventSection(day: key, events: buckets[key]!),
  ];
}
