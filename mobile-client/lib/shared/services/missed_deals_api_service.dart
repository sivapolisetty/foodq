import 'dart:async';
import '../../core/services/api_service.dart';
import '../../core/config/api_config.dart';
import '../models/api_models.dart';
import '../models/deal.dart';

/// Clean API-driven service for missed deals
/// TEMPORARY: Uses existing deals API until backend endpoints are implemented
class MissedDealsApiService {
  
  /// Get missed deals by simulating user viewed but not purchased deals
  /// TEMPORARY: Until proper missed deals endpoint is implemented
  static Future<List<MissedDeal>> getMissedDeals() async {
    try {
      // Use existing deals API and simulate missed deals
      final response = await ApiService.get<dynamic>(
        '${ApiConfig.dealsEndpoint}',
      );
      
      if (response.success && response.data != null) {
        final dealsData = response.data as List<dynamic>;
        final allDeals = dealsData
            .map((json) => Deal.fromJson(json as Map<String, dynamic>))
            .toList();
        
        // Simulate "missed" deals - active deals that user might have viewed
        final now = DateTime.now();
        final activeDeals = allDeals
            .where((deal) => deal.expiresAt.isAfter(now))
            .toList();
        
        // Take every 3rd deal as "missed" for demo purposes
        final missedDeals = <MissedDeal>[];
        for (int i = 2; i < activeDeals.length; i += 3) {
          final deal = activeDeals[i];
          final urgencyLevel = _calculateUrgencyLevel(deal);
          
          missedDeals.add(MissedDeal(
            deal: deal,
            viewedAt: now.subtract(Duration(hours: 2)), // Simulate viewed 2 hours ago
            viewCount: 3, // Simulate multiple views
            lastInteraction: now.subtract(Duration(minutes: 30)), // Simulate last interaction 30 min ago
            urgencyLevel: urgencyLevel,
            fomoMessage: _generateFOMOMessage(deal, urgencyLevel),
            urgencyScore: _calculateUrgencyScore(deal),
          ));
        }
        
        return missedDeals.take(8).toList(); // Limit for demo
      } else {
        print('Failed to fetch deals for missed simulation: ${response.error}');
        return [];
      }
    } catch (e) {
      print('Error fetching missed deals: $e');
      return [];
    }
  }
  
  /// Calculate urgency level based on deal properties
  static String _calculateUrgencyLevel(Deal deal) {
    final hoursLeft = deal.expiresAt.difference(DateTime.now()).inHours;
    if (hoursLeft <= 2) return 'critical';
    if (hoursLeft <= 6) return 'high';
    if (hoursLeft <= 24) return 'medium';
    return 'low';
  }
  
  /// Generate FOMO message based on deal and urgency
  static String _generateFOMOMessage(Deal deal, String urgencyLevel) {
    final hoursLeft = deal.expiresAt.difference(DateTime.now()).inHours;
    
    switch (urgencyLevel) {
      case 'critical':
        return 'EXPIRES IN ${hoursLeft}H! Don\'t miss out!';
      case 'high':
        return 'Only ${hoursLeft} hours left to save \$${deal.savingsAmount.toStringAsFixed(0)}!';
      case 'medium':
        return 'You viewed this ${hoursLeft}h ago - still deciding?';
      default:
        return 'You looked at this deal but haven\'t acted yet';
    }
  }
  
  /// Calculate urgency score (0-100)
  static double _calculateUrgencyScore(Deal deal) {
    final hoursLeft = deal.expiresAt.difference(DateTime.now()).inHours;
    final savings = deal.savingsAmount;
    
    // Higher score for less time and more savings
    final timeScore = (48 - hoursLeft).clamp(0, 48) / 48 * 50; // 50 points max for time
    final savingsScore = (savings * 2).clamp(0, 50); // 50 points max for savings
    
    return (timeScore + savingsScore).clamp(0, 100);
  }
  
  
  /// Get missed deals statistics calculated from current missed deals
  /// TEMPORARY: Until proper stats endpoint is implemented
  static Future<MissedDealStats?> getMissedDealsStats() async {
    try {
      final missedDeals = await getMissedDeals();
      
      if (missedDeals.isEmpty) {
        return MissedDealStats(
          totalMissed: 0,
          endingSoon: 0,
          highHesitation: 0,
          totalMissedSavings: 0.0,
          primaryFOMOMessage: "No missed deals - you're doing great!",
          secondaryFOMOMessage: "Keep being decisive with deals",
        );
      }
      
      final totalMissed = missedDeals.length;
      final endingSoon = missedDeals.where((deal) => deal.isEndingSoon).length;
      final highHesitation = missedDeals.where((deal) => deal.isHighHesitation).length;
      final totalMissedSavings = missedDeals
          .fold(0.0, (sum, deal) => sum + deal.deal.savingsAmount);
      
      return MissedDealStats(
        totalMissed: totalMissed,
        endingSoon: endingSoon,
        highHesitation: highHesitation,
        totalMissedSavings: totalMissedSavings,
        primaryFOMOMessage: endingSoon > 0
            ? "$endingSoon deals ending soon - act fast!"
            : "You have $totalMissed deals you've been considering",
        secondaryFOMOMessage: totalMissedSavings >= 30
            ? "That's \$${totalMissedSavings.toStringAsFixed(0)} in potential savings!"
            : "Make faster decisions to secure deals",
      );
    } catch (e) {
      print('Error calculating missed deals stats: $e');
      return null;
    }
  }
  
  /// Get deals ending soon (high FOMO)
  /// TEMPORARY: Filter from all missed deals
  static Future<List<MissedDeal>> getEndingSoonDeals() async {
    final allMissed = await getMissedDeals();
    return allMissed.where((deal) => deal.isEndingSoon).toList();
  }
  
  /// Get deals with high hesitation (multiple views)
  /// TEMPORARY: Filter from all missed deals
  static Future<List<MissedDeal>> getHesitatedDeals() async {
    final allMissed = await getMissedDeals();
    return allMissed.where((deal) => deal.viewCount >= 3).toList();
  }
  
  /// Check if a specific deal is in the missed list
  /// TEMPORARY: Check against simulated missed deals
  static Future<bool> isDealMissed(String dealId) async {
    try {
      final missedDeals = await getMissedDeals();
      return missedDeals.any((missed) => missed.deal.id == dealId);
    } catch (e) {
      print('Error checking if deal is missed: $e');
      return false;
    }
  }
  
  /// Remove a specific missed deal (user dismissed it)
  /// TEMPORARY: Returns true until backend implementation
  static Future<bool> dismissMissedDeal(String dealId) async {
    try {
      // TODO: Implement when backend endpoint is available
      print('Dismissed missed deal: $dealId');
      return true;
    } catch (e) {
      print('Error dismissing missed deal: $e');
      return false;
    }
  }
}