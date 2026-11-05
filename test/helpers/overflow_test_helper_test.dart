import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'overflow_test_helper.dart';

void main() {
  testWidgets('pumpAndCheckOverflow passes on flexible responsive widget', (
    tester,
  ) async {
    await pumpAndCheckOverflow(
      tester,
      child: Row(
        children: const [
          Icon(Icons.star),
          Expanded(
            child: Text(
              'A very long text that must wrap cleanly without causing overflow',
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  });
}
