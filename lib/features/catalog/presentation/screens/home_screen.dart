import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/loading_overlay.dart';
import '../../data/models/cake_model.dart';
import '../../data/repositories/cake_repository.dart';
import '../../../../core/services/favorites_service.dart';
import '../../../../core/services/cart_service.dart';
import '../../../../core/services/cache_service.dart';
import '../../../../core/services/api_service.dart';
import 'package:denzels_cakes/l10n/app_localizations.dart';
import '../../../../core/utils/category_utils.dart';
import '../../../search/data/models/filter_options.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final _searchController = TextEditingController();
  Timer? _searchDebounceTimer;

  // State management
  List<CakeStyle> _featuredCakes = [];
  List<CakeStyle> _allCakes = [];
  List<CakeStyle> _filteredCakes = [];
  List<String> _categories = [];
  bool _isLoading = true;
  bool _showingAllCakes = false;
  String? _errorMessage;
  bool _isSearching = false;

  // Favorites state
  Set<String> _favoriteIds = {};

  // Filter state
  String? _selectedCategory;
  FilterOptions _currentFilters = const FilterOptions();
  String? _selectedAgeGroup;
  String? _selectedGender;

  // Cart state
  int _cartItemCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadData();
    
    // Add search listener for real-time search
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    _searchDebounceTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Refresh cart count when app comes back to foreground
      _refreshCartCount();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh cart count when returning to this screen
    _refreshCartCount();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Clear any old categories cache to ensure we use the fixed 5 categories
      await CacheService.clearCache('categories');

      // Try to load from cache first
      final cachedCakes = await CacheService.getFeaturedCakes();
      final cachedFavorites = await CacheService.getFavorites();

      // Load cakes
      if (cachedCakes != null) {
        // Use cached data
        setState(() {
          _featuredCakes =
              cachedCakes.map((json) => CakeStyle.fromJson(json)).toList();
          _filteredCakes = _featuredCakes;
        });
      } else {
        // Load from API and cache
        try {
          final cakeResponse = await CakeRepository.getFeaturedCakes(limit: 10);
          setState(() {
            _featuredCakes = cakeResponse.data;
            _filteredCakes = cakeResponse.data;
          });
          // Cache the data
          await CacheService.setFeaturedCakes(
              cakeResponse.data.map((cake) => cake.toJson()).toList());
        } catch (e) {
          throw ApiException(ApiService.readableError(e));
        }
      }

      // Get all categories with core 5 first, then all others
      setState(() {
        _categories = CategoryUtils.getAllCategoriesForHomePage();
      });

      // Load favorites
      if (cachedFavorites != null) {
        setState(() {
          _favoriteIds = cachedFavorites.toSet();
        });
      } else {
        try {
          final favoriteIds = await FavoritesService.getFavoriteIds();
          setState(() {
            _favoriteIds = favoriteIds;
          });
          // Cache the data
          await CacheService.setFavorites(favoriteIds.toList());
        } catch (e) {
          // Continue without favorites if they fail to load
        }
      }

      // Load cart count (always fresh)
      try {
        await CartService.loadCart();
        final cartCount = CartService.getItemCount();
        setState(() {
          _cartItemCount = cartCount;
        });
      } catch (e) {
        // Continue without cart count if it fails to load
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = ApiService.readableError(e);
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshCartCount() async {
    try {
      await CartService.loadCart();
      final cartCount = CartService.getItemCount();
      final cart = CartService.currentCart;
// print('DEBUG: Refreshed cart count: $cartCount');
// print('DEBUG: Number of unique items: ${cart.items.length}');
// print('DEBUG: Cart items:');
      for (int i = 0; i < cart.items.length; i++) {
        // final item = cart.items[i];
// print('  Item ${i + 1}: ${cart.items[i].cakeTitle} (${cart.items[i].selectedSize}, ${cart.items[i].selectedFlavor}) x${cart.items[i].quantity}');
      }
      if (mounted) {
        setState(() {
          _cartItemCount = cartCount;
        });
      }
    } catch (e) {
// print('DEBUG: Error refreshing cart count: $e');
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
          final l10n = AppLocalizations.of(context)!;
          // Find cake name from available lists
          String cakeName = 'Cake';
          try {
            final cake = _featuredCakes.firstWhere((c) => c.id == cakeId);
            cakeName = cake.title;
          } catch (_) {
            try {
              final cake = _filteredCakes.firstWhere((c) => c.id == cakeId);
              cakeName = cake.title;
            } catch (_) {
              // Use default name
            }
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  isFavorite ? l10n.addedToFavorites : l10n.removedFromFavorites(cakeName)),
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
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.failedToUpdateFavorites),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  void _filterCakesByCategory(String? category) {
    setState(() {
      _selectedCategory = category;
      final source = _showingAllCakes ? _allCakes : _featuredCakes;
      if (category == null) {
        _filteredCakes = source;
      } else {
        _filteredCakes = source
            .where((cake) => cake.tags.any(
                (tag) => tag.toLowerCase().contains(category.toLowerCase())))
            .toList();
      }
    });
  }

  Future<void> _loadAllCakes() async {
    HapticFeedback.lightImpact();
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _selectedCategory = null;
      _isSearching = false;
      _searchController.clear();
    });

    try {
      final cakeResponse =
          await CakeRepository.getCakes(limit: 50, isAvailable: true);
      if (!mounted) return;
      setState(() {
        _allCakes = cakeResponse.data;
        _filteredCakes = cakeResponse.data;
        _showingAllCakes = true;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.failedToLoadCakes),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  void _showFeaturedCakes() {
    HapticFeedback.lightImpact();
    setState(() {
      _showingAllCakes = false;
      _selectedCategory = null;
      _filteredCakes = _featuredCakes;
    });
  }

  void _selectCategory(String category) {
    HapticFeedback.lightImpact();
    if (_selectedCategory == category) {
      // Deselect if already selected
      _filterCakesByCategory(null);
    } else {
      _filterCakesByCategory(category);
    }
  }

  Future<void> _refreshData() async {
    HapticFeedback.lightImpact();
    await _loadData();
  }

  void _onSearchChanged() {
    // Cancel previous timer
    _searchDebounceTimer?.cancel();
    
    // Start new timer for debounced search
    _searchDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      _performRealTimeSearch();
    });
  }

  void _updateFilters() {
    setState(() {
      _currentFilters = FilterOptions(
        targetAgeGroup: _selectedAgeGroup,
        targetGender: _selectedGender,
      );
    });
    // Trigger search with new filters if there's a search query
    if (_searchController.text.trim().isNotEmpty) {
      _performRealTimeSearch();
    }
  }

  Future<void> _performRealTimeSearch() async {
    final query = _searchController.text.trim();
    
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _showingAllCakes = false;
        _filteredCakes = _featuredCakes;
        _selectedCategory = null;
        _selectedAgeGroup = null;
        _selectedGender = null;
        _currentFilters = const FilterOptions();
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final searchResults = await CakeRepository.searchCakesWithFilters(
        query: query,
        filters: _currentFilters.hasActiveFilters ? _currentFilters : null,
        limit: 20,
      );
      setState(() {
        _filteredCakes = searchResults.data;
        _isSearching = false;
        _showingAllCakes = false;
        _selectedCategory = null; // Clear category filter when searching
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
        _filteredCakes = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return LoadingOverlay(
      isLoading: _isLoading,
      message: l10n.loadingCakes,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(l10n.denzelsCakeShop),
        ),
        body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          top: false,
          child: RefreshIndicator(
            onRefresh: _refreshData,
            color: AppTheme.accentColor,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // Modern Search Bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical:
                            12), // Increased vertical padding from 4 to 12
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: l10n.searchForCakes,
                              hintStyle:
                                  const TextStyle(color: AppTheme.textTertiary),
                              prefixIcon: Icon(
                                Icons.search,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                              suffixIcon: _isSearching
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: Padding(
                                        padding: EdgeInsets.all(12),
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                              AppTheme.accentColor),
                                        ),
                                      ),
                                    )
                                  : _searchController.text.isNotEmpty
                                      ? IconButton(
                                          icon: const Icon(Icons.clear,
                                              color: AppTheme.textSecondary),
                                          onPressed: () {
                                            setState(() {
                                              _searchController.clear();
                                              _selectedAgeGroup = null;
                                              _selectedGender = null;
                                              _currentFilters = const FilterOptions();
                                            });
                                          },
                                        )
                                      : null,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(28),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(28),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(28),
                                borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.transparent,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 16),
                            ),
                            onSubmitted: (query) {
                              if (query.isNotEmpty) {
                                Navigator.of(context)
                                    .pushNamed('/search', arguments: query);
                              }
                            },
                          ),
                        ),
                        // Filter Row
                        if (_searchController.text.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppTheme.primaryColor.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _selectedAgeGroup,
                                      hint: Row(
                                        children: const [
                                          Icon(Icons.group, size: 18, color: AppTheme.textSecondary),
                                          SizedBox(width: 8),
                                          Text('Age Group', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                                        ],
                                      ),
                                      items: const [
                                        DropdownMenuItem(value: null, child: Text('All')),
                                        DropdownMenuItem(value: 'adults', child: Text('Adults')),
                                        DropdownMenuItem(value: 'kids', child: Text('Kids')),
                                      ],
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedAgeGroup = value;
                                          _selectedGender = null; // Reset gender when age group changes
                                          _updateFilters();
                                        });
                                      },
                                      isExpanded: true,
                                      icon: const Icon(Icons.arrow_drop_down, color: AppTheme.accentColor),
                                    ),
                                  ),
                                ),
                              ),
                              if (_selectedAgeGroup != null) ...[
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: AppTheme.primaryColor.withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: _selectedGender,
                                        hint: const Row(
                                          children: [
                                            Icon(Icons.person, size: 18, color: AppTheme.textSecondary),
                                            SizedBox(width: 8),
                                            Text('Gender', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                                          ],
                                        ),
                                        items: _selectedAgeGroup == 'adults'
                                            ? const [
                                                DropdownMenuItem(value: null, child: Text('All')),
                                                DropdownMenuItem(value: 'male', child: Text('Male')),
                                                DropdownMenuItem(value: 'female', child: Text('Female')),
                                              ]
                                            : const [
                                                DropdownMenuItem(value: null, child: Text('All')),
                                                DropdownMenuItem(value: 'boy', child: Text('Boy')),
                                                DropdownMenuItem(value: 'girl', child: Text('Girl')),
                                              ],
                                        onChanged: (value) {
                                          setState(() {
                                            _selectedGender = value;
                                            _updateFilters();
                                          });
                                        },
                                        isExpanded: true,
                                        icon: const Icon(Icons.arrow_drop_down, color: AppTheme.accentColor),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                              if (_currentFilters.hasActiveFilters) ...[
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.clear, color: AppTheme.textSecondary),
                                  onPressed: () {
                                    setState(() {
                                      _selectedAgeGroup = null;
                                      _selectedGender = null;
                                      _currentFilters = const FilterOptions();
                                    });
                                    _performRealTimeSearch();
                                  },
                                  tooltip: 'Clear filters',
                                ),
                              ],
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // Custom Order Quick Action
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 12),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed('/custom-order');
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Theme.of(context).colorScheme.primaryContainer,
                              Theme.of(context).colorScheme.secondaryContainer,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.edit_note,
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                              size: 28,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.cake,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimaryContainer,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          l10n.placeCustomOrder,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onPrimaryContainer,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    l10n.orderCustomCake,
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimaryContainer,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward,
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Categories Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.categories,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 40,
                          child: _isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : Builder(
                                  builder: (context) {
                                    final visible =
                                        CategoryUtils.getHomePageCategories();
                                    if (_selectedCategory != null &&
                                        !visible.contains(_selectedCategory)) {
                                      visible.insert(0, _selectedCategory!);
                                    }
                                    return ListView.separated(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: visible.length + 1,
                                      separatorBuilder: (context, index) =>
                                          const SizedBox(width: 8),
                                      itemBuilder: (context, index) {
                                        if (index == visible.length) {
                                          return ActionChip(
                                            label: Text(l10n.seeAll),
                                            visualDensity:
                                                VisualDensity.compact,
                                            materialTapTargetSize:
                                                MaterialTapTargetSize
                                                    .shrinkWrap,
                                            onPressed: () =>
                                                _showAllCategories(l10n),
                                          );
                                        }
                                        final category = visible[index];
                                        return _buildCategoryChip(
                                          category,
                                          CategoryUtils.getLocalizedCategory(
                                            category,
                                            l10n,
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 8)),

                // Featured Cakes Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                width: 4,
                                height: 24,
                                decoration: BoxDecoration(
                                  gradient: AppTheme.primaryGradient,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Flexible(
                                child: Text(
                                  _selectedCategory != null
                                      ? l10n.cakesCategory(
                                          CategoryUtils.getLocalizedCategory(
                                              _selectedCategory!, l10n))
                                      : _showingAllCakes
                                          ? l10n.allCakes
                                          : l10n.featuredCakes,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.textPrimary,
                                      ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: AppTheme.accentGradient,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    AppTheme.accentColor.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: GestureDetector(
                            onTap: () {
                              if (_selectedCategory != null) {
                                _filterCakesByCategory(null);
                              } else if (_showingAllCakes) {
                                _showFeaturedCakes();
                              } else {
                                _loadAllCakes();
                              }
                            },
                            child: Text(
                              _selectedCategory != null
                                  ? l10n.showAll
                                  : _showingAllCakes
                                      ? l10n.featuredCakes
                                      : l10n.seeAll,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 8)),

                ..._buildCakeShelves(context, l10n),

                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).pushNamed('/custom-order');
        },
        backgroundColor: AppTheme.accentColor,
        foregroundColor: Colors.white,
        shape: const StadiumBorder(),
        icon: const Icon(Icons.edit_note),
        label: Text(
          l10n.placeCustomOrder,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        tooltip: l10n.placeCustomOrder,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: _buildBottomNavigationBar(context),
    ),
    );
  }

  Widget _buildCategoryChip(String categoryKey, String localizedTitle) {
    return FilterChip(
      label: Text(localizedTitle),
      selected: _selectedCategory == categoryKey,
      showCheckmark: false,
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      onSelected: (_) => _selectCategory(categoryKey),
    );
  }

  void _showAllCategories(AppLocalizations l10n) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) {
        final sheetHeight = MediaQuery.sizeOf(sheetContext).height * 0.7;
        return SizedBox(
          height: sheetHeight,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            children: [
              Text(
                l10n.categories,
                style: Theme.of(sheetContext).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final category in _categories)
                    FilterChip(
                      label: Text(
                        CategoryUtils.getLocalizedCategory(category, l10n),
                      ),
                      selected: _selectedCategory == category,
                      showCheckmark: false,
                      onSelected: (_) {
                        Navigator.of(sheetContext).pop();
                        _selectCategory(category);
                      },
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildCakeShelves(BuildContext context, AppLocalizations l10n) {
    if (_isLoading) {
      return const [
        SliverToBoxAdapter(
          child: SizedBox(
            height: 200,
            child: Center(
              child: CircularProgressIndicator(color: AppTheme.accentColor),
            ),
          ),
        ),
      ];
    }
    if (_errorMessage != null) {
      return [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(l10n.failedToLoadCakes),
                const SizedBox(height: 8),
                TextButton(onPressed: _loadData, child: Text(l10n.tryAgain)),
              ],
            ),
          ),
        ),
      ];
    }
    if (_filteredCakes.isEmpty) {
      return [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              l10n.noResultsFound,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ),
      ];
    }

    final groups = _groupCakesByCategory(_filteredCakes);
    final showHeadings = _selectedCategory == null && groups.length > 1;
    final shelves = <Widget>[];
    for (final group in groups) {
      final title = group.key == 'Other'
          ? l10n.optionOther
          : CategoryUtils.getLocalizedCategory(group.key, l10n);
      if (showHeadings) {
        shelves.add(
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Text(title, style: Theme.of(context).textTheme.titleMedium),
            ),
          ),
        );
      }
      shelves.add(
        SliverToBoxAdapter(
          child: SizedBox(
            height: 200,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: group.value.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                return SizedBox(
                  width: 168,
                  child: _buildShelfCard(context, group.value[index]),
                );
              },
            ),
          ),
        ),
      );
    }
    return shelves;
  }

  List<MapEntry<String, List<CakeStyle>>> _groupCakesByCategory(
    List<CakeStyle> cakes,
  ) {
    final order = CategoryUtils.getAllCategoriesForHomePage();
    final buckets = <String, List<CakeStyle>>{
      for (final key in order) key: <CakeStyle>[],
    };
    final other = <CakeStyle>[];
    for (final cake in cakes) {
      String? match;
      for (final key in order) {
        final needle = key.toLowerCase();
        if (cake.tags.any((tag) => tag.toLowerCase().contains(needle))) {
          match = key;
          break;
        }
      }
      if (match == null) {
        other.add(cake);
      } else {
        buckets[match]!.add(cake);
      }
    }
    final groups = <MapEntry<String, List<CakeStyle>>>[
      for (final key in order)
        if (buckets[key]!.isNotEmpty) MapEntry(key, buckets[key]!),
    ];
    if (other.isNotEmpty) groups.add(MapEntry('Other', other));
    return groups;
  }

  Widget _buildShelfCard(BuildContext context, CakeStyle cake) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.of(context).pushNamed('/cake/${cake.id}');
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(
              color: scheme.surfaceContainerHigh,
              child: cake.images.isNotEmpty
                  ? Image.network(
                      cake.images.first,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildPlaceholderImage(),
                    )
                  : _buildPlaceholderImage(),
            ),
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 88,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x00000000), Color(0xCC000000)],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 10,
              right: 10,
              bottom: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cake.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Colors.white,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${cake.basePrice.toInt()} XAF',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Material(
                color: scheme.surface.withValues(alpha: 0.92),
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _toggleFavorite(cake.id);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Icon(
                      _favoriteIds.contains(cake.id)
                          ? Icons.favorite
                          : Icons.favorite_border,
                      size: 18,
                      color: scheme.primary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      child: Icon(
        Icons.cake_outlined,
        color: Theme.of(context).colorScheme.primary,
        size: 48,
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return NavigationBar(
      selectedIndex: 0,
      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.home_outlined),
          selectedIcon: const Icon(Icons.home),
          label: l10n.home,
        ),
        NavigationDestination(
          icon: const Icon(Icons.school_outlined),
          selectedIcon: const Icon(Icons.school),
          label: l10n.training,
        ),
        NavigationDestination(
          icon: _cartItemCount > 0
              ? Badge(
                  label: Text(
                    _cartItemCount > 99 ? '99+' : '$_cartItemCount',
                  ),
                  child: const Icon(Icons.shopping_cart_outlined),
                )
              : const Icon(Icons.shopping_cart_outlined),
          selectedIcon: _cartItemCount > 0
              ? Badge(
                  label: Text(
                    _cartItemCount > 99 ? '99+' : '$_cartItemCount',
                  ),
                  child: const Icon(Icons.shopping_cart),
                )
              : const Icon(Icons.shopping_cart),
          label: l10n.cart,
        ),
        NavigationDestination(
          icon: const Icon(Icons.person_outline),
          selectedIcon: const Icon(Icons.person),
          label: l10n.profile,
        ),
      ],
      onDestinationSelected: (index) {
        switch (index) {
          case 0:
            break;
          case 1:
            Navigator.of(context).pushNamed('/training');
            break;
          case 2:
            Navigator.of(context).pushNamed('/cart');
            break;
          case 3:
            Navigator.of(context).pushNamed('/profile');
            break;
        }
      },
    );
  }

}
