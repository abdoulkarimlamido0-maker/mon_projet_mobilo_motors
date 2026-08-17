import 'package:flutter_test/flutter_test.dart';
import 'package:mobilo_app/main.dart';

void main() {
  testWidgets('Aperçu de l\'application Gari', (WidgetTester tester) async {
    // Remplacement de GariPreviewApp par GariInteractiveApp
    await tester.pumpWidget(const GariInteractiveApp());

    // Vérifie que l'application charge bien l'écran d'authentification
    expect(find.text('Gari.'), findsWidgets);
  });
}
