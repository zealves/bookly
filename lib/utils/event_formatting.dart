import 'package:device_calendar/device_calendar.dart';
import 'package:intl/intl.dart';

String formatEventTimeRange(Event event, {String locale = 'en_US'}) {
  if (event.allDay ?? false) return 'All day';
  final fmt = DateFormat.jm(locale);
  final start = event.start;
  final end = event.end;
  if (start == null) return '—';
  if (end == null) return fmt.format(start.toLocal());
  return '${fmt.format(start.toLocal())} – ${fmt.format(end.toLocal())}';
}

String formatEventTitle(Event event) {
  final title = event.title?.trim();
  if (title == null || title.isEmpty) return 'Untitled';
  return title;
}
