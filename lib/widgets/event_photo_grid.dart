import 'dart:io';

import 'package:flutter/cupertino.dart';

class EventPhotoGrid extends StatelessWidget {
  const EventPhotoGrid({
    super.key,
    required this.photoPaths,
    required this.onDelete,
  });

  final List<String> photoPaths;
  final Future<void> Function(String path) onDelete;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: photoPaths.length,
      itemBuilder: (context, index) {
        final path = photoPaths[index];
        return GestureDetector(
          onLongPress: () => _confirmDelete(context, path),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.file(
              File(path),
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, String path) async {
    final shouldDelete = await showCupertinoModalPopup<bool>(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: const Text('Delete photo?'),
        message: const Text('This will remove the photo from this event.'),
        actions: [
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel'),
        ),
      ),
    );
    if (shouldDelete ?? false) {
      await onDelete(path);
    }
  }
}
