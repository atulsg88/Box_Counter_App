import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';

// Make sure these imports match your package name in pubspec.yaml
import 'package:flutter_application_2/main.dart';
// We must also import the firebase_options to initialize the app
import 'package:flutter_application_2/firebase_options.dart';

void main() {
  // This is the new, crucial part.
  // It ensures Firebase is initialized ONCE before any tests run.
  setUpAll(() async {
    // This is required to initialize bindings before calling Firebase.initializeApp
    TestWidgetsFlutterBinding.ensureInitialized();
    // This initializes Firebase using your firebase_options.dart
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  });

  testWidgets('App renders, shows title, and handles no data', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ObjectCounterApp());

    // 1. Verify the app title is present.
    // (This was failing because the app crashed before it could build)
    expect(find.text('Live Object Counts'), findsOneWidget);

    // 2. Initially, it should show a loading indicator
    //    while waiting for the Firebase stream.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // 3. Settle the widget tree to allow the StreamBuilder
    //    to receive its initial (likely empty) data.
    await tester.pumpAndSettle();

    // 4. Now the loading indicator should be gone.
    expect(find.byType(CircularProgressIndicator), findsNothing);

    // 5. Since the database is empty (in a test environment),
    //    it should now show the "No data found" message.
    expect(find.text('No data found.\nRun your Python script to send data.'), findsOneWidget);
  });
}