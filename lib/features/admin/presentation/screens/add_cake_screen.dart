import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../core/services/admin_api_service_new.dart';

class AddCakeScreen extends StatefulWidget {
  const AddCakeScreen({super.key});

  @override
  State<AddCakeScreen> createState() => _AddCakeScreenState();
}

class _AddCakeScreenState extends State<AddCakeScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Form controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _basePriceController = TextEditingController();
  final _prepTimeController = TextEditingController();
  final _servingsController = TextEditingController();

  // Form data
  // Removed unused _imageUrls field
  final List<File> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();
  final List<Map<String, dynamic>> _sizes = [
    {'name': 'Small', 'multiplier': 1.0},
    {'name': 'Medium', 'multiplier': 1.5},
    {'name': 'Large', 'multiplier': 2.0},
  ];
  final List<String> _flavors = ['Vanilla', 'Chocolate', 'Strawberry'];
  final List<String> _tags = [];
  bool _isAvailable = true;
  String? _targetGender; // New field for gender specification
  String? _selectedCategory; // Selected category

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _basePriceController.dispose();
    _prepTimeController.dispose();
    _servingsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Add New Cake'),
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveCake,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppTheme.accentColor),
                    ),
                  )
                : const Text(
                    'Save',
                    style: TextStyle(
                      color: AppTheme.accentColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildImageSection(),
                  const SizedBox(height: 20),
                  _buildBasicInfoSection(),
                  const SizedBox(height: 20),
                  _buildSizesSection(),
                  const SizedBox(height: 20),
                  _buildFlavorsSection(),
                  const SizedBox(height: 20),
                  _buildCategorySection(),
                  const SizedBox(height: 20),
                  _buildTagsSection(),
                  const SizedBox(height: 20),
                  _buildAvailabilitySection(),
                  const SizedBox(height: 100), // Extra padding for bottom button
                ],
              ),
            ),
            // Bottom Save Button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveCake,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Save Cake',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
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

  Widget _buildImageSection() {
    return Card(
      color: AppTheme.surfaceColor,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cake Images',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  ..._selectedImages.map(
                    (image) => Container(
                      width: 100,
                      height: 100,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: FileImage(image),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => _removeImage(image),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _pickImages,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppTheme.accentColor,
                          width: 2,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate,
                            color: AppTheme.accentColor,
                            size: 32,
                          ),
                          Text(
                            'Add Photo',
                            style: TextStyle(
                              color: AppTheme.accentColor,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add up to 5 high-quality images of your cake',
              style: TextStyle(
                color: AppTheme.textPrimary.withValues(alpha: 0.6),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      color: AppTheme.surfaceColor,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Basic Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Cake Title *',
                hintText: 'e.g., Chocolate Deluxe Cake',
                prefixIcon: Icon(Icons.cake, color: AppTheme.accentColor),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a cake title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description *',
                hintText: 'Describe your delicious cake...',
                prefixIcon:
                    Icon(Icons.description, color: AppTheme.accentColor),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _basePriceController,
              decoration: const InputDecoration(
                labelText: 'Base Price *',
                hintText: '0.00',
                prefixIcon:
                    Icon(Icons.attach_money, color: AppTheme.accentColor),
                prefixText: 'XAF ',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Required';
                }
                if (double.tryParse(value) == null) {
                  return 'Invalid price';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _prepTimeController,
              decoration: const InputDecoration(
                labelText: 'Prep Time (min) *',
                hintText: '60',
                prefixIcon: Icon(Icons.timer, color: AppTheme.accentColor),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Required';
                }
                if (int.tryParse(value) == null) {
                  return 'Invalid time';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _servingsController,
              decoration: const InputDecoration(
                labelText: 'Servings Estimate *',
                hintText: '8',
                prefixIcon: Icon(Icons.people, color: AppTheme.accentColor),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Required';
                }
                if (int.tryParse(value) == null) {
                  return 'Invalid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _targetGender,
              decoration: const InputDecoration(
                labelText: 'Target Gender (Optional)',
                hintText: 'Select target gender',
                prefixIcon: Icon(Icons.person, color: AppTheme.accentColor),
              ),
              items: const [
                DropdownMenuItem(value: null, child: Text('Not specified')),
                DropdownMenuItem(value: 'male', child: Text('Male')),
                DropdownMenuItem(value: 'female', child: Text('Female')),
              ],
              onChanged: (value) {
                setState(() {
                  _targetGender = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSizesSection() {
    return Card(
      color: AppTheme.surfaceColor,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Available Sizes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                TextButton.icon(
                  onPressed: _addSize,
                  icon: const Icon(Icons.add, color: AppTheme.accentColor),
                  label: const Text(
                    'Add Size',
                    style: TextStyle(color: AppTheme.accentColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._sizes.asMap().entries.map(
              (entry) {
                final index = entry.key;
                final size = entry.value;
                return _buildSizeItem(index, size);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSizeItem(int index, Map<String, dynamic> size) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              size['name'],
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'x${size['multiplier']}',
              style: TextStyle(
                color: AppTheme.textPrimary.withValues(alpha: 0.7),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              () {
                try {
                  final basePrice = double.parse(
                      _basePriceController.text.isEmpty
                          ? '0'
                          : _basePriceController.text);
                  return '${(basePrice * size['multiplier']).toStringAsFixed(0)} XAF';
                } catch (e) {
                  return '0 XAF';
                }
              }(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.accentColor,
              ),
            ),
          ),
          IconButton(
            onPressed: () => _removeSize(index),
            icon: const Icon(Icons.delete, color: Colors.red),
            iconSize: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildFlavorsSection() {
    return Card(
      color: AppTheme.surfaceColor,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Available Flavors',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                TextButton.icon(
                  onPressed: _addFlavor,
                  icon: const Icon(Icons.add, color: AppTheme.accentColor),
                  label: const Text(
                    'Add Flavor',
                    style: TextStyle(color: AppTheme.accentColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _flavors
                  .map(
                    (flavor) => Chip(
                      label: Text(flavor),
                      backgroundColor: AppTheme.backgroundColor,
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () => _removeFlavor(flavor),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection() {
    // Comprehensive list of cake categories covering all occasions
    // Using a Set to ensure uniqueness, then converting to sorted list
    final categoriesSet = {
      // Life Celebrations
      'Birthday',
      'Wedding',
      'Engagement',
      'Anniversary',
      'Bridal Shower',
      'Baby Shower',
      'Gender Reveal',
      
      // Religious & Faith Celebrations
      'Baptism',
      'Child Dedication',
      'First Communion',
      'Confirmation',
      'Bar Mitzvah',
      'Bat Mitzvah',
      'Religious Celebration',
      
      // Holidays & Seasonal
      'Christmas',
      'Easter',
      'New Year',
      'Thanksgiving',
      'Halloween',
      'Valentine\'s Day',
      'Mother\'s Day',
      'Father\'s Day',
      'Independence Day',
      'St. Patrick\'s Day',
      
      // Milestones & Achievements
      'Graduation',
      'Retirement',
      'Promotion',
      'Congratulations',
      'Achievement',
      
      // Other Occasions
      'Corporate Event',
      'Office Party',
      'Housewarming',
      'Welcome Party',
      'Farewell Party',
      'Sympathy',
      'Memorial',
      'Custom Design',
      'General Celebration',
    };
    
    // Convert to sorted list for consistent display
    final categories = categoriesSet.toList()..sort();

    return Card(
      color: AppTheme.surfaceColor,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Category *',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: (_selectedCategory != null && categories.contains(_selectedCategory))
                  ? _selectedCategory
                  : null,
              decoration: const InputDecoration(
                labelText: 'Select Category',
                hintText: 'Choose a category for this cake',
                prefixIcon: Icon(Icons.category, color: AppTheme.accentColor),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              items: categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                  // Automatically add category to tags if not already present
                  if (value != null && !_tags.contains(value.toLowerCase())) {
                    _tags.add(value.toLowerCase());
                  }
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a category';
                }
                return null;
              },
            ),
            if (_selectedCategory != null) ...[
              const SizedBox(height: 8),
              Text(
                'Selected: $_selectedCategory',
                style: TextStyle(
                  color: AppTheme.accentColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTagsSection() {
    return Card(
      color: AppTheme.surfaceColor,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tags (Optional)',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                TextButton.icon(
                  onPressed: _addTag,
                  icon: const Icon(Icons.add, color: AppTheme.accentColor),
                  label: const Text(
                    'Add Tag',
                    style: TextStyle(color: AppTheme.accentColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_tags.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _tags
                    .map(
                      (tag) => Chip(
                        label: Text(tag),
                        backgroundColor:
                            AppTheme.accentColor.withValues(alpha: 0.1),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: () => _removeTag(tag),
                      ),
                    )
                    .toList(),
              )
            else
              Text(
                'Add tags like "Birthday", "Wedding", "Gluten-Free" to help customers find your cake',
                style: TextStyle(
                  color: AppTheme.textPrimary.withValues(alpha: 0.6),
                  fontSize: 14,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailabilitySection() {
    return Card(
      color: AppTheme.surfaceColor,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Availability',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Available for Order'),
              subtitle: Text(
                _isAvailable
                    ? 'Customers can order this cake'
                    : 'This cake is currently unavailable',
                style: TextStyle(
                  color: AppTheme.textPrimary.withValues(alpha: 0.6),
                ),
              ),
              value: _isAvailable,
              activeThumbColor: AppTheme.accentColor,
              onChanged: (value) {
                setState(() {
                  _isAvailable = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  void _pickImages() async {
    if (_selectedImages.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 5 images allowed')),
      );
      return;
    }

    final List<XFile> images = await _picker.pickMultiImage();

    setState(() {
      for (var image in images) {
        if (_selectedImages.length < 5) {
          _selectedImages.add(File(image.path));
        }
      }
    });
  }

  void _removeImage(File image) {
    setState(() {
      _selectedImages.remove(image);
    });
  }

  void _addSize() {
    showDialog(
      context: context,
      builder: (context) {
        String name = '';
        double multiplier = 1.0;

        return AlertDialog(
          title: const Text('Add Size'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Size Name'),
                onChanged: (value) => name = value,
              ),
              const SizedBox(height: 16),
              TextField(
                decoration:
                    const InputDecoration(labelText: 'Price Multiplier'),
                keyboardType: TextInputType.number,
                onChanged: (value) =>
                    multiplier = double.tryParse(value) ?? 1.0,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (name.isNotEmpty) {
                  setState(() {
                    _sizes.add({'name': name, 'multiplier': multiplier});
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _removeSize(int index) {
    setState(() {
      _sizes.removeAt(index);
    });
  }

  void _addFlavor() {
    showDialog(
      context: context,
      builder: (context) {
        String flavor = '';

        return AlertDialog(
          title: const Text('Add Flavor'),
          content: TextField(
            decoration: const InputDecoration(labelText: 'Flavor Name'),
            onChanged: (value) => flavor = value,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (flavor.isNotEmpty && !_flavors.contains(flavor)) {
                  setState(() {
                    _flavors.add(flavor);
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _removeFlavor(String flavor) {
    setState(() {
      _flavors.remove(flavor);
    });
  }

  void _addTag() {
    showDialog(
      context: context,
      builder: (context) {
        String tag = '';

        return AlertDialog(
          title: const Text('Add Tag'),
          content: TextField(
            decoration: const InputDecoration(labelText: 'Tag Name'),
            onChanged: (value) => tag = value,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (tag.isNotEmpty && !_tags.contains(tag)) {
                  setState(() {
                    _tags.add(tag);
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  void _saveCake() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one image'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate required fields
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a cake title'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a cake description'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_sizes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one size'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_flavors.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one flavor'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedCategory == null || _selectedCategory!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a category'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Upload images first and get URLs
      List<String> imageUrls = [];
      List<String> failedUploads = [];

      for (int i = 0; i < _selectedImages.length; i++) {
        File imageFile = _selectedImages[i];
        try {
          final imageUrl = await AdminApiService.uploadImage(imageFile);
          imageUrls.add(imageUrl);
        } catch (e) {
// print('Failed to upload image ${i + 1}: $e');
          failedUploads.add('Image ${i + 1}');
          // Continue with other images, don't fail the entire operation
        }
      }

      // Check if any images were uploaded successfully
      if (imageUrls.isEmpty) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Failed to upload any images. Please check your connection and try again.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
        return;
      }

      // Show warning if some images failed
      if (failedUploads.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Warning: Failed to upload ${failedUploads.join(", ")}. Continuing with ${imageUrls.length} uploaded images.'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 4),
          ),
        );
      }

      // Validate and parse numeric fields
      double basePrice;
      int prepTime;
      int servings;

      try {
        basePrice = double.parse(_basePriceController.text.trim());
        if (basePrice <= 0) {
          throw const FormatException('Price must be greater than 0');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invalid base price: ${_basePriceController.text}'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      try {
        prepTime = int.parse(_prepTimeController.text.trim());
        if (prepTime <= 0) {
          throw const FormatException('Prep time must be greater than 0');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invalid prep time: ${_prepTimeController.text}'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      try {
        servings = int.parse(_servingsController.text.trim());
        if (servings <= 0) {
          throw const FormatException('Servings must be greater than 0');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invalid servings: ${_servingsController.text}'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Ensure category is in tags
      final tagsWithCategory = [..._tags];
      if (_selectedCategory != null && !tagsWithCategory.contains(_selectedCategory!.toLowerCase())) {
        tagsWithCategory.add(_selectedCategory!.toLowerCase());
      }

      final cakeData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'images': imageUrls,
        'basePrice': basePrice,
        'sizes': _sizes,
        'flavors': _flavors,
        'tags': tagsWithCategory,
        'prepTimeMinutes': prepTime,
        'servingsEstimate': servings,
        'isAvailable': _isAvailable,
        'targetGender': _targetGender,
      };

      await AdminApiService.createCake(cakeData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cake added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding cake: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
