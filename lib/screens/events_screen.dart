import 'package:flutter/cupertino.dart';

import '../models/event_section.dart';
import '../services/calendar_service.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_state.dart';
import '../widgets/event_card.dart';
import '../widgets/section_header.dart';
import 'permission_screen.dart';

/// Main screen. Coordinates permission, loading, error and ready states for
/// the events grouped by day.
class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key, required this.service});

  final CalendarService service;

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

enum _ViewState { loading, permissionRequired, ready, error }

class _EventsScreenState extends State<EventsScreen> {
  _ViewState _state = _ViewState.loading;
  bool _requestingPermission = false;
  String? _permissionHint;
  CalendarFetchResult? _result;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    setState(() => _state = _ViewState.loading);
    final has = await widget.service.hasPermissions();
    if (!mounted) return;
    if (!has) {
      setState(() => _state = _ViewState.permissionRequired);
      return;
    }
    await _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() => _state = _ViewState.loading);
    try {
      final result = await widget.service.fetchUpcomingEvents();
      if (!mounted) return;
      setState(() {
        _result = result;
        _state = _ViewState.ready;
      });
    } on CalendarException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.message ?? 'Please try again in a moment.';
        _state = _ViewState.error;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'An unexpected error occurred.';
        _state = _ViewState.error;
      });
    }
  }

  Future<void> _handlePermissionRequest() async {
    setState(() => _requestingPermission = true);
    final granted = await widget.service.requestPermissions();
    if (!mounted) return;
    setState(() => _requestingPermission = false);
    if (granted) {
      await _loadEvents();
    } else {
      setState(() {
        _permissionHint =
            'Access denied. You can enable it in Settings › Privacy › Calendars.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (_state) {
      case _ViewState.permissionRequired:
        return PermissionScreen(
          onRequestAccess: _handlePermissionRequest,
          isRequesting: _requestingPermission,
          deniedHint: _permissionHint,
        );
      case _ViewState.loading:
      case _ViewState.ready:
      case _ViewState.error:
        return _buildEventsScaffold(context);
    }
  }

  Widget _buildEventsScaffold(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor:
          CupertinoColors.systemGroupedBackground.resolveFrom(context),
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          const CupertinoSliverNavigationBar(
            largeTitle: Text('Upcoming'),
            border: null,
          ),
          CupertinoSliverRefreshControl(
            onRefresh: _loadEvents,
          ),
          SliverFillRemaining(
            hasScrollBody: _state == _ViewState.ready &&
                (_result?.events.isNotEmpty ?? false),
            child: _buildBody(context),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_state == _ViewState.loading) {
      return const Center(child: CupertinoActivityIndicator(radius: 14));
    }
    if (_state == _ViewState.error) {
      return ErrorState(message: _errorMessage, onRetry: _loadEvents);
    }
    final result = _result;
    if (result == null || result.isEmpty) {
      return const EmptyState();
    }
    return _EventList(result: result);
  }
}

class _EventList extends StatelessWidget {
  const _EventList({required this.result});

  final CalendarFetchResult result;

  @override
  Widget build(BuildContext context) {
    final sections = groupEventsByDay(result.events);
    final now = DateTime.now();
    final fallback = CupertinoColors.systemBlue.resolveFrom(context);

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
      itemCount: sections.length,
      itemBuilder: (context, index) {
        final section = sections[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SectionHeader(label: section.label(now)),
            for (final event in section.events)
              EventCard(
                event: event,
                accentColor: result.calendarColors[event.calendarId] ??
                    fallback,
              ),
          ],
        );
      },
    );
  }
}
