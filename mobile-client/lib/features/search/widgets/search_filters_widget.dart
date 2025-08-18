import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../models/search_filters.dart';

class SearchFiltersWidget extends StatefulWidget {
  final SearchFilters filters;
  final Function(SearchFilters) onFiltersChanged;

  const SearchFiltersWidget({
    super.key,
    required this.filters,
    required this.onFiltersChanged,
  });

  @override
  State<SearchFiltersWidget> createState() => _SearchFiltersWidgetState();
}

class _SearchFiltersWidgetState extends State<SearchFiltersWidget> {
  late SearchFilters _currentFilters;

  @override
  void initState() {
    super.initState();
    _currentFilters = widget.filters;
  }

  void _updateFilters(SearchFilters newFilters) {
    setState(() {
      _currentFilters = newFilters;
    });
    widget.onFiltersChanged(newFilters);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Filters',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_currentFilters.hasActiveFilters)
              TextButton(
                onPressed: () => _updateFilters(const SearchFilters()),
                child: const Text('Clear All'),
              ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Sort By
        _buildSortBySection(),
        const SizedBox(height: 16),
        
        // Price Range
        _buildPriceRangeSection(),
        const SizedBox(height: 16),
        
        // Distance
        _buildDistanceSection(),
        const SizedBox(height: 16),
        
        // Dietary Preferences
        _buildDietaryPreferencesSection(),
        const SizedBox(height: 16),
        
        // Special Filters
        _buildSpecialFiltersSection(),
      ],
    );
  }

  Widget _buildSortBySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sort By',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: SearchSortBy.values.map((sortBy) {
            final isSelected = _currentFilters.sortBy == sortBy;
            return FilterChip(
              label: Text(sortBy.displayName),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  _updateFilters(_currentFilters.copyWith(sortBy: sortBy));
                }
              },
              selectedColor: AppTheme.primaryGreen.withOpacity(0.2),
              checkmarkColor: AppTheme.primaryGreen,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPriceRangeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Price Range',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'Min Price (\$)',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final price = double.tryParse(value);
                  _updateFilters(_currentFilters.copyWith(minPrice: price));
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'Max Price (\$)',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final price = double.tryParse(value);
                  _updateFilters(_currentFilters.copyWith(maxPrice: price));
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDistanceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Distance',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (_currentFilters.maxDistance != null)
              Text(
                '${_currentFilters.maxDistance!.toStringAsFixed(1)} km',
                style: TextStyle(
                  color: AppTheme.primaryGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Slider(
          value: _currentFilters.maxDistance ?? 10.0,
          min: 1.0,
          max: 50.0,
          divisions: 49,
          activeColor: AppTheme.primaryGreen,
          onChanged: (value) {
            _updateFilters(_currentFilters.copyWith(maxDistance: value));
          },
        ),
      ],
    );
  }

  Widget _buildDietaryPreferencesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Dietary Preferences',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            FilterChip(
              label: const Text('Vegetarian'),
              selected: _currentFilters.isVegetarian,
              onSelected: (selected) {
                _updateFilters(_currentFilters.copyWith(isVegetarian: selected));
              },
              selectedColor: AppTheme.primaryGreen.withOpacity(0.2),
              checkmarkColor: AppTheme.primaryGreen,
            ),
            FilterChip(
              label: const Text('Vegan'),
              selected: _currentFilters.isVegan,
              onSelected: (selected) {
                _updateFilters(_currentFilters.copyWith(isVegan: selected));
              },
              selectedColor: AppTheme.primaryGreen.withOpacity(0.2),
              checkmarkColor: AppTheme.primaryGreen,
            ),
            FilterChip(
              label: const Text('Gluten-Free'),
              selected: _currentFilters.isGlutenFree,
              onSelected: (selected) {
                _updateFilters(_currentFilters.copyWith(isGlutenFree: selected));
              },
              selectedColor: AppTheme.primaryGreen.withOpacity(0.2),
              checkmarkColor: AppTheme.primaryGreen,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSpecialFiltersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Special Offers',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            FilterChip(
              label: const Text('Expiring Soon'),
              selected: _currentFilters.isExpiringSoon,
              onSelected: (selected) {
                _updateFilters(_currentFilters.copyWith(isExpiringSoon: selected));
              },
              selectedColor: AppTheme.accentOrange.withOpacity(0.2),
              checkmarkColor: AppTheme.accentOrange,
            ),
            FilterChip(
              label: const Text('Almost Sold Out'),
              selected: _currentFilters.isAlmostSoldOut,
              onSelected: (selected) {
                _updateFilters(_currentFilters.copyWith(isAlmostSoldOut: selected));
              },
              selectedColor: Colors.red.withOpacity(0.2),
              checkmarkColor: Colors.red,
            ),
          ],
        ),
      ],
    );
  }
}