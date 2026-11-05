/// What the backend knows of the user's subscription and free photos
/// (`GET /bobobidou/subscription`). The backend decides who may send photos:
/// the app only uses this to explain it.
class SubscriptionStatus {
  /// RevenueCat app user id: an HMAC of the email, computed by the backend.
  final String appUserId;
  final bool premium;

  /// End of the paid period, when [premium].
  final DateTime? expiresAt;

  /// False once the subscription is cancelled (it stays active until [expiresAt]).
  final bool willRenew;
  final int freePhotosLeft;
  final int freePhotosTotal;
  final int dailyPhotoLimit;

  const SubscriptionStatus({
    required this.appUserId,
    required this.premium,
    required this.expiresAt,
    required this.willRenew,
    required this.freePhotosLeft,
    required this.freePhotosTotal,
    required this.dailyPhotoLimit,
  });

  /// Neither subscribed nor any free photo left: a photo would be refused.
  bool get needsSubscription => !premium && freePhotosLeft <= 0;

  factory SubscriptionStatus.fromJson(Map<String, dynamic> json) {
    final expiresAt = json['expires_at'];
    return SubscriptionStatus(
      appUserId: json['app_user_id'] as String,
      premium: json['premium'] == true,
      expiresAt: expiresAt is String ? DateTime.parse(expiresAt).toLocal() : null,
      willRenew: json['will_renew'] == true,
      freePhotosLeft: (json['free_photos_left'] as num?)?.toInt() ?? 0,
      freePhotosTotal: (json['free_photos_total'] as num?)?.toInt() ?? 0,
      dailyPhotoLimit: (json['daily_photo_limit'] as num?)?.toInt() ?? 0,
    );
  }
}
