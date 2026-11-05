import 'package:bobobidou/models/subscription_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('reads the backend status of a subscriber', () {
    final status = SubscriptionStatus.fromJson({
      'app_user_id': 'abc',
      'premium': true,
      'expires_at': '2026-12-02T10:00:00+00:00',
      'will_renew': false,
      'free_photos_left': 0,
      'free_photos_total': 3,
      'daily_photo_limit': 5,
    });
    expect(status.premium, isTrue);
    expect(status.willRenew, isFalse);
    expect(status.expiresAt!.toUtc(), DateTime.utc(2026, 12, 2, 10));
    // A subscriber may send photos even with no free photo left
    expect(status.needsSubscription, isFalse);
  });

  test('needs a subscription once the free photos are used up', () {
    SubscriptionStatus withLeft(int left) => SubscriptionStatus.fromJson({
          'app_user_id': 'abc',
          'premium': false,
          'expires_at': null,
          'will_renew': false,
          'free_photos_left': left,
          'free_photos_total': 3,
          'daily_photo_limit': 5,
        });
    expect(withLeft(1).needsSubscription, isFalse);
    expect(withLeft(0).needsSubscription, isTrue);
    expect(withLeft(0).expiresAt, isNull);
  });
}
