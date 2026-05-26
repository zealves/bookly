import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/cupertino.dart';

import '../services/photo_storage_service.dart';
import '../utils/event_formatting.dart';
import '../widgets/event_photo_grid.dart';

class EventDetailScreen extends StatefulWidget {
  const EventDetailScreen({
    super.key,
    required this.event,
    required this.accentColor,
    required this.photoService,
  });

  final Event event;
  final Color accentColor;
  final PhotoStorageService photoService;

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  List<String> _photos = const [];
  bool _loading = true;
  bool _picking = false;

  String? get _eventId => widget.event.eventId;

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    final id = _eventId;
    if (id == null) {
      setState(() => _loading = false);
      return;
    }
    final photos = await widget.photoService.getPhotos(id);
    if (!mounted) return;
    setState(() {
      _photos = photos;
      _loading = false;
    });
  }

  Future<void> _addPhoto() async {
    final id = _eventId;
    if (id == null || _picking) return;
    setState(() => _picking = true);
    try {
      final path = await widget.photoService.pickAndAttachPhoto(id);
      if (!mounted) return;
      if (path != null) {
        setState(() => _photos = [..._photos, path]);
      }
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  Future<void> _deletePhoto(String path) async {
    final id = _eventId;
    if (id == null) return;
    await widget.photoService.removePhoto(id, path);
    if (!mounted) return;
    setState(() => _photos = _photos.where((p) => p != path).toList());
  }

  @override
  Widget build(BuildContext context) {
    final subtitleColor =
        CupertinoColors.secondaryLabel.resolveFrom(context);

    return CupertinoPageScaffold(
      backgroundColor:
          CupertinoColors.systemGroupedBackground.resolveFrom(context),
      child: CustomScrollView(
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: Text(formatEventTitle(widget.event)),
            border: null,
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildHeaderCard(subtitleColor),
                const SizedBox(height: 24),
                _buildAddButton(),
                const SizedBox(height: 20),
                _buildPhotosSection(subtitleColor),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(Color subtitleColor) {
    final isDark =
        CupertinoTheme.brightnessOf(context) == Brightness.dark;
    final cardBg = isDark
        ? const Color(0xFF1C1C1E)
        : CupertinoColors.white;

    return Container(
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
                color: widget.accentColor,
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
                  vertical: 14,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      formatEventTitle(widget.event),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      formatEventTimeRange(widget.event),
                      style: TextStyle(
                        fontSize: 14,
                        color: subtitleColor,
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

  Widget _buildAddButton() {
    final enabled = _eventId != null && !_picking;
    return SizedBox(
      width: double.infinity,
      child: CupertinoButton.filled(
        onPressed: enabled ? _addPhoto : null,
        child: _picking
            ? const CupertinoActivityIndicator(color: CupertinoColors.white)
            : const Text('Add Photo'),
      ),
    );
  }

  Widget _buildPhotosSection(Color subtitleColor) {
    if (_eventId == null) {
      return Text(
        'This event has no identifier, so photos cannot be attached.',
        style: TextStyle(color: subtitleColor, fontSize: 14),
      );
    }
    if (_loading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: CupertinoActivityIndicator(),
        ),
      );
    }
    if (_photos.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            'No photos yet. Tap “Add Photo” to attach one.',
            style: TextStyle(color: subtitleColor, fontSize: 14),
          ),
        ),
      );
    }
    return EventPhotoGrid(
      photoPaths: _photos,
      onDelete: _deletePhoto,
    );
  }
}
