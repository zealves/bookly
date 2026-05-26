import 'package:bookly/screens/permission_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Permission screen renders CTA and copy',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      CupertinoApp(
        home: PermissionScreen(onRequestAccess: () async {}),
      ),
    );

    expect(find.text('Your events, all in one place'), findsOneWidget);
    expect(find.text('Allow calendar access'), findsOneWidget);
  });
}
