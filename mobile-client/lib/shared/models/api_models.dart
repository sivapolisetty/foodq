import 'deal.dart';

/// API response model for deals with distance (from nearby endpoint)
class DealWithDistance {
  final Deal deal;
  final double distanceKm;
  final String formattedDistance;
  final String walkingTimeEstimate;
  final String urgencyLevel;
  
  const DealWithDistance({
    required this.deal,
    required this.distanceKm,
    required this.formattedDistance,
    required this.walkingTimeEstimate,
    required this.urgencyLevel,
  });
  
  factory DealWithDistance.fromJson(Map<String, dynamic> json) {
    return DealWithDistance(
      deal: Deal.fromJson(json['deal'] as Map<String, dynamic>),
      distanceKm: (json['distance_km'] as num).toDouble(),
      formattedDistance: json['formatted_distance'] as String,
      walkingTimeEstimate: json['walking_time_estimate'] as String,
      urgencyLevel: json['urgency_level'] as String,
    );
  }
}

/// API response model for missed deals (from user missed-deals endpoint)
class MissedDeal {
  final Deal deal;
  final DateTime viewedAt;
  final int viewCount;
  final DateTime lastInteraction;
  final String urgencyLevel;
  final String fomoMessage;
  final double urgencyScore;
  
  const MissedDeal({
    required this.deal,
    required this.viewedAt,
    required this.viewCount,
    required this.lastInteraction,
    required this.urgencyLevel,
    required this.fomoMessage,
    required this.urgencyScore,
  });
  
  factory MissedDeal.fromJson(Map<String, dynamic> json) {
    return MissedDeal(
      deal: Deal.fromJson(json['deal'] as Map<String, dynamic>),
      viewedAt: DateTime.parse(json['viewed_at'] as String),
      viewCount: json['view_count'] as int,
      lastInteraction: DateTime.parse(json['last_interaction'] as String),
      urgencyLevel: json['urgency_level'] as String,
      fomoMessage: json['fomo_message'] as String,
      urgencyScore: (json['urgency_score'] as num).toDouble(),
    );
  }
  
  /// Check if this deal is ending soon (server-calculated)
  bool get isEndingSoon => urgencyLevel == 'critical' || urgencyLevel == 'high';
  
  /// Check if user has high hesitation (server-calculated)  
  bool get isHighHesitation => viewCount >= 3;
}

/// API response model for expired deals (from user expired-deals endpoint)
class ExpiredDeal {
  final Deal deal;
  final DateTime expiredAt;
  final DateTime discoveredAt;
  final bool wasViewedByUser;
  final bool wasInUserCart;
  final String regretLevel;
  final String regretMessage;
  final String timeDisplayMessage;
  
  const ExpiredDeal({
    required this.deal,
    required this.expiredAt,
    required this.discoveredAt,
    required this.wasViewedByUser,
    required this.wasInUserCart,
    required this.regretLevel,
    required this.regretMessage,
    required this.timeDisplayMessage,
  });
  
  factory ExpiredDeal.fromJson(Map<String, dynamic> json) {
    return ExpiredDeal(
      deal: Deal.fromJson(json['deal'] as Map<String, dynamic>),
      expiredAt: DateTime.parse(json['expired_at'] as String),
      discoveredAt: DateTime.parse(json['discovered_at'] as String),
      wasViewedByUser: json['was_viewed_by_user'] as bool,
      wasInUserCart: json['was_in_user_cart'] as bool,
      regretLevel: json['regret_level'] as String,
      regretMessage: json['regret_message'] as String,
      timeDisplayMessage: json['time_display_message'] as String,
    );
  }
  
  /// Time since this deal expired (server provides formatted message)
  String get expiryUrgencyMessage => timeDisplayMessage;
  
  /// Get regret level for styling
  RegretLevel get displayRegretLevel {
    switch (regretLevel) {
      case 'maximum':
        return RegretLevel.maximum;
      case 'high':
        return RegretLevel.high;
      case 'medium':
        return RegretLevel.medium;
      default:
        return RegretLevel.low;
    }
  }
}

/// Statistics from server about missed deals
class MissedDealStats {
  final int totalMissed;
  final int endingSoon;
  final int highHesitation;
  final double totalMissedSavings;
  final String primaryFOMOMessage;
  final String secondaryFOMOMessage;
  
  const MissedDealStats({
    required this.totalMissed,
    required this.endingSoon,
    required this.highHesitation,
    required this.totalMissedSavings,
    required this.primaryFOMOMessage,
    required this.secondaryFOMOMessage,
  });
  
  factory MissedDealStats.fromJson(Map<String, dynamic> json) {
    return MissedDealStats(
      totalMissed: json['total_missed'] as int,
      endingSoon: json['ending_soon'] as int,
      highHesitation: json['high_hesitation'] as int,
      totalMissedSavings: (json['total_missed_savings'] as num).toDouble(),
      primaryFOMOMessage: json['primary_fomo_message'] as String,
      secondaryFOMOMessage: json['secondary_fomo_message'] as String,
    );
  }
}

/// Statistics from server about expired deals  
class ExpiredDealStats {
  final int totalExpired;
  final int viewedExpired;
  final int cartExpired;
  final int recentlyExpired;
  final double totalExpiredValue;
  final double totalExpiredSavings;
  final String primaryRegretMessage;
  final String secondaryRegretMessage;
  final String actionableMessage;
  
  const ExpiredDealStats({
    required this.totalExpired,
    required this.viewedExpired,
    required this.cartExpired,
    required this.recentlyExpired,
    required this.totalExpiredValue,
    required this.totalExpiredSavings,
    required this.primaryRegretMessage,
    required this.secondaryRegretMessage,
    required this.actionableMessage,
  });
  
  factory ExpiredDealStats.fromJson(Map<String, dynamic> json) {
    return ExpiredDealStats(
      totalExpired: json['total_expired'] as int,
      viewedExpired: json['viewed_expired'] as int,
      cartExpired: json['cart_expired'] as int,
      recentlyExpired: json['recently_expired'] as int,
      totalExpiredValue: (json['total_expired_value'] as num).toDouble(),
      totalExpiredSavings: (json['total_expired_savings'] as num).toDouble(),
      primaryRegretMessage: json['primary_regret_message'] as String,
      secondaryRegretMessage: json['secondary_regret_message'] as String,
      actionableMessage: json['actionable_message'] as String,
    );
  }
}

/// Regret levels for UI styling (simplified from server response)
enum RegretLevel {
  low,
  medium, 
  high,
  maximum,
}