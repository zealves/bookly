import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

/// Minimalist event card with a colored side bar matching the source calendar.
class EventCard extends StatelessWidget {
  const EventCard({
    super.key,
    required this.event,
    required this.accentColor,
  });

  final Event event;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final isDark =
        CupertinoTheme.brightnessOf(context) == Brightness.dark;
    final cardBg = isDark
        ? const Color(0xFF1C1C1E)
        : CupertinoColors.white;
    final titleColor = isDark
        ? CupertinoColors.white
        : CupertinoColors.label.resolveFrom(context);
    final subtitleColor =
        CupertinoColors.secondaryLabel.resolveFrom(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  bottomLeft: Radius.circular(14),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      (event.title?.trim().isNotEmpty ?? false)
                          ? event.title!
                          : 'Untitled',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: titleColor,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatTimeRange(event),
                      style: TextStyle(
                        fontSize: 14,
                        color: subtitleColor,
                        letterSpacing: -0.1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimeRange(Event event) {
    if (event.allDay ?? false) return 'All day';
    final fmt = DateFormat.jm('en_US');
    final start = event.start;
    final end = event.end;
    if (start == null) return '—';
    if (end == null) return fmt.format(start.toLocal());
    return '${fmt.format(start.toLocal())} – ${fmt.format(end.toLocal())}';
  }
}
