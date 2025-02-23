// // This is a basic Flutter widget test.
// //
// // To perform an interaction with a widget in your test, use the WidgetTester
// // utility in the flutter_test package. For example, you can send tap and scroll
// // gestures. You can also use WidgetTester to find child widgets in the widget
// // tree, read text, and verify that the values of widget properties are correct.

// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';

// import 'package:cinecast_fyp/main.dart';

// void main() {
//   testWidgets('Counter increments smoke test', (WidgetTester tester) async {
//     // Build our app and trigger a frame.
//     await tester.pumpWidget(const MyApp());

//     // Verify that our counter starts at 0.
//     expect(find.text('0'), findsOneWidget);
//     expect(find.text('1'), findsNothing);

//     // Tap the '+' icon and trigger a frame.
//     await tester.tap(find.byIcon(Icons.add));
//     await tester.pump();

//     // Verify that our counter has incremented.
//     expect(find.text('0'), findsNothing);
//     expect(find.text('1'), findsOneWidget);
//   });
// }

import 'package:cinecast_fyp/main.dart';
import 'package:cinecast_fyp/screens/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MyApp Widget Tests', () {
    // Initialize Firebase before running any tests.  Important if your app
    // relies on Firebase functionality during widget testing.  This is usually
    // done using a setUpAll block.
    setUpAll(() async {
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp(); // Ensure Firebase is initialized
    });

    testWidgets('MyApp should render the LoginScreen as its home',
        (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const MyApp());

      // Verify that the LoginScreen is displayed.
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('MyApp title should be "CineCast"',
        (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const MyApp());

      // Find the MaterialApp widget
      final materialAppFinder = find.byType(MaterialApp);

      // Extract the MaterialApp widget from the widget tree.
      final MaterialApp materialApp = tester.widget(materialAppFinder);

      // Verify that the title is "CineCast".
      expect(materialApp.title, 'CineCast');
    });
  });
}
