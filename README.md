# Bookly

A Flutter iOS app that surfaces your iPhone's upcoming calendar events in a
clean, minimal interface aligned with the Apple Human Interface Guidelines.

Bookly reads from the native iOS calendar store — no servers, no sync, no
accounts. Everything stays on the device.

## Features

- Reads events from every user calendar on the device (next 30 days).
- Groups events by day with friendly headers: **Today**, **Tomorrow**,
  weekday names, then full dates.
- Event cards show the title, start/end time and a side accent in the
  calendar's original color.
- First-run onboarding screen explaining why calendar access is needed.
- Cupertino-native loading, empty and error states, plus pull-to-refresh.
- Dark mode follows the iOS system setting automatically.

## Tech stack

- **Flutter** (Dart `^3.12`)
- [`device_calendar`](https://pub.dev/packages/device_calendar) — native
  calendar bridge.
- [`intl`](https://pub.dev/packages/intl) — locale-aware date and time
  formatting.

## Project structure

```
lib/
├── main.dart                       # App entry, Cupertino theme, intl init
├── services/
│   └── calendar_service.dart       # Isolated layer over device_calendar
├── models/
│   └── event_section.dart          # Per-day grouping + header labels
├── screens/
│   ├── events_screen.dart          # Orchestrates permission → load → render
│   └── permission_screen.dart      # Onboarding / access request CTA
└── widgets/
    ├── event_card.dart             # Card with calendar-colored side bar
    ├── section_header.dart         # Discreet day header
    ├── empty_state.dart            # "No events ahead"
    └── error_state.dart            # Error message + retry
```

The UI never talks to `device_calendar` directly — all native interaction
goes through `CalendarService`, which exposes a small, testable surface
(`hasPermissions`, `requestPermissions`, `fetchUpcomingEvents`).

## Getting started

Prerequisites: a recent Flutter SDK and Xcode for iOS builds.

```bash
flutter pub get
flutter run -d <your-iphone-or-simulator>
```

To build a release-ready iOS bundle:

```bash
flutter build ios --release
```

## iOS permissions

`ios/Runner/Info.plist` declares the keys required by iOS 17+:

- `NSCalendarsUsageDescription`
- `NSCalendarsFullAccessUsageDescription`

If the user denies access, the app surfaces a hint pointing them to
**Settings › Privacy › Calendars** to enable it later.

## License

MIT — feel free to use, fork and adapt.
