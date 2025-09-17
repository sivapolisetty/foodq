import 'package:flutter/material.dart';
import '../../../shared/services/expired_deals_api_service.dart';
import '../../../shared/models/api_models.dart';
import '../../../core/config/api_config.dart';

/// Test page to debug expired deals API calls
/// This will help identify if expired deals are being fetched correctly
class ExpiredDealsTestPage extends StatefulWidget {
  const ExpiredDealsTestPage({Key? key}) : super(key: key);

  @override
  State<ExpiredDealsTestPage> createState() => _ExpiredDealsTestPageState();
}

class _ExpiredDealsTestPageState extends State<ExpiredDealsTestPage> {
  List<ExpiredDeal> _expiredDeals = [];
  ExpiredDealStats? _stats;
  bool _isLoading = false;
  String? _error;
  String _debugLog = '';

  @override
  void initState() {
    super.initState();
    _addToLog('🚀 EXPIRED_TEST: ExpiredDealsTestPage initialized');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _testExpiredDealsAPI();
    });
  }

  void _addToLog(String message) {
    final timestamp = DateTime.now().toString().substring(11, 19);
    setState(() {
      _debugLog += '[$timestamp] $message\n';
    });
    print(message);
  }

  Future<void> _testExpiredDealsAPI() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _debugLog = '';
    });

    _addToLog('🔧 EXPIRED_TEST: Starting API test');
    _addToLog('🔧 EXPIRED_TEST: API Base URL: ${ApiConfig.baseUrl}');
    _addToLog('🔧 EXPIRED_TEST: Expired Deals URL: ${ApiConfig.userExpiredDealsUrl}');

    try {
      _addToLog('📡 EXPIRED_TEST: Calling getExpiredDeals()');
      final deals = await ExpiredDealsApiService.getExpiredDeals();
      _addToLog('✅ EXPIRED_TEST: Received ${deals.length} expired deals');

      _addToLog('📊 EXPIRED_TEST: Calling getExpiredDealsStats()');
      final stats = await ExpiredDealsApiService.getExpiredDealsStats();
      _addToLog('✅ EXPIRED_TEST: Received stats: ${stats?.totalExpired ?? 0} total expired');

      setState(() {
        _expiredDeals = deals;
        _stats = stats;
        _isLoading = false;
      });

      _addToLog('🎉 EXPIRED_TEST: API test completed successfully');

    } catch (e, stackTrace) {
      _addToLog('❌ EXPIRED_TEST: API test failed: $e');
      _addToLog('📚 EXPIRED_TEST: Stack trace: ${stackTrace.toString().substring(0, 200)}...');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expired Deals API Test'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _testExpiredDealsAPI,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // API Configuration Info
            _buildAPIConfigSection(),
            const SizedBox(height: 16),
            
            // Test Results
            _buildTestResultsSection(),
            const SizedBox(height: 16),
            
            // Debug Log
            _buildDebugLogSection(),
            const SizedBox(height: 16),
            
            // Expired Deals List
            if (_expiredDeals.isNotEmpty) _buildExpiredDealsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildAPIConfigSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'API Configuration',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 8),
            Text('Base URL: ${ApiConfig.baseUrl}'),
            Text('Expired Deals Endpoint: /api/user/expired-deals'),
            Text('Stats Endpoint: /api/user/expired-deals/stats'),
            Text('Environment: ${ApiConfig.isDevelopment ? 'Development' : 'Production'}'),
          ],
        ),
      ),
    );
  }

  Widget _buildTestResultsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Test Results',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 8),
            
            if (_isLoading)
              const Row(
                children: [
                  CircularProgressIndicator(strokeWidth: 2),
                  SizedBox(width: 12),
                  Text('Testing API endpoints...'),
                ],
              )
            else if (_error != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Error:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red[800],
                      ),
                    ),
                    Text(
                      _error!,
                      style: TextStyle(color: Colors.red[700]),
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Success!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green[800],
                      ),
                    ),
                    Text('Expired Deals: ${_expiredDeals.length}'),
                    Text('Total Expired (stats): ${_stats?.totalExpired ?? 'N/A'}'),
                    Text('Recently Expired: ${_stats?.recentlyExpired ?? 'N/A'}'),
                    Text('Total Savings Missed: \$${_stats?.totalExpiredSavings?.toStringAsFixed(2) ?? 'N/A'}'),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDebugLogSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Debug Log',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              height: 200,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: SingleChildScrollView(
                child: Text(
                  _debugLog.isEmpty ? 'No debug information yet...' : _debugLog,
                  style: TextStyle(
                    fontFamily: 'Courier',
                    fontSize: 12,
                    color: Colors.grey[800],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpiredDealsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Expired Deals (${_expiredDeals.length})',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 12),
            
            ...(_expiredDeals.take(5).map((deal) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    deal.deal.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  Text('Regret Level: ${deal.regretLevel}'),
                  Text('Regret Message: ${deal.regretMessage}'),
                  Text('Expired: ${deal.timeDisplayMessage}'),
                  Text('Was Viewed: ${deal.wasViewedByUser}'),
                  Text('Was in Cart: ${deal.wasInUserCart}'),
                ],
              ),
            )).toList()),
            
            if (_expiredDeals.length > 5)
              Text('... and ${_expiredDeals.length - 5} more deals'),
          ],
        ),
      ),
    );
  }
}