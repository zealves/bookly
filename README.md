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
- Tap any event to open a detail screen and attach photos from the
  device gallery. Multiple photos per event, long-press to delete.
- First-run onboarding screen explaining why calendar access is needed.
- Cupertino-native loading, empty and error states, plus pull-to-refresh.
- Dark mode follows the iOS system setting automatically.

## Tech stack

- **Flutter** (Dart `^3.12`)
- [`device_calendar`](https://pub.dev/packages/device_calendar) — native
  calendar bridge.
- [`image_picker`](https://pub.dev/packages/image_picker) — gallery
  selection via `PHPicker`.
- [`path_provider`](https://pub.dev/packages/path_provider) +
  [`path`](https://pub.dev/packages/path) — locate and build paths inside
  the app documents directory.
- [`shared_preferences`](https://pub.dev/packages/shared_preferences) —
  persists the `eventId → [photoPath]` index.
- [`intl`](https://pub.dev/packages/intl) — locale-aware date and time
  formatting.

## Project structure

```
lib/
├── main.dart                       # App entry, Cupertino theme, intl init
├── services/
│   ├── calendar_service.dart       # Isolated layer over device_calendar
│   └── photo_storage_service.dart  # Picks, copies and indexes event photos
├── models/
│   └── event_section.dart          # Per-day grouping + header labels
├── screens/
│   ├── events_screen.dart          # Orchestrates permission → load → render
│   ├── event_detail_screen.dart    # Event header + attached photos gallery
│   └── permission_screen.dart      # Onboarding / access request CTA
├── utils/
│   └── event_formatting.dart       # Shared title/time-range formatters
└── widgets/
    ├── event_card.dart             # Tappable card with calendar-colored side bar
    ├── event_photo_grid.dart       # 3-column grid with long-press to delete
    ├── section_header.dart         # Discreet day header
    ├── empty_state.dart            # "No events ahead"
    └── error_state.dart            # Error message + retry
```

The UI never talks to `device_calendar` directly — all native interaction
goes through `CalendarService`, which exposes a small, testable surface
(`hasPermissions`, `requestPermissions`, `fetchUpcomingEvents`).
Photo handling is similarly encapsulated in `PhotoStorageService`
(`getPhotos`, `pickAndAttachPhoto`, `removePhoto`).

## Event photos

Tapping an event card pushes `EventDetailScreen`, which lets the user
attach photos from the device gallery. Because `device_calendar` does
not support media attachments natively, Bookly persists the association
locally:

- **Binary files** are copied (not referenced) into
  `<ApplicationDocumentsDirectory>/event_photos/<eventId>/<timestamp>.<ext>`
  via `path_provider`. Copying is required because `image_picker` returns
  a temporary cache path that iOS may purge.
- **The `eventId → [photoPath]` index** is stored as JSON in
  `SharedPreferences` under the key `event_photos`.

Everything stays inside the app sandbox: photos are not added to the
system Photos app, are private to Bookly, and are removed when the app
is uninstalled.

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
- `NSPhotoLibraryUsageDescription` — shown when the user attaches a
  photo to an event.

If the user denies calendar access, the app surfaces a hint pointing
them to **Settings › Privacy › Calendars** to enable it later.

## License

MIT — feel free to use, fork and adapt.
