import 'package:flutter/material.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../data/models/filter_options.dart';
import '../../../catalog/data/repositories/cake_repository.dart';

class FilterDialog extends StatefulWidget {
  final FilterOptions initialFilters;
  final Function(FilterOptions) onApplyFilters;

  const FilterDialog({
    super.key,
    required this.initialFilters,
    required this.onApplyFilters,
  });

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  late FilterOptions _currentFilters;
  RangeValues _priceRange = const RangeValues(0, 1000);
  double _minPrice = 0;
  double _maxPrice = 1000;
  List<String> _availableTags = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _currentFilters = widget.initialFilters;
    _loadFilterData();
  }

  Future<void> _loadFilterData() async {
    try {
      final priceRange = await CakeRepository.getPriceRange();
      final tags = await CakeRepository.getAvailableCategories();

      final minPrice = priceRange['min'] ?? 0.0;
      final maxPrice = priceRange['max'] ?? 1000.0;

      setState(() {
        _minPrice = minPrice;
        _maxPrice = maxPrice;
        _priceRange = RangeValues(minPrice, maxPrice);
        _availableTags = tags;
        _isLoading = false;

        // Set initial price range if filters have values
        if (_currentFilters.minPrice != null ||
            _currentFilters.maxPrice != null) {
          final filterMinPrice = _currentFilters.minPrice ?? minPrice;
          final filterMaxPrice = _currentFilters.maxPrice ?? maxPrice;

          // Ensure values are within bounds
          _priceRange = RangeValues(
            filterMinPrice.clamp(minPrice, maxPrice),
            filterMaxPrice.clamp(minPrice, maxPrice),
          );
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _updatePriceRange(RangeValues values) {
    setState(() {
      _priceRange = values;
      _currentFilters = _currentFilters.copyWith(
        minPrice: values.start,
        maxPrice: values.end,
      );
    });
  }

  void _toggleTag(String tag) {
    setState(() {
      final tags = _currentFilters.tags ?? [];
      if (tags.contains(tag)) {
        tags.remove(tag);
      } else {
        tags.add(tag);
      }
      _currentFilters = _currentFilters.copyWith(tags: tags);
    });
  }

  void _updateSorting(String? sortBy, String? sortOrder) {
    setState(() {
      _currentFilters = _currentFilters.copyWith(
        sortBy: sortBy,
        sortOrder: sortOrder,
      );
    });
  }

  void _clearAllFilters() {
    setState(() {
      _currentFilters = const FilterOptions();
      _priceRange = RangeValues(
        _priceRange.start,
        _priceRange.end,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter Results',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                ),
                TextButton(
                  onPressed: _clearAllFilters,
                  child: const Text(
                    'Clear All',
                    style: TextStyle(
                      color: AppTheme.accentColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Price Range
                        _buildPriceRangeSection(),
                        const SizedBox(height: 24),

                        // Sort Options
                        _buildSortSection(),
                        const SizedBox(height: 24),

                        // Tags/Categories
                        _buildTagsSection(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
          ),

          // Apply Button
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  widget.onApplyFilters(_currentFilters);
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Apply Filters',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRangeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Price Range (XAF)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
        ),
        const SizedBox(height: 12),
        RangeSlider(
          values: _priceRange,
          min: _minPrice,
          max: _maxPrice,
          divisions: 20,
          labels: RangeLabels(
            '${_priceRange.start.round()} XAF',
            '${_priceRange.end.round()} XAF',
          ),
          onChanged: _updatePriceRange,
          activeColor: AppTheme.accentColor,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${_priceRange.start.round()} XAF',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            Text(
              '${_priceRange.end.round()} XAF',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSortSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sort By',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildSortChip('createdAt', 'desc', 'Newest'),
            _buildSortChip('basePrice', 'asc', 'Price: Low to High'),
            _buildSortChip('basePrice', 'desc', 'Price: High to Low'),
          ],
        ),
      ],
    );
  }

  Widget _buildSortChip(String sortBy, String sortOrder, String label) {
    final isSelected = _currentFilters.sortBy == sortBy &&
        _currentFilters.sortOrder == sortOrder;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          _updateSorting(sortBy, sortOrder);
        } else {
          _updateSorting(null, null);
        }
      },
      selectedColor: AppTheme.accentColor.withValues(alpha: 0.2),
      checkmarkColor: AppTheme.accentColor,
    );
  }

  Widget _buildTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categories',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableTags.map((tag) {
            final isSelected = _currentFilters.tags?.contains(tag) ?? false;
            return FilterChip(
              label: Text(tag),
              selected: isSelected,
              onSelected: (_) => _toggleTag(tag),
              selectedColor: AppTheme.accentColor.withValues(alpha: 0.2),
              checkmarkColor: AppTheme.accentColor,
            );
          }).toList(),
        ),
      ],
    );
  }
}
