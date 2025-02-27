import 'package:cinecast_fyp/screens/home_screen.dart';
import 'package:cinecast_fyp/screens/s1_home.dart';
import 'package:cinecast_fyp/screens/s2_prediction.dart';
import 'package:cinecast_fyp/screens/s3_search.dart';
import 'package:cinecast_fyp/screens/s4_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HomeScreen Widget Tests', () {
    testWidgets('HomeScreen correctly interact with the BottomNavigationBar',
        (WidgetTester tester) async {
      //build app and triggers a frame
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

      //expect that the BottomNavigationBar is present.
      expect(find.byType(BottomNavigationBar), findsOneWidget);

      //expect that the initial screen is the Home screen.
      expect(find.byType(Home), findsOneWidget);
      expect(find.byType(Prediction), findsNothing);
      expect(find.byType(Search), findsNothing);
      expect(find.byType(SettingsScreen), findsNothing);

      //expect that the bottom navigation items are present
      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.movie), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Prediction'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });
  });
}
