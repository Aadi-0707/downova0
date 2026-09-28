import 'package:downova/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Downova app renders the configured app name', (tester) async {
    await tester.pumpWidget(
      DownovaApp(
        config: {
          'app': {'name': 'Downova', 'font_family': 'Roboto'},
          'theme': {
            'default_mode': 'light',
            'modes': {
              'light': {'background': '#FFFFFF'},
              'dark': {'background': '#121212'},
            },
          },
        },
      ),
    );

    expect(find.text('Downova'), findsOneWidget);
  });

  testWidgets('Downova app renders a fallback when config is incomplete', (
    tester,
  ) async {
    await tester.pumpWidget(
      DownovaApp(
        config: {
          'app': {'name': 'Sample App'},
        },
      ),
    );

    expect(find.text('Sample App'), findsOneWidget);
  });
}
