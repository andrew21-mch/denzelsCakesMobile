import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/loading_overlay.dart';
import '../../../../core/services/favorites_service.dart';
import '../../../../l10n/app_localizations.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Map<String, dynamic>> _favorites = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final favorites = await FavoritesService.getUserFavorites();
// print('DEBUG: Loaded favorites: $favorites');
      setState(() {
        _favorites = favorites;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load favorites: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.myFavorites),
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFavorites,
          ),
          if (_favorites.isNotEmpty)
            PopupMenuButton<String>(
              onSelected: _handleMenuAction,
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'clear_all',
                  child: Row(
                    children: [
                      const Icon(Icons.clear_all, size: 20),
                      const SizedBox(width: 8),
                      Text(AppLocalizations.of(context)!.clearAll),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        message: AppLocalizations.of(context)!.loadingFavorites,
        child: _error != null
            ? _buildErrorState()
            : _favorites.isEmpty
                ? _buildEmptyState()
                : _buildFavoritesList(),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 80,
            color: AppTheme.errorColor,
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.failedToLoadFavorites,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            _error ?? AppLocalizations.of(context)!.unknownErrorOccurred,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textTertiary,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadFavorites,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentColor,
              foregroundColor: Colors.white,
            ),
            child: Text(AppLocalizations.of(context)!.retry),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.favorite_border,
            size: 80,
            color: AppTheme.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.noFavoritesYet,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.startAddingCakesToFavorites,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textTertiary,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () =>
                Navigator.of(context).pushReplacementNamed('/home'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentColor,
              foregroundColor: Colors.white,
            ),
            child: Text(AppLocalizations.of(context)!.browseCakes),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _favorites.length,
      itemBuilder: (context, index) {
        final cake = _favorites[index];
        return _buildFavoriteCard(cake, index);
      },
    );
  }

  Widget _buildFavoriteCard(Map<String, dynamic> favorite, int index) {
    // Safely extract cake data
    final cakeStyleId = favorite['cakeStyleId'];
    final cake = (cakeStyleId is Map<String, dynamic>)
        ? cakeStyleId
        : <String, dynamic>{};
    final cakeId =
        cake['_id']?.toString() ?? favorite['cakeStyleId']?.toString() ?? '';

    // If we don't have valid cake data, show a placeholder
    if (cake.isEmpty && cakeId.isEmpty) {
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          AppLocalizations.of(context)!.invalidFavoriteItem,
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
      );
    }

    return Dismissible(
      key: Key(cakeId.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppTheme.errorColor,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.delete,
              color: Colors.white,
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              AppLocalizations.of(context)!.remove,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      onDismissed: (direction) {
        _removeFavorite(index);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: AppTheme.cardShadowColor,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            final cakeId = cake['_id']?.toString() ?? '';
            if (cakeId.isNotEmpty) {
              Navigator.of(context).pushNamed('/cake/$cakeId');
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(AppLocalizations.of(context)!.unableToViewCakeDetails)),
              );
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Cake Image
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppTheme.accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.cake,
                    color: AppTheme.accentColor,
                    size: 40,
                  ),
                ),

                const SizedBox(width: 16),

                // Cake Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cake['title'] ?? AppLocalizations.of(context)!.unknownCake,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        cake['description'] ?? AppLocalizations.of(context)!.noDescriptionAvailable,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatRating(cake['averageRating']),
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color:
                                  AppTheme.accentColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              cake['category'] ?? 'Cake',
                              style: const TextStyle(
                                color: AppTheme.accentColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatPrice(cake['basePrice']),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppTheme.accentColor,
                            ),
                          ),
                          Text(
                            '${AppLocalizations.of(context)!.added} ${_getTimeAgo(context, favorite['createdAt'])}',
                            style: const TextStyle(
                              color: AppTheme.textTertiary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Actions
                Column(
                  children: [
                    IconButton(
                      onPressed: () => _removeFavorite(index),
                      icon: const Icon(
                        Icons.favorite,
                        color: Colors.red,
                      ),
                      tooltip: AppLocalizations.of(context)!.removeFromFavorites,
                    ),
                    IconButton(
                      onPressed: () => _addToCart(cake),
                      icon: const Icon(
                        Icons.add_shopping_cart,
                        color: AppTheme.accentColor,
                      ),
                      tooltip: AppLocalizations.of(context)!.addToCart,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleMenuAction(String action) {
    HapticFeedback.lightImpact();

    switch (action) {
      case 'clear_all':
        _showClearAllDialog();
        break;
    }
  }

  void _showClearAllDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.clearAllFavorites),
        content: Text(l10n.clearAllFavoritesConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();

              try {
                await FavoritesService.clearFavorites();
                setState(() {
                  _favorites.clear();
                });

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.allFavoritesCleared),
                      backgroundColor: AppTheme.errorColor,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.failedToClearFavorites),
                      backgroundColor: AppTheme.errorColor,
                    ),
                  );
                }
              }
            },
            child: Text(
              l10n.clearAll,
              style: const TextStyle(color: AppTheme.errorColor),
            ),
          ),
        ],
      ),
    );
  }

  void _removeFavorite(int index) async {
    HapticFeedback.lightImpact();
    final favorite = _favorites[index];
    final cake = favorite['cakeStyleId'] ?? {};
    final cakeId = cake['_id'] ?? '';
    final cakeName = cake['title'] ?? 'Unknown Cake';

    final l10n = AppLocalizations.of(context)!;
    // Optimistically remove from UI
    setState(() {
      _favorites.removeAt(index);
    });

    try {
      await FavoritesService.removeFromFavorites(cakeId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.removedFromFavorites(cakeName)),
            action: SnackBarAction(
              label: l10n.undo,
              onPressed: () async {
                try {
                  await FavoritesService.addToFavorites(cakeId);
                  _loadFavorites(); // Reload to get updated data
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.failedToUndoRemoval)),
                    );
                  }
                }
              },
            ),
          ),
        );
      }
    } catch (e) {
      // Revert UI change on error
      setState(() {
        _favorites.insert(index, favorite);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.failedToRemoveFromFavorites)),
        );
      }
    }
  }

  void _addToCart(Map<String, dynamic> cake) {
    final l10n = AppLocalizations.of(context)!;
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.addedToCart(cake['title'] ?? 'Cake')),
        backgroundColor: AppTheme.successColor,
        action: SnackBarAction(
          label: l10n.viewCart,
          textColor: Colors.white,
          onPressed: () {
            Navigator.of(context).pushNamed('/cart');
          },
        ),
      ),
    );
  }

  String _getTimeAgo(BuildContext context, dynamic dateValue) {
    try {
      DateTime? date;

      if (dateValue is String) {
        date = DateTime.tryParse(dateValue);
      } else if (dateValue is DateTime) {
        date = dateValue;
      }

      final l10n = AppLocalizations.of(context)!;
      if (date == null) {
        return l10n.recently;
      }

      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 0) {
        return '${difference.inDays}d ${l10n.ago}';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ${l10n.ago}';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ${l10n.ago}';
      } else {
        return l10n.justNow;
      }
    } catch (e) {
      return AppLocalizations.of(context)!.recently;
    }
  }

  String _formatRating(dynamic rating) {
    try {
      if (rating == null) return '0.0';
      if (rating is num) return rating.toStringAsFixed(1);
      if (rating is String) {
        final parsed = double.tryParse(rating);
        return parsed?.toStringAsFixed(1) ?? '0.0';
      }
      return '0.0';
    } catch (e) {
      return '0.0';
    }
  }

  String _formatPrice(dynamic price) {
    try {
      if (price == null) return '0 FCFA';

      int priceValue = 0;
      if (price is num) {
        priceValue = price.toInt();
      } else if (price is String) {
        priceValue = int.tryParse(price) ?? 0;
      }

      return '${priceValue.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} FCFA';
    } catch (e) {
      return '0 FCFA';
    }
  }
}
