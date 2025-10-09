import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../data/models/cake_model.dart';
import '../../data/repositories/cake_repository.dart';
import '../../../../core/services/favorites_service.dart';
import '../../../../core/services/cart_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final _searchController = TextEditingController();

  // State management
  List<CakeStyle> _featuredCakes = [];
  List<CakeStyle> _filteredCakes = [];
  List<String> _categories = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Favorites state
  Set<String> _favoriteIds = {};

  // Filter state
  String? _selectedCategory;

  // Cart state
  int _cartItemCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
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

      // Load cakes first
      try {
        final cakeResponse = await CakeRepository.getFeaturedCakes(limit: 10);
// print('DEBUG: Loaded ${cakeResponse.data.length} cakes');
        setState(() {
          _featuredCakes = cakeResponse.data;
          _filteredCakes = cakeResponse.data; // Initialize filtered cakes
        });
      } catch (e) {
// print('DEBUG: Error loading cakes: $e');
        throw Exception('Failed to load cakes: $e');
      }

      // Load categories separately
      try {
        final categories = await CakeRepository.getAvailableCategories();
// print('DEBUG: Loaded ${categories.length} categories');
        setState(() {
          _categories = categories;
        });
      } catch (e) {
// print('DEBUG: Error loading categories: $e');
        // Use default categories if API fails
        setState(() {
          _categories = ['Birthday', 'Wedding', 'Anniversary', 'Baby Shower', 'Faith Celebrations'];
        });
      }

      // Load favorites
      try {
        final favoriteIds = await FavoritesService.getFavoriteIds();
// print('DEBUG: Loaded ${favoriteIds.length} favorites');
        setState(() {
          _favoriteIds = favoriteIds;
        });
      } catch (e) {
// print('DEBUG: Error loading favorites: $e');
        // Continue without favorites if they fail to load
      }

      // Load cart count
      try {
        await CartService.loadCart();
        final cartCount = CartService.getItemCount();
// print('DEBUG: Loaded cart with ${cartCount} items');
        setState(() {
          _cartItemCount = cartCount;
        });
      } catch (e) {
// print('DEBUG: Error loading cart: $e');
        // Continue without cart count if it fails to load
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
// print('DEBUG: Error loading data: $e');
      setState(() {
        _errorMessage = e.toString();
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

  void _filterCakesByCategory(String? category) {
    setState(() {
      _selectedCategory = category;
      if (category == null) {
        _filteredCakes = _featuredCakes;
      } else {
        _filteredCakes = _featuredCakes
            .where((cake) => cake.tags.any(
                (tag) => tag.toLowerCase().contains(category.toLowerCase())))
            .toList();
      }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _refreshData,
            color: AppTheme.accentColor,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // Modern App Bar
                SliverAppBar(
                  expandedHeight: 100, // Reduced from 120
                  floating: true,
                  pinned: false,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      padding: const EdgeInsets.fromLTRB(
                          20, 10, 20, 16), // Reduced top padding from 20 to 10
                      child: Row(
                        children: [
                          // Logo
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: const [
                                BoxShadow(
                                  color: AppTheme.shadowColor,
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(4),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(11),
                              child: Image.asset(
                                'assets/images/logo2.jpeg',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      gradient: AppTheme.primaryGradient,
                                      borderRadius: BorderRadius.circular(11),
                                    ),
                                    child: const Icon(
                                      Icons.cake,
                                      size: 24,
                                      color: Colors.white,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Welcome Text
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Welcome to Denzel\'s! 🎂',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(
                                        color: AppTheme.textSecondary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                ShaderMask(
                                  shaderCallback: (bounds) => AppTheme
                                      .primaryGradient
                                      .createShader(bounds),
                                  child: Text(
                                    'Delicious cakes await!',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          height: 1.2,
                                        ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Action Buttons
                          Row(
                            children: [
                              _buildCartButton(),
                              const SizedBox(width: 8),
                              _buildActionButton(
                                Icons.person_outlined,
                                () =>
                                    Navigator.of(context).pushNamed('/profile'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Modern Search Bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical:
                            12), // Increased vertical padding from 4 to 12
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
                        decoration: InputDecoration(
                          hintText: 'Search for delicious cakes...',
                          hintStyle:
                              const TextStyle(color: AppTheme.textTertiary),
                          prefixIcon: const Icon(Icons.search,
                              color: AppTheme.accentColor, size: 24),
                          suffixIcon: Container(
                            margin: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: AppTheme.accentGradient,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.filter_list,
                                  color: Colors.white, size: 20),
                              onPressed: () {
                                // TODO: Implement filter
                              },
                            ),
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
                        onSubmitted: (query) {
                          if (query.isNotEmpty) {
                            Navigator.of(context)
                                .pushNamed('/search', arguments: query);
                          }
                        },
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
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 120,
                          child: _isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _categories.length,
                                  itemBuilder: (context, index) {
                                    final category = _categories[index];
                                    return _buildModernCategoryCard(
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
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 8)),

                // Featured Cakes Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
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
                            Text(
                              _selectedCategory != null
                                  ? '$_selectedCategory Cakes'
                                  : 'Featured Cakes',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary,
                                  ),
                            ),
                          ],
                        ),
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
                                _filterCakesByCategory(null); // Clear filter
                              } else {
                                // TODO: Navigate to all cakes
                              }
                            },
                            child: Text(
                              _selectedCategory != null
                                  ? 'Show All'
                                  : 'See All',
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

                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // Cake Grid with improved design
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  sliver: _isLoading
                      ? const SliverToBoxAdapter(
                          child: SizedBox(
                            height: 200,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppTheme.accentColor,
                              ),
                            ),
                          ),
                        )
                      : _errorMessage != null
                          ? SliverToBoxAdapter(
                              child: Container(
                                height: 120, // Further reduced from 140
                                margin: const EdgeInsets.symmetric(
                                    vertical: 8), // Reduced from 10
                                padding:
                                    const EdgeInsets.all(12), // Reduced from 14
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: AppTheme.shadowColor,
                                      blurRadius: 15,
                                      offset: Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize
                                        .min, // Ensure minimum space
                                    children: [
                                      Container(
                                        width: 40, // Reduced from 50
                                        height: 40, // Reduced from 50
                                        decoration: BoxDecoration(
                                          color: AppTheme.errorColor
                                              .withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(
                                              20), // Reduced from 25
                                        ),
                                        child: const Icon(
                                          Icons.error_outline,
                                          size: 24, // Reduced from 28
                                          color: AppTheme.errorColor,
                                        ),
                                      ),
                                      const SizedBox(
                                          height: 8), // Reduced from 12
                                      const Text(
                                        'Failed to load cakes',
                                        style: TextStyle(
                                          color: AppTheme.textPrimary,
                                          fontSize: 13, // Reduced from 14
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(
                                          height: 4), // Reduced from 6
                                      Container(
                                        height: 32, // Fixed height for button
                                        decoration: BoxDecoration(
                                          gradient: AppTheme.primaryGradient,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: ElevatedButton(
                                          onPressed: _loadData,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.transparent,
                                            shadowColor: Colors.transparent,
                                            minimumSize: const Size(60, 32),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16),
                                          ),
                                          child: const Text(
                                            'Retry',
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          : SliverGrid(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.85,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 20,
                              ),
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  return _buildModernCakeCard(
                                      context, _filteredCakes[index]);
                                },
                                childCount: _filteredCakes.length,
                              ),
                            ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildActionButton(IconData icon, VoidCallback onPressed) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: AppTheme.shadowColor,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: AppTheme.textPrimary, size: 22),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildModernCategoryCard(String title, IconData icon, Color color) {
    final isSelected = _selectedCategory == title;

    return GestureDetector(
      onTap: () => _selectCategory(title),
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? Border.all(color: color, width: 2) : null,
          boxShadow: const [
            BoxShadow(
              color: AppTheme.shadowColor,
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withValues(alpha: 0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernCakeCard(BuildContext context, CakeStyle cake) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.of(context).pushNamed('/cake/${cake.id}');
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: AppTheme.shadowColor,
              blurRadius: 15,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cake Image with gradient overlay
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      gradient: AppTheme.primaryGradient,
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      child: cake.images.isNotEmpty
                          ? Image.network(
                              cake.images.first,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  _buildPlaceholderImage(),
                            )
                          : _buildPlaceholderImage(),
                    ),
                  ),
                  // Favorite button
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: const [
                          BoxShadow(
                            color: AppTheme.shadowColor,
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(
                          _favoriteIds.contains(cake.id)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: AppTheme.accentColor,
                          size: 20,
                        ),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          _toggleFavorite(cake.id);
                        },
                      ),
                    ),
                  ),
                  // Price tag
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: AppTheme.accentGradient,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.accentColor.withValues(alpha: 0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        '${cake.basePrice.toInt()} XAF',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
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
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cake.title,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Expanded(
                            child: Text(
                              cake.description,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppTheme.textSecondary,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Add to cart button
                    Container(
                      width: double.infinity,
                      height: 28,
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: TextButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          // Navigate to cake detail page to select size and flavor
                          Navigator.of(context)
                              .pushNamed(
                            '/cake/${cake.id}',
                          )
                              .then((_) {
                            // Refresh cart count when returning from detail page
                            _refreshCartCount();
                          });
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Add to Cart',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
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

  Widget _buildPlaceholderImage() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: const Icon(
        Icons.cake,
        color: Colors.white,
        size: 40,
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowColor,
            blurRadius: 20,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white.withAlpha(179),
          currentIndex: 0,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.school),
              label: 'Training',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              label: 'Cart',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],        onTap: (index) {
          switch (index) {
            case 0:
              // Already on home
              break;
            case 1:
              Navigator.of(context).pushNamed('/search');
              break;
            case 2:
              Navigator.of(context).pushNamed('/training');
              break;
            case 3:
              Navigator.of(context).pushNamed('/cart');
              break;
            case 4:
              Navigator.of(context).pushNamed('/profile');
              break;
          }
        },
        ),
      ),
    );
  }

  // Helper methods for category icons and colors
  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'birthday':
        return Icons.cake;
      case 'wedding':
        return Icons.favorite;
      case 'anniversary':
        return Icons.celebration;
      case 'baby shower':
        return Icons.child_friendly;
      case 'faith celebrations':
        return Icons.church; // For Christian events like communion, baptism, etc.
      case 'religious events':
        return Icons.church; // For backward compatibility
      case 'celebrations':
        return Icons.church; // For backward compatibility
      case 'custom':
        return Icons.palette;
      case 'cupcakes':
        return Icons.bakery_dining;
      case 'seasonal':
        return Icons.celebration;
      default:
        return Icons.cake;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'birthday':
        return AppTheme.accentColor; // Steel blue
      case 'wedding':
        return AppTheme.goldenBrown; // Dark goldenrod
      case 'anniversary':
        return AppTheme.warmGray; // Slate gray
      case 'baby shower':
        return Colors.pink; // Soft pink for baby shower
      case 'faith celebrations':
        return Colors.deepPurple; // For Christian celebrations
      case 'religious events':
        return Colors.deepPurple; // For backward compatibility
      case 'celebrations':
        return Colors.deepPurple; // For backward compatibility
      case 'custom':
        return AppTheme.secondaryColor; // Chocolate orange
      case 'cupcakes':
        return AppTheme.successColor; // Forest green
      case 'seasonal':
        return AppTheme.warningColor; // Peru (warm brown)
      default:
        return AppTheme.accentColor;
    }
  }

  Widget _buildCartButton() {
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed('/cart'),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: AppTheme.shadowColor,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            const Center(
              child: Icon(
                Icons.shopping_cart_outlined,
                color: AppTheme.textPrimary,
                size: 22,
              ),
            ),
            if (_cartItemCount > 0)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: AppTheme.accentColor,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 14,
                    minHeight: 14,
                  ),
                  child: Text(
                    _cartItemCount > 99 ? '99+' : _cartItemCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
