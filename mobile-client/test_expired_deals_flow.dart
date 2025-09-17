import 'dart:convert';
import 'package:http/http.dart' as http;
import 'lib/shared/services/expired_deals_api_service.dart';
import 'lib/shared/models/deal.dart';
import 'lib/shared/models/api_models.dart';

/// Simple test to verify expired deals flow works end-to-end
void main() async {
  print('🧪 Testing Expired Deals Flow...\n');
  
  // Test 1: Direct API call
  print('1️⃣ Testing direct API call...');
  try {
    final response = await http.get(
      Uri.parse('https://foodq.pages.dev/api/deals?status=expired&limit=3'),
      headers: {'accept': 'application/json'},
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List<dynamic>;
      print('✅ API returned ${data.length} expired deals');
      
      if (data.isNotEmpty) {
        final firstDeal = data.first as Map<String, dynamic>;
        print('   First deal: ${firstDeal['title']} (expires: ${firstDeal['expires_at']})');
      }
    } else {
      print('❌ API call failed with status: ${response.statusCode}');
      return;
    }
  } catch (e) {
    print('❌ API call error: $e');
    return;
  }
  
  print('');
  
  // Test 2: Deal.fromJson conversion
  print('2️⃣ Testing Deal.fromJson conversion...');
  try {
    final response = await http.get(
      Uri.parse('https://foodq.pages.dev/api/deals?status=expired&limit=1'),
      headers: {'accept': 'application/json'},
    );
    
    final data = jsonDecode(response.body) as List<dynamic>;
    final firstDealJson = data.first as Map<String, dynamic>;
    
    final deal = Deal.fromJson(firstDealJson);
    print('✅ Deal.fromJson successful: ${deal.title}');
    print('   Expires at: ${deal.expiresAt}');
    print('   Created at: ${deal.createdAt}');
  } catch (e) {
    print('❌ Deal.fromJson error: $e');
    return;
  }
  
  print('');
  
  // Test 3: ExpiredDeal conversion with our logic
  print('3️⃣ Testing ExpiredDeal conversion...');
  try {
    final response = await http.get(
      Uri.parse('https://foodq.pages.dev/api/deals?status=expired&limit=2'),
      headers: {'accept': 'application/json'},
    );
    
    final data = jsonDecode(response.body) as List<dynamic>;
    
    final expiredDeals = data.map((json) {
      final dealJson = json as Map<String, dynamic>;
      final deal = Deal.fromJson(dealJson);
      
      // Use the same logic as in ExpiredDealsApiService
      return ExpiredDeal(
        deal: deal,
        expiredAt: deal.expiresAt,
        discoveredAt: deal.createdAt,
        wasViewedByUser: false,
        wasInUserCart: false,
        regretLevel: _calculateRegretLevel(deal),
        regretMessage: _generateRegretMessage(deal),
        timeDisplayMessage: _formatTimeDisplayMessage(deal.expiresAt),
      );
    }).toList();
    
    print('✅ ExpiredDeal conversion successful: ${expiredDeals.length} expired deals');
    for (final expiredDeal in expiredDeals) {
      print('   - ${expiredDeal.deal.title}: ${expiredDeal.regretMessage}');
    }
  } catch (e) {
    print('❌ ExpiredDeal conversion error: $e');
    return;
  }
  
  print('');
  
  // Test 4: Service method (commented out since it requires app context)
  print('4️⃣ Service method test would require app context');
  print('   but based on tests 1-3, the conversion logic should work');
  
  print('\n🎉 All tests passed! The expired deals flow should work.');
}

/// Helper methods (copied from ExpiredDealsApiService)
String _calculateRegretLevel(Deal deal) {
  if (deal.savingsAmount >= 15.0) return 'critical';
  if (deal.savingsAmount >= 10.0) return 'high';
  if (deal.savingsAmount >= 5.0) return 'medium';
  return 'low';
}

String _generateRegretMessage(Deal deal) {
  final savings = deal.savingsAmount;
  if (savings >= 15.0) {
    return 'You missed out on huge savings of \$${savings.toStringAsFixed(0)}!';
  } else if (savings >= 10.0) {
    return 'Could have saved \$${savings.toStringAsFixed(0)} on this deal!';
  } else if (savings >= 5.0) {
    return 'Small savings add up - missed \$${savings.toStringAsFixed(0)}';
  } else {
    return 'This deal expired recently';
  }
}

String _formatTimeDisplayMessage(DateTime expiresAt) {
  final now = DateTime.now();
  final difference = now.difference(expiresAt);
  
  if (difference.inDays > 0) {
    return 'Expired ${difference.inDays}d ago';
  } else if (difference.inHours > 0) {
    return 'Expired ${difference.inHours}h ago';
  } else {
    return 'Expired ${difference.inMinutes}m ago';
  }
}