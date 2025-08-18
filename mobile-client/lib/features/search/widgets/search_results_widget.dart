import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/deal_card.dart';
import '../../../shared/widgets/business_card.dart';
import '../../../shared/models/deal.dart';
import '../../../shared/models/business.dart';
import '../models/search_result.dart';

class SearchResultsWidget extends StatelessWidget {
  final SearchResult searchResult;
  final Function(Deal) onDealTap;
  final Function(Business) onBusinessTap;

  const SearchResultsWidget({
    super.key,
    required this.searchResult,
    required this.onDealTap,
    required this.onBusinessTap,
  });

  @override
  Widget build(BuildContext context) {
    if (searchResult.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        // Results Summary
        if (searchResult.hasResults) _buildResultsSummary(),
        
        // Results List
        Expanded(
          child: _buildResultsList(),
        ),
      ],
    );
  }

  Widget _buildResultsSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search,
            color: AppTheme.primaryGreen,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              searchResult.summaryText,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (searchResult.query != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                searchResult.query!,
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.primaryGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResultsList() {
    // If we have both deals and businesses, show them mixed
    if (searchResult.deals.isNotEmpty && searchResult.businesses.isNotEmpty) {
      return _buildMixedResults();
    }
    
    // Show deals only
    if (searchResult.deals.isNotEmpty) {
      return _buildDealsOnlyList();
    }
    
    // Show businesses only
    if (searchResult.businesses.isNotEmpty) {
      return _buildBusinessesOnlyList();
    }

    return _buildEmptyState();
  }

  Widget _buildMixedResults() {
    final allResults = searchResult.allResults;
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: allResults.length,
      itemBuilder: (context, index) {
        final result = allResults[index];
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: result.when(
            deal: (deal) => DealCard(
              deal: deal,
              onTap: () => onDealTap(deal),
              showDistance: searchResult.searchLatitude != null,
            ),
            business: (business) => BusinessCard(
              business: business,
              onTap: () => onBusinessTap(business),
              showDistance: searchResult.searchLatitude != null,
            ),
          ),
        );
      },
    );
  }

  Widget _buildDealsOnlyList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: searchResult.deals.length,
      itemBuilder: (context, index) {
        final deal = searchResult.deals[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: DealCard(
            deal: deal,
            onTap: () => onDealTap(deal),
            showDistance: searchResult.searchLatitude != null,
          ),
        );
      },
    );
  }

  Widget _buildBusinessesOnlyList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: searchResult.businesses.length,
      itemBuilder: (context, index) {
        final business = searchResult.businesses[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: BusinessCard(
            business: business,
            onTap: () => onBusinessTap(business),
            showDistance: searchResult.searchLatitude != null,
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            searchResult.query != null
                ? 'No results found for "${searchResult.query}"'
                : 'No results found',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}