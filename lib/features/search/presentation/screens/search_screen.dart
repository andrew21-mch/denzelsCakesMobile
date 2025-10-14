import 'package:flutter/material.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../catalog/data/repositories/cake_repository.dart';
import '../../../catalog/data/models/cake_model.dart';
import '../../../../core/services/cache_service.dart';
import '../../../../core/services/favorites_service.dart';
import '../../data/models/filter_options.dart';
import '../widgets/filter_dialog.dart';

class SearchScreen extends StatefulWidget {
  final String? initialQuery;

  const SearchScreen({super.key, this.initialQuery});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();

  List<CakeStyle> _searchResults = [];
  final List<String> _recentSearches = [
    'Chocolate cake',
    'Birthday cake',
    'Wedding cake'
  ];
  List<String> _categories = [];
  String? _selectedCategory;
  bool _isSearching = false;
  bool _isLoadingCategories = true;

  // Favorites state
  Set<String> _favoriteIds = {};

  // Filter state
  FilterOptions _currentFilters = const FilterOptions();

  @override
  void initState() {
    super.initState();
    _loadData();
    if (widget.initialQuery != null) {
      _searchController.text = widget.initialQuery!;
      _performSearch(widget.initialQuery!);
    }
    _focusNode.requestFocus();

    // Add listener to update UI when search text changes
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      // Force use the exact same categories as home screen
      setState(() {
        _categories = [
          'Birthday',
          'Wedding',
          'Anniversary',
          'Baby Shower',
          'Faith Celebrations'
        ];
        _isLoadingCategories = false;
      });

      // Load favorites
      try {
        final favoriteIds = await FavoritesService.getFavoriteIds();
        setState(() {
          _favoriteIds = favoriteIds;
        });
      } catch (e) {
        // Continue without favorites if they fail to load
      }
    } catch (e) {
      // Use fallback categories if API fails - EXACTLY the same as home screen
      setState(() {
        _categories = [
          'Birthday',
          'Wedding',
          'Anniversary',
          'Baby Shower',
          'Faith Celebrations'
        ];
        _isLoadingCategories = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with back button
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new,
                          color: AppTheme.textPrimary),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const Expanded(
                      child: Text(
                        'Search Cakes',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    // Removed duplicate filter icon - kept only the one in search box
                    const SizedBox(width: 48), // Maintain spacing
                  ],
                ),
              ),

              // Search Box
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: AppTheme.shadowColor,
                        blurRadius: 15,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                      hintText: 'Search for delicious cakes...',
                      hintStyle: const TextStyle(color: AppTheme.textTertiary),
                      prefixIcon: const Icon(Icons.search,
                          color: AppTheme.accentColor, size: 24),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Filter button
                          Container(
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              gradient: _currentFilters.hasActiveFilters
                                  ? AppTheme.accentGradient
                                  : LinearGradient(
                                      colors: [
                                        Colors.grey[300]!,
                                        Colors.grey[300]!
                                      ],
                                    ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.filter_list,
                                color: _currentFilters.hasActiveFilters
                                    ? Colors.white
                                    : Colors.grey[600],
                                size: 20,
                              ),
                              onPressed: _showFilterDialog,
                            ),
                          ),
                          // Clear button (only when there's text)
                          if (_searchController.text.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.clear,
                                  color: AppTheme.textSecondary),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchResults.clear();
                                  _isSearching = false;
                                });
                              },
                            ),
                        ],
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                    ),
                    onSubmitted: _performSearch,
                    onChanged: (query) {
                      setState(() {
                        if (query.isEmpty) {
                          _searchResults.clear();
                          _isSearching = false;
                        }
                      });
                    },
                  ),
                ),
              ),

              // Categories Section
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 24,
                          decoration: BoxDecoration(
                            gradient: AppTheme.accentGradient,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Categories',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 100,
                      child: _isLoadingCategories
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: AppTheme.accentColor,
                              ),
                            )
                          : ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _categories.length,
                              itemBuilder: (context, index) {
                                final category = _categories[index];
                                return _buildCategoryCard(
                                  category,
                                  _getCategoryIcon(category),
                                  _getCategoryColor(category),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),

              // Search Results - Flexible to prevent overflow
              Expanded(
                child: _buildBody(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isSearching) {
      return _buildSearchResults();
    } else if (_searchController.text.isEmpty && _selectedCategory == null) {
      return _buildSearchSuggestions();
    } else {
      return _buildSearchResults();
    }
  }

  Widget _buildSearchSuggestions() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 20),
          Text(
            'Recent Searches',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: _recentSearches
                .map((search) => GestureDetector(
                      onTap: () {
                        _searchController.text = search;
                        _performSearch(search);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color:
                                  AppTheme.accentColor.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          search,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 20), // Add some bottom padding
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_isSearching) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentColor),
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return _buildNoResults();
    }

    return Column(
      children: [
        // Results header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_searchResults.length} results found',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              GestureDetector(
                onTap: _showSortDialog,
                child: Row(
                  children: [
                    const Icon(Icons.sort,
                        size: 16, color: AppTheme.accentColor),
                    const SizedBox(width: 4),
                    Text(
                      'Sort',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.accentColor,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Results grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              return _buildCakeCard(_searchResults[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNoResults() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight - 40, // Account for padding
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.search_off,
                  size: 80,
                  color: AppTheme.textTertiary,
                ),
                const SizedBox(height: 16),
                Text(
                  'No results found',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Try searching with different keywords',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textTertiary,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryCard(String title, IconData icon, Color color) {
    final isSelected = _selectedCategory == title;

    return GestureDetector(
      onTap: () => _selectCategory(title),
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isSelected ? Border.all(color: color, width: 2) : null,
          boxShadow: const [
            BoxShadow(
              color: AppTheme.shadowColor,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withValues(alpha: 0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCakeCard(CakeStyle cake) {
    final isFavorite = _favoriteIds.contains(cake.id);

    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed('/cake/${cake.id}');
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: AppTheme.shadowColor,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cake Image
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    child: cake.images.isNotEmpty
                        ? ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(16)),
                            child: Image.network(
                              cake.images.first,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(
                                  child: Icon(
                                    Icons.cake,
                                    size: 48,
                                    color: Colors.white,
                                  ),
                                );
                              },
                            ),
                          )
                        : const Center(
                            child: Icon(
                              Icons.cake,
                              size: 48,
                              color: Colors.white,
                            ),
                          ),
                  ),
                  // Favorite button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => _toggleFavorite(cake.id),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                              color: AppTheme.shadowColor,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color:
                              isFavorite ? Colors.red : AppTheme.textSecondary,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Cake Details
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8), // Reduced from 12 to 8
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min, // Added to prevent overflow
                  children: [
                    Text(
                      cake.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2), // Reduced from 4 to 2
                    Expanded(
                      // Wrap description in Expanded
                      child: Text(
                        cake.description.isNotEmpty
                            ? cake.description
                            : 'Delicious cake',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textTertiary,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 4), // Small spacing before price row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          // Wrap price text in Expanded
                          child: Text(
                            cake.sizes.isNotEmpty &&
                                    cake.sizes.first.basePriceOverride != null
                                ? '${cake.sizes.first.basePriceOverride} XAF'
                                : '${cake.basePrice} XAF',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  color: AppTheme.accentColor,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppTheme.accentColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.add_shopping_cart,
                            size: 16,
                            color: AppTheme.accentColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectCategory(String category) {
    setState(() {
      if (_selectedCategory == category) {
        _selectedCategory = null; // Deselect if already selected
      } else {
        _selectedCategory = category;
      }
    });

    // Perform search based on category
    if (_selectedCategory != null) {
      _performCategorySearch(_selectedCategory!);
    } else {
      // Clear search results if no category selected
      setState(() {
        _searchResults.clear();
        _isSearching = false;
      });
    }
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _isSearching = true;
      _selectedCategory = null; // Clear category selection when searching
    });

    // Add to recent searches
    if (!_recentSearches.contains(query)) {
      _recentSearches.insert(0, query);
      if (_recentSearches.length > 5) {
        _recentSearches.removeLast();
      }
    }

    try {
      final cakeResponse = await CakeRepository.searchCakesWithFilters(
        query: query,
        filters: _currentFilters.hasActiveFilters ? _currentFilters : null,
        limit: 20,
      );
      setState(() {
        _searchResults = cakeResponse.data;
        _isSearching = false;
      });
    } catch (e) {
// print('DEBUG: Error searching cakes: $e');
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
    }
  }

  Future<void> _performCategorySearch(String category) async {
    setState(() {
      _isSearching = true;
    });

    try {
      final cakeResponse =
          await CakeRepository.searchCakes(query: category, limit: 20);
      setState(() {
        _searchResults = cakeResponse.data
            .where((cake) => cake.tags.any(
                (tag) => tag.toLowerCase().contains(category.toLowerCase())))
            .toList();
        _isSearching = false;
      });
    } catch (e) {
// print('DEBUG: Error searching cakes by category: $e');
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
    }
  }

  Future<void> _toggleFavorite(String cakeId) async {
    try {
      final success = await FavoritesService.toggleFavorite(cakeId);
      if (success) {
        final favoriteIds = await FavoritesService.getFavoriteIds();
        setState(() {
          _favoriteIds = favoriteIds;
        });

        // Update cache with new favorites
        await CacheService.setFavorites(favoriteIds.toList());

        // Show feedback to user
        if (mounted) {
          final isFavorite = _favoriteIds.contains(cakeId);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  isFavorite ? 'Added to favorites' : 'Removed from favorites'),
              duration: const Duration(seconds: 2),
              backgroundColor:
                  isFavorite ? AppTheme.primaryColor : AppTheme.textSecondary,
            ),
          );
        }
      }
    } catch (e) {
// print('DEBUG: Error toggling favorite: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update favorites'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'birthday':
        return Icons.cake;
      case 'wedding':
        return Icons.favorite;
      case 'anniversary':
        return Icons.celebration;
      case 'baby shower':
        return Icons.child_care;
      case 'faith celebrations':
        return Icons.church;
      default:
        return Icons.cake;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'birthday':
        return Colors.pink;
      case 'wedding':
        return Colors.red;
      case 'anniversary':
        return Colors.blue;
      case 'baby shower':
        return Colors.green;
      case 'faith celebrations':
        return Colors.purple;
      default:
        return AppTheme.accentColor;
    }
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterDialog(
        initialFilters: _currentFilters,
        onApplyFilters: (filters) {
          setState(() {
            _currentFilters = filters;
          });
          // Re-perform search with new filters if there's a current query
          if (_searchController.text.isNotEmpty) {
            _performSearch(_searchController.text);
          }
        },
      ),
    );
  }

  void _showSortDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sort By',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Price: Low to High'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: const Text('Price: High to Low'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: const Text('Newest First'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: const Text('Most Popular'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
