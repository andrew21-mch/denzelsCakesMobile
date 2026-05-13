import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../core/services/admin_api_service_new.dart';
import '../../../../core/utils/category_utils.dart';
import 'package:denzels_cakes/l10n/app_localizations.dart';

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
  String? _targetAgeGroup; // Age group: adults or kids
  String? _targetGender; // Gender: male/female for adults, boy/girl for kids
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
        title: const Text(
          'Add New Cake',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
        shadowColor: AppTheme.shadowColor,
        surfaceTintColor: Colors.transparent,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _isLoading
                ? const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppTheme.accentColor),
                      ),
                    ),
                  )
                : TextButton(
                    onPressed: _saveCake,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: AppTheme.shadowColor,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Text(
                        'Save',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppTheme.accentGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: AppTheme.shadowColor,
                          blurRadius: 12,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveCake,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
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
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
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
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: AppTheme.shadowColor,
            blurRadius: 15,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.photo_library,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Cake Images',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  ..._selectedImages.map(
                    (image) => Container(
                      width: 120,
                      height: 120,
                      margin: const EdgeInsets.only(right: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: AppTheme.shadowColor,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          children: [
                            Image.file(
                              image,
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: GestureDetector(
                                onTap: () => _removeImage(image),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withValues(alpha: 0.9),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.2),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _pickImages,
                    child: Container(
                      width: 120,
                      height: 120,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppTheme.paleBlue,
                            AppTheme.lightBlue,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppTheme.accentColor,
                          width: 2,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: AppTheme.shadowColor,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_rounded,
                            color: AppTheme.accentColor,
                            size: 36,
                          ),
                          SizedBox(height: 6),
                          Flexible(
                            child: Text(
                              'Add Photo',
                              style: TextStyle(
                                color: AppTheme.accentColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.paleBlue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppTheme.accentColor,
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Add up to 5 high-quality images of your cake',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: AppTheme.shadowColor,
            blurRadius: 15,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.info_outline,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Basic Information',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Cake Title *',
                hintText: 'e.g., Chocolate Deluxe Cake',
                prefixIcon: Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.paleBlue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.cake,
                    color: AppTheme.accentColor,
                    size: 20,
                  ),
                ),
                filled: true,
                fillColor: AppTheme.surfaceColor,
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
              decoration: InputDecoration(
                labelText: 'Description *',
                hintText: 'Describe your delicious cake...',
                prefixIcon: Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.paleBlue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.description, color: AppTheme.accentColor, size: 20),
                ),
                filled: true,
                fillColor: AppTheme.surfaceColor,
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
              decoration: InputDecoration(
                labelText: 'Base Price *',
                hintText: '0.00',
                prefixIcon: Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.paleBlue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.attach_money, color: AppTheme.accentColor, size: 20),
                ),
                prefixText: 'XAF ',
                filled: true,
                fillColor: AppTheme.surfaceColor,
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
              decoration: InputDecoration(
                labelText: 'Prep Time (min) *',
                hintText: '60',
                prefixIcon: Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.paleBlue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.timer, color: AppTheme.accentColor, size: 20),
                ),
                filled: true,
                fillColor: AppTheme.surfaceColor,
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
              decoration: InputDecoration(
                labelText: 'Servings Estimate *',
                hintText: '8',
                prefixIcon: Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.paleBlue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.people, color: AppTheme.accentColor, size: 20),
                ),
                filled: true,
                fillColor: AppTheme.surfaceColor,
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
              value: _targetAgeGroup,
              decoration: InputDecoration(
                labelText: 'Target Age Group (Optional)',
                hintText: 'Select age group',
                prefixIcon: Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.paleBlue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.group, color: AppTheme.accentColor, size: 20),
                ),
                filled: true,
                fillColor: AppTheme.surfaceColor,
              ),
              items: const [
                DropdownMenuItem(value: null, child: Text('Not specified')),
                DropdownMenuItem(value: 'adults', child: Text('Adults')),
                DropdownMenuItem(value: 'kids', child: Text('Kids')),
              ],
              onChanged: (value) {
                setState(() {
                  _targetAgeGroup = value;
                  // Reset gender when age group changes
                  _targetGender = null;
                });
              },
            ),
            const SizedBox(height: 16),
            if (_targetAgeGroup != null)
              DropdownButtonFormField<String>(
                value: _targetGender,
                decoration: InputDecoration(
                  labelText: _targetAgeGroup == 'adults'
                      ? 'Target Gender (Optional)'
                      : 'Target Gender (Optional)',
                  hintText: _targetAgeGroup == 'adults'
                      ? 'Select gender'
                      : 'Select gender',
                  prefixIcon: Container(
                    margin: const EdgeInsets.all(12),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.paleBlue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.person, color: AppTheme.accentColor, size: 20),
                  ),
                  filled: true,
                  fillColor: AppTheme.surfaceColor,
                ),
                items: _targetAgeGroup == 'adults'
                    ? const [
                        DropdownMenuItem(value: null, child: Text('Not specified')),
                        DropdownMenuItem(value: 'male', child: Text('Male')),
                        DropdownMenuItem(value: 'female', child: Text('Female')),
                      ]
                    : const [
                        DropdownMenuItem(value: null, child: Text('Not specified')),
                        DropdownMenuItem(value: 'boy', child: Text('Boy')),
                        DropdownMenuItem(value: 'girl', child: Text('Girl')),
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
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: AppTheme.shadowColor,
            blurRadius: 15,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.straighten,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Available Sizes',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: AppTheme.shadowColor,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextButton.icon(
                    onPressed: _addSize,
                    icon: const Icon(Icons.add, color: Colors.white, size: 18),
                    label: const Text(
                      'Add Size',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.paleBlue,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.lightBlue,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowColor.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
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
          Container(
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              onPressed: () => _removeSize(index),
              icon: const Icon(Icons.delete, color: Colors.red),
              iconSize: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlavorsSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: AppTheme.shadowColor,
            blurRadius: 15,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.local_dining,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Available Flavors',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: AppTheme.shadowColor,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextButton.icon(
                    onPressed: _addFlavor,
                    icon: const Icon(Icons.add, color: Colors.white, size: 18),
                    label: const Text(
                      'Add Flavor',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _flavors
                  .map(
                    (flavor) => Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppTheme.paleBlue,
                            AppTheme.lightBlue,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppTheme.accentColor.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.shadowColor.withValues(alpha: 0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Chip(
                        label: Text(
                          flavor,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        backgroundColor: Colors.transparent,
                        deleteIcon: const Icon(Icons.close, size: 18, color: AppTheme.accentColor),
                        onDeleted: () => _removeFlavor(flavor),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                      ),
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
    final l10n = AppLocalizations.of(context)!;
    // Get all categories from CategoryUtils
    final categories = CategoryUtils.getAllCategoryKeys();

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: AppTheme.shadowColor,
            blurRadius: 15,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.category,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  l10n.category + ' *',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: (_selectedCategory != null && categories.contains(_selectedCategory))
                  ? _selectedCategory
                  : null,
              decoration: InputDecoration(
                labelText: l10n.selectCategory,
                hintText: l10n.chooseCategoryForCake,
                prefixIcon: Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.paleBlue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.category, color: AppTheme.accentColor, size: 20),
                ),
                filled: true,
                fillColor: AppTheme.surfaceColor,
              ),
              items: categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(CategoryUtils.getLocalizedCategory(category, l10n)),
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
                  return l10n.pleaseSelectCategory;
                }
                return null;
              },
            ),
            if (_selectedCategory != null) ...[
              const SizedBox(height: 8),
              Text(
                '${l10n.selected}: ${CategoryUtils.getLocalizedCategory(_selectedCategory!, l10n)}',
                style: const TextStyle(
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
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: AppTheme.shadowColor,
            blurRadius: 15,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.label,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Tags (Optional)',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: AppTheme.shadowColor,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextButton.icon(
                    onPressed: _addTag,
                    icon: const Icon(Icons.add, color: Colors.white, size: 18),
                    label: const Text(
                      'Add Tag',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_tags.isNotEmpty)
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _tags
                    .map(
                      (tag) => Container(
                        decoration: BoxDecoration(
                          gradient: AppTheme.accentGradient,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                              color: AppTheme.shadowColor,
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Chip(
                          label: Text(
                            tag,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          backgroundColor: Colors.transparent,
                          deleteIcon: const Icon(Icons.close, size: 18, color: Colors.white),
                          onDeleted: () => _removeTag(tag),
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                        ),
                      ),
                    )
                    .toList(),
              )
            else
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.paleBlue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppTheme.accentColor,
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Add tags like "Birthday", "Wedding", "Gluten-Free" to help customers find your cake',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailabilitySection() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: AppTheme.shadowColor,
            blurRadius: 15,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.check_circle_outline,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Availability',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _isAvailable ? AppTheme.paleBlue : AppTheme.backgroundColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isAvailable ? AppTheme.accentColor : AppTheme.borderColor,
                  width: 2,
                ),
              ),
              child: SwitchListTile(
                title: const Text(
                  'Available for Order',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    _isAvailable
                        ? 'Customers can order this cake'
                        : 'This cake is currently unavailable',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ),
                value: _isAvailable,
                activeColor: AppTheme.accentColor,
                activeTrackColor: AppTheme.accentColor.withValues(alpha: 0.5),
                onChanged: (value) {
                  setState(() {
                    _isAvailable = value;
                  });
                },
                contentPadding: EdgeInsets.zero,
              ),
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
        'targetAgeGroup': _targetAgeGroup,
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
