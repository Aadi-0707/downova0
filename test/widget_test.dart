import 'package:downova/config/app_config.dart';
import 'package:downova/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('DOWNOVA app renders the configured app name', (tester) async {
    final config = await AppConfig.load();

    await tester.pumpWidget(DownovaApp(config: config));
    await tester.pump();

    expect(find.text(config.string('app.name')), findsOneWidget);
  });
}
