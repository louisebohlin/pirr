import 'package:flutter_test/flutter_test.dart';
import 'package:pirr_app/utils/time_ago.dart';

void main() {
  test('formatTimeAgo formats typical ranges', () {
    final fixedNow = DateTime(2025, 1, 1, 12, 0, 0);
    expect(
      formatTimeAgo(
        fixedNow.subtract(const Duration(seconds: 5)),
        now: fixedNow,
      ),
      '5s ago',
    );
    expect(
      formatTimeAgo(
        fixedNow.subtract(const Duration(minutes: 2)),
        now: fixedNow,
      ),
      '2m ago',
    );
    expect(
      formatTimeAgo(fixedNow.subtract(const Duration(hours: 3)), now: fixedNow),
      '3h ago',
    );
    expect(
      formatTimeAgo(fixedNow.subtract(const Duration(days: 2)), now: fixedNow),
      '2d ago',
    );
    expect(
      formatTimeAgo(fixedNow.subtract(const Duration(days: 14)), now: fixedNow),
      '2w ago',
    );
    expect(
      formatTimeAgo(fixedNow.subtract(const Duration(days: 60)), now: fixedNow),
      '2mo ago',
    );
    expect(
      formatTimeAgo(
        fixedNow.subtract(const Duration(days: 365)),
        now: fixedNow,
      ),
      '1y ago',
    );
  });
}
