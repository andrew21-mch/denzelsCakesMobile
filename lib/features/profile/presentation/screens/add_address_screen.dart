import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../core/models/user_model.dart';

class AddAddressScreen extends StatefulWidget {
  final Address? address;
  final Function(Address) onSave;

  const AddAddressScreen({
    super.key,
    this.address,
    required this.onSave,
  });

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  late TextEditingController _streetController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _zipController;
  
  String _selectedType = 'home';
  String _selectedCountry = 'Cameroon';
  
  // Google Maps
  GoogleMapController? _mapController;
  LatLng _selectedLocation = const LatLng(3.848, 11.502); // Yaoundé, Cameroon
  bool _isLoadingLocation = false;
  bool _showMap = false;

  @override
  void initState() {
    super.initState();
    _streetController = TextEditingController(text: widget.address?.street ?? '');
    _cityController = TextEditingController(text: widget.address?.city ?? '');
    _stateController = TextEditingController(text: widget.address?.state ?? '');
    _zipController = TextEditingController(text: widget.address?.zipCode ?? '');
    _selectedType = widget.address?.type ?? 'home';
    _selectedCountry = widget.address?.country ?? 'Cameroon';
  }

  @override
  void dispose() {
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(widget.address == null ? 'Add Address' : 'Edit Address'),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _saveAddress,
            child: const Text(
              'Save',
              style: TextStyle(
                color: AppTheme.accentColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Map toggle button
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _showMap = !_showMap;
                });
                if (_showMap) {
                  _getCurrentLocation();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _showMap ? AppTheme.accentColor : AppTheme.surfaceColor,
                foregroundColor: _showMap ? Colors.white : AppTheme.textPrimary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: Icon(_showMap ? Icons.map_outlined : Icons.map),
              label: Text(_showMap ? 'Hide Map' : 'Pick Location on Map'),
            ),
          ),
          
          // Google Map (when enabled)
          if (_showMap)
            Container(
              height: 250,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _selectedLocation,
                    zoom: 14,
                  ),
                  onMapCreated: (GoogleMapController controller) {
                    _mapController = controller;
                  },
                  onTap: _onMapTapped,
                  markers: {
                    Marker(
                      markerId: const MarkerId('selected_location'),
                      position: _selectedLocation,
                      infoWindow: const InfoWindow(title: 'Selected Location'),
                    ),
                  },
                ),
              ),
            ),
          
          // Form
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Address Type Section
                    const Text(
                      'Address Type',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildAddressTypeSelector(),
                    const SizedBox(height: 24),

                    // Street Address
                    _buildTextField(
                      controller: _streetController,
                      label: 'Street Address',
                      hintText: 'Enter your street address',
                      icon: Icons.location_on_outlined,
                      maxLines: 2,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Street address is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // City
                    _buildTextField(
                      controller: _cityController,
                      label: 'City',
                      hintText: 'Enter city',
                      icon: Icons.location_city,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'City is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // State/Region
                    _buildTextField(
                      controller: _stateController,
                      label: 'State/Region',
                      hintText: 'Enter state or region',
                      icon: Icons.map,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'State/Region is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // ZIP/Postal Code
                    _buildTextField(
                      controller: _zipController,
                      label: 'ZIP/Postal Code',
                      hintText: 'Enter postal code',
                      icon: Icons.markunread_mailbox,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'ZIP/Postal code is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Country
                    _buildCountryDropdown(),
                    const SizedBox(height: 24),

                    // Current location button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _isLoadingLocation ? null : _getCurrentLocation,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: const BorderSide(color: AppTheme.accentColor),
                        ),
                        icon: _isLoadingLocation
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.my_location, color: AppTheme.accentColor),
                        label: Text(
                          _isLoadingLocation ? 'Getting location...' : 'Use Current Location',
                          style: const TextStyle(color: AppTheme.accentColor),
                        ),
                      ),
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

  Widget _buildAddressTypeSelector() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.borderColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTypeOption('home', 'Home', Icons.home),
          ),
          Expanded(
            child: _buildTypeOption('work', 'Work', Icons.work),
          ),
          Expanded(
            child: _buildTypeOption('other', 'Other', Icons.location_on),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeOption(String value, String label, IconData icon) {
    final isSelected = _selectedType == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.accentColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppTheme.textSecondary,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppTheme.textSecondary,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: Icon(icon, color: AppTheme.textSecondary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.accentColor, width: 2),
            ),
            filled: true,
            fillColor: AppTheme.surfaceColor,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildCountryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Country',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedCountry,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.flag, color: AppTheme.textSecondary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.accentColor, width: 2),
            ),
            filled: true,
            fillColor: AppTheme.surfaceColor,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          items: [
            'Cameroon',
            'Nigeria',
            'Ghana',
            'Kenya',
            'South Africa',
            'United States',
            'Canada',
            'United Kingdom',
            'France',
            'Germany',
            'Other',
          ].map((country) => DropdownMenuItem(
            value: country,
            child: Text(country),
          )).toList(),
          onChanged: (value) {
            setState(() {
              _selectedCountry = value ?? 'Cameroon';
            });
          },
        ),
      ],
    );
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      // Check location permission
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Location services are disabled';
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Location permissions are denied';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw 'Location permissions are permanently denied';
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _selectedLocation = LatLng(position.latitude, position.longitude);
      });

      // Move map camera to current location
      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLng(_selectedLocation),
        );
      }

      // Reverse geocode to get address
      await _reverseGeocode(_selectedLocation);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error getting location: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  Future<void> _onMapTapped(LatLng location) async {
    setState(() {
      _selectedLocation = location;
    });

    // Reverse geocode the selected location
    await _reverseGeocode(location);
  }

  Future<void> _reverseGeocode(LatLng location) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        setState(() {
          if (place.street?.isNotEmpty == true) {
            _streetController.text = place.street!;
          }
          if (place.locality?.isNotEmpty == true) {
            _cityController.text = place.locality!;
          }
          if (place.administrativeArea?.isNotEmpty == true) {
            _stateController.text = place.administrativeArea!;
          }
          if (place.postalCode?.isNotEmpty == true) {
            _zipController.text = place.postalCode!;
          }
          if (place.country?.isNotEmpty == true) {
            // Try to match the country to our dropdown options
            String country = place.country!;
            if (country.toLowerCase().contains('cameroon') || country.toLowerCase().contains('cm')) {
              _selectedCountry = 'Cameroon';
            } else if (country.toLowerCase().contains('nigeria')) {
              _selectedCountry = 'Nigeria';
            } else if (country.toLowerCase().contains('ghana')) {
              _selectedCountry = 'Ghana';
            } else if (country.toLowerCase().contains('kenya')) {
              _selectedCountry = 'Kenya';
            } else if (country.toLowerCase().contains('south africa')) {
              _selectedCountry = 'South Africa';
            } else if (country.toLowerCase().contains('united states') || country.toLowerCase().contains('usa')) {
              _selectedCountry = 'United States';
            } else if (country.toLowerCase().contains('canada')) {
              _selectedCountry = 'Canada';
            } else if (country.toLowerCase().contains('united kingdom') || country.toLowerCase().contains('uk')) {
              _selectedCountry = 'United Kingdom';
            } else if (country.toLowerCase().contains('france')) {
              _selectedCountry = 'France';
            } else if (country.toLowerCase().contains('germany')) {
              _selectedCountry = 'Germany';
            } else {
              _selectedCountry = 'Other';
            }
          }
        });
      }
    } catch (e) {
      // Silently fail - geocoding is optional
    }
  }

  void _saveAddress() {
    if (_formKey.currentState?.validate() ?? false) {
      final address = Address(
        id: widget.address?.id,
        type: _selectedType,
        street: _streetController.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        zipCode: _zipController.text.trim(),
        country: _selectedCountry,
        isDefault: widget.address?.isDefault ?? false,
      );

      widget.onSave(address);
    }
  }
}
