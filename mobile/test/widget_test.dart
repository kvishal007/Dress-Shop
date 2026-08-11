import 'package:flutter_test/flutter_test.dart';
import 'package:smart_dress_shop_pos/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SmartDressShopApp());
  });
}
