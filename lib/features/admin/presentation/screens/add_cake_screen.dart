import 'dart:io';

import 'package:denzels_cakes/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/services/admin_api_service_new.dart';
import '../../../../core/utils/cake_share.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/utils/category_utils.dart';
import '../../../../shared/theme/app_theme.dart';

class AddCakeScreen extends StatefulWidget {
  /// When set, the form edits this cake instead of creating one.
  final Map<String, dynamic>? cake;

  const AddCakeScreen({super.key, this.cake});

  @override
  State<AddCakeScreen> createState() => _AddCakeScreenState();
}

class _AddCakeScreenState extends State<AddCakeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _descriptionFrController = TextEditingController();
  final _basePriceController = TextEditingController();
  final _prepTimeController = TextEditingController(text: '1440');
  final _servingsController = TextEditingController(text: '8');
  final _picker = ImagePicker();

  final List<File> _selectedImages = [];
  final List<String> _existingImages = [];
  final List<Map<String, dynamic>> _sizes = [
    {'name': 'Small', 'multiplier': 1.0},
    {'name': 'Medium', 'multiplier': 1.5},
    {'name': 'Large', 'multiplier': 2.0},
  ];
  final List<String> _flavors = ['Vanilla'];

  static const _flavorChoices = [
    'Vanilla',
    'Chocolate',
    'Strawberry',
    'Red velvet',
    'Buttercream',
  ];

  bool _isLoading = false;
  bool _showAllCategories = false;
  bool _isAvailable = true;
  String? _selectedCategory;
  String? _categoryError;
  String? _targetAgeGroup;
  String? _targetGender;

  bool get _editing => widget.cake != null;
  int get _photoCount => _existingImages.length + _selectedImages.length;

  @override
  void initState() {
    super.initState();
    final cake = widget.cake;
    if (cake == null) return;
    _titleController.text = cake['title']?.toString() ?? '';
    _descriptionController.text = cake['description']?.toString() ?? '';
    _descriptionFrController.text = cake['descriptionFr']?.toString() ?? '';
    final price = cake['basePrice'];
    _basePriceController.text =
        price is num ? price.round().toString() : (price?.toString() ?? '');
    final prep = cake['prepTimeMinutes'];
    if (prep != null) _prepTimeController.text = prep.toString();
    final servings = cake['servingsEstimate'];
    if (servings != null) _servingsController.text = servings.toString();
    _isAvailable = cake['isAvailable'] != false;
    _targetAgeGroup = cake['targetAgeGroup']?.toString();
    _targetGender = cake['targetGender']?.toString();
    _existingImages.addAll(
      List<String>.from(cake['images'] ?? const <String>[]),
    );
    final flavors = cake['flavors'];
    if (flavors is List && flavors.isNotEmpty) {
      _flavors
        ..clear()
        ..addAll(flavors.map((flavor) => flavor.toString()));
    }
    final sizes = cake['sizes'];
    if (sizes is List && sizes.isNotEmpty) {
      _sizes
        ..clear()
        ..addAll(sizes.whereType<Map>().map((size) => {
              'name': size['name']?.toString() ?? 'Size',
              'multiplier': (size['multiplier'] as num?)?.toDouble() ?? 1,
            }));
    }
    _selectedCategory = _categoryFrom(cake['tags']);
    if (_selectedCategory != null &&
        !CategoryUtils.getHomePageCategories().contains(_selectedCategory)) {
      _showAllCategories = true;
    }
  }

  String? _categoryFrom(dynamic tags) {
    if (tags is! List) return null;
    final keys = CategoryUtils.getAllCategoryKeys();
    for (final tag in tags) {
      final text = tag.toString().toLowerCase();
      for (final key in keys) {
        if (text == key.toLowerCase() || text.contains(key.toLowerCase())) {
          return key;
        }
      }
    }
    return null;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _descriptionFrController.dispose();
    _basePriceController.dispose();
    _prepTimeController.dispose();
    _servingsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(_editing ? 'Edit cake' : 'New cake'),
        backgroundColor: AppTheme.surfaceColor,
        surfaceTintColor: Colors.transparent,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  _photos(),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _titleController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      hintText: 'Chocolate fudge',
                    ),
                    validator: (value) {
                      final text = value?.trim() ?? '';
                      if (text.length < 3) return 'Use at least 3 characters';
                      if (text.length > 100) return 'Use at most 100 characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _basePriceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Price',
                      prefixText: 'XAF ',
                    ),
                    validator: (value) {
                      final price = double.tryParse(value?.trim() ?? '');
                      if (price == null || price <= 0) return 'Enter a price';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descriptionController,
                    textCapitalization: TextCapitalization.sentences,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      alignLabelWithHint: true,
                      helperText: 'A sentence is enough',
                    ),
                    validator: (value) {
                      final text = value?.trim() ?? '';
                      if (text.length < 10) {
                        return 'Use at least 10 characters';
                      }
                      if (text.length > 1000) return 'Use at most 1000 characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Text('Category', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  _categoryChips(l10n),
                  if (_categoryError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        _categoryError!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  _moreDetails(l10n),
                ],
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isLoading ? null : _saveCake,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(_editing ? 'Save changes' : 'Save cake'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _photos() {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 112,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (final url in _existingImages)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      url,
                      width: 112,
                      height: 112,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox(
                        width: 112,
                        height: 112,
                        child: Icon(Icons.broken_image_outlined),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: IconButton.filledTonal(
                      visualDensity: VisualDensity.compact,
                      onPressed: () => setState(() => _existingImages.remove(url)),
                      icon: const Icon(Icons.close, size: 16),
                    ),
                  ),
                ],
              ),
            ),
          for (final image in _selectedImages)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      image,
                      width: 112,
                      height: 112,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: IconButton.filledTonal(
                      visualDensity: VisualDensity.compact,
                      onPressed: () => setState(() => _selectedImages.remove(image)),
                      icon: const Icon(Icons.close, size: 16),
                    ),
                  ),
                ],
              ),
            ),
          if (_photoCount < 5)
            InkWell(
              onTap: _pickImages,
              borderRadius: BorderRadius.circular(12),
              child: Ink(
                width: _photoCount == 0 ? null : 112,
                height: 112,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: scheme.outline),
                ),
                child: SizedBox(
                  width: _photoCount == 0 ? MediaQuery.sizeOf(context).width - 32 : 112,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo_outlined, color: scheme.primary),
                      const SizedBox(height: 6),
                      Text(
                        _photoCount == 0 ? 'Add photos' : 'Add',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _categoryChips(AppLocalizations l10n) {
    final categories = _showAllCategories
        ? CategoryUtils.getAllCategoriesForHomePage()
        : CategoryUtils.getHomePageCategories();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final category in categories)
              FilterChip(
                label: Text(CategoryUtils.getLocalizedCategory(category, l10n)),
                selected: _selectedCategory == category,
                showCheckmark: false,
                onSelected: (selected) {
                  setState(() {
                    _selectedCategory = selected ? category : null;
                    _categoryError = null;
                  });
                },
              ),
          ],
        ),
        TextButton(
          onPressed: () => setState(() => _showAllCategories = !_showAllCategories),
          child: Text(_showAllCategories ? 'Fewer categories' : 'More categories'),
        ),
      ],
    );
  }

  Widget _moreDetails(AppLocalizations l10n) {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      title: const Text('More details'),
      subtitle: const Text('Sizes, flavors, French, timing'),
      children: [
        TextFormField(
          controller: _descriptionFrController,
          textCapitalization: TextCapitalization.sentences,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Description in French',
            alignLabelWithHint: true,
          ),
          validator: (value) {
            final text = value?.trim() ?? '';
            if (text.isEmpty) return null;
            if (text.length < 10) {
              return 'Use at least 10 characters, or leave this empty';
            }
            if (text.length > 1000) return 'Use at most 1000 characters';
            return null;
          },
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _prepTimeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Ready in',
                  suffixText: 'min',
                ),
                validator: (value) {
                  final minutes = int.tryParse(value?.trim() ?? '');
                  if (minutes == null || minutes < 30) return 'At least 30';
                  if (minutes > 10080) return 'At most 7 days';
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _servingsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Servings'),
                validator: (value) {
                  final servings = int.tryParse(value?.trim() ?? '');
                  if (servings == null || servings < 1) return 'Required';
                  if (servings > 1000) return 'At most 1000';
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text('Flavors', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final flavor in {..._flavorChoices, ..._flavors})
              FilterChip(
                label: Text(flavor),
                selected: _flavors.contains(flavor),
                showCheckmark: false,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _flavors.add(flavor);
                    } else if (_flavors.length > 1) {
                      _flavors.remove(flavor);
                    }
                  });
                },
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text('Sizes', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 4),
        Text(
          'Medium is 1.5× the price, large is 2×.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 8),
        for (var i = 0; i < _sizes.length; i++)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(_sizes[i]['name'] as String),
            subtitle: Text('×${_sizes[i]['multiplier']}'),
            trailing: _sizes.length > 1
                ? IconButton(
                    onPressed: () => setState(() => _sizes.removeAt(i)),
                    icon: const Icon(Icons.close),
                  )
                : null,
          ),
        const SizedBox(height: 8),
        Text('Who it\'s for', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _audienceChip('Anyone', _targetAgeGroup == null && _targetGender == null, () {
              setState(() {
                _targetAgeGroup = null;
                _targetGender = null;
              });
            }),
            _audienceChip('Adults', _targetAgeGroup == 'adults' && _targetGender == null, () {
              setState(() {
                _targetAgeGroup = 'adults';
                _targetGender = null;
              });
            }),
            _audienceChip('Kids', _targetAgeGroup == 'kids' && _targetGender == null, () {
              setState(() {
                _targetAgeGroup = 'kids';
                _targetGender = null;
              });
            }),
            _audienceChip('Woman', _targetGender == 'female', () {
              setState(() {
                _targetAgeGroup = 'adults';
                _targetGender = 'female';
              });
            }),
            _audienceChip('Man', _targetGender == 'male', () {
              setState(() {
                _targetAgeGroup = 'adults';
                _targetGender = 'male';
              });
            }),
            _audienceChip('Girl', _targetGender == 'girl', () {
              setState(() {
                _targetAgeGroup = 'kids';
                _targetGender = 'girl';
              });
            }),
            _audienceChip('Boy', _targetGender == 'boy', () {
              setState(() {
                _targetAgeGroup = 'kids';
                _targetGender = 'boy';
              });
            }),
          ],
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Available for order'),
          value: _isAvailable,
          onChanged: (value) => setState(() => _isAvailable = value),
        ),
      ],
    );
  }

  Widget _audienceChip(String label, bool selected, VoidCallback onTap) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      onSelected: (_) => onTap(),
    );
  }

  Future<void> _pickImages() async {
    if (_photoCount >= 5) return;
    final images = await _picker.pickMultiImage();
    if (!mounted || images.isEmpty) return;
    setState(() {
      for (final image in images) {
        if (_photoCount >= 5) break;
        _selectedImages.add(File(image.path));
      }
    });
  }

  Future<void> _saveCake() async {
    final formOk = _formKey.currentState!.validate();
    if (_selectedCategory == null) {
      setState(() => _categoryError = 'Choose a category');
    }
    if (!formOk || _selectedCategory == null) return;

    if (_photoCount == 0) {
      _message('Add at least one photo');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final imageUrls = List<String>.from(_existingImages);
      for (final image in _selectedImages) {
        imageUrls.add(await AdminApiService.uploadImage(image));
      }

      final cakeData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        if (_descriptionFrController.text.trim().isNotEmpty)
          'descriptionFr': _descriptionFrController.text.trim()
        else if (_editing)
          'descriptionFr': null,
        'images': imageUrls,
        'basePrice': double.parse(_basePriceController.text.trim()),
        'sizes': _sizes,
        'flavors': _flavors,
        'tags': [_selectedCategory!.toLowerCase()],
        'prepTimeMinutes': int.parse(_prepTimeController.text.trim()),
        'servingsEstimate': int.parse(_servingsController.text.trim()),
        'isAvailable': _isAvailable,
        'targetAgeGroup': _targetAgeGroup,
        'targetGender': _targetGender,
      };

      if (_editing) {
        final cake = widget.cake!;
        final id = cake['_id']?.toString() ?? cake['id']?.toString() ?? '';
        await AdminApiService.updateCake(id, cakeData);
        if (!mounted) return;
        Navigator.pop(context, true);
        return;
      }

      final created = await AdminApiService.createCake(cakeData);
      if (!mounted) return;
      setState(() => _isLoading = false);
      final id = created['_id']?.toString() ?? created['id']?.toString();
      await CakeShare.show(
        context,
        title: _titleController.text.trim(),
        price: double.parse(_basePriceController.text.trim()),
        description: _descriptionController.text.trim(),
        id: id,
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      _message(ApiService.readableError(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _message(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }
}
