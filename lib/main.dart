import 'package:flutter/cupertino.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'screens/events_screen.dart';
import 'services/calendar_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('en_US');
  runApp(const BooklyApp());
}

class BooklyApp extends StatelessWidget {
  const BooklyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Bookly',
      debugShowCheckedModeBanner: false,
      theme: const CupertinoThemeData(
        brightness: null,
        primaryColor: CupertinoColors.systemBlue,
        scaffoldBackgroundColor: CupertinoColors.systemGroupedBackground,
      ),
      home: EventsScreen(service: CalendarService()),
    );
  }
}
