import 'package:flutter/cupertino.dart';

/// Elegant empty state shown when there are no events on the horizon.
class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final accent = CupertinoColors.systemBlue.resolveFrom(context);
    final secondary =
        CupertinoColors.secondaryLabel.resolveFrom(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                CupertinoIcons.calendar,
                size: 42,
                color: accent,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No events ahead',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.4,
                color: CupertinoColors.label.resolveFrom(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your next 30 days are clear. Enjoy the break.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                height: 1.35,
                color: secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
