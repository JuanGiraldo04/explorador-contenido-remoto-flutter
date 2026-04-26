import 'package:explorador_contenido_remoto/features/location/domain/entities/location.dart';
import 'package:explorador_contenido_remoto/features/location/presentation/screens/location_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const tLocation = Location(
    id: 1,
    name: 'Earth (C-137)',
    type: 'Planet',
    dimension: 'Dimension C-137',
    residentCount: 27,
  );

  Widget buildSubject(Location location) {
    return MaterialApp(home: LocationDetailScreen(location: location));
  }

  group('LocationDetailScreen', () {
    testWidgets('shows location name in AppBar and body', (tester) async {
      await tester.pumpWidget(buildSubject(tLocation));
      expect(find.text('Earth (C-137)'), findsWidgets);
    });

    testWidgets('shows type info row', (tester) async {
      await tester.pumpWidget(buildSubject(tLocation));
      expect(find.text('Tipo'), findsOneWidget);
      expect(find.text('Planet'), findsOneWidget);
    });

    testWidgets('shows dimension info row', (tester) async {
      await tester.pumpWidget(buildSubject(tLocation));
      expect(find.text('Dimensión'), findsOneWidget);
      expect(find.text('Dimension C-137'), findsOneWidget);
    });

    testWidgets('shows resident count', (tester) async {
      await tester.pumpWidget(buildSubject(tLocation));
      expect(find.text('Residentes'), findsOneWidget);
      expect(find.text('27'), findsOneWidget);
    });
  });
}
