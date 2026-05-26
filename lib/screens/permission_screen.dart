import 'package:flutter/cupertino.dart';

/// Onboarding screen shown when calendar permission has not been granted yet.
class PermissionScreen extends StatelessWidget {
  const PermissionScreen({
    super.key,
    required this.onRequestAccess,
    this.isRequesting = false,
    this.deniedHint,
  });

  final Future<void> Function() onRequestAccess;
  final bool isRequesting;

  /// Optional hint shown when the user has previously denied access — in that
  /// case the native prompt may not appear again, so we point them to iOS
  /// Settings instead.
  final String? deniedHint;

  @override
  Widget build(BuildContext context) {
    final accent = CupertinoColors.systemBlue.resolveFrom(context);
    return CupertinoPageScaffold(
      backgroundColor:
          CupertinoColors.systemGroupedBackground.resolveFrom(context),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const Spacer(flex: 2),
              Container(
                width: 108,
                height: 108,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Icon(
                  CupertinoIcons.calendar_today,
                  size: 56,
                  color: accent,
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'Your events, all in one place',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.6,
                  color: CupertinoColors.label.resolveFrom(context),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'To show your upcoming schedule, Bookly needs access to '
                "your iPhone calendar. Nothing leaves the device.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.4,
                  color: CupertinoColors.secondaryLabel.resolveFrom(context),
                ),
              ),
              if (deniedHint != null) ...[
                const SizedBox(height: 14),
                Text(
                  deniedHint!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color:
                        CupertinoColors.systemOrange.resolveFrom(context),
                  ),
                ),
              ],
              const Spacer(flex: 3),
              SizedBox(
                width: double.infinity,
                child: CupertinoButton.filled(
                  onPressed: isRequesting ? null : onRequestAccess,
                  child: isRequesting
                      ? const CupertinoActivityIndicator(
                          color: CupertinoColors.white,
                        )
                      : const Text(
                          'Allow calendar access',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
