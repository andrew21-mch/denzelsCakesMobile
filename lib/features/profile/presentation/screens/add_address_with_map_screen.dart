import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/models/country_model.dart';
import '../../../../core/services/country_service.dart';

class AddAddressWithMapScreen extends StatefulWidget {
  final Function(Address) onSave;
  final Address? initialAddress;

  const AddAddressWithMapScreen({
    super.key,
    required this.onSave,
    this.initialAddress,
  });

  @override
  State<AddAddressWithMapScreen> createState() => _AddAddressWithMapScreenState();
}

class _AddAddressWithMapScreenState extends State<AddAddressWithMapScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  late TextEditingController _streetController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _zipController;
  
  // Map related
  GoogleMapController? _mapController;
  LatLng _selectedLocation = const LatLng(3.848, 11.502); // Yaoundé, Cameroon default
  Set<Marker> _markers = {};
  
  // Dropdown values
  String _selectedType = 'home';
  Country? _selectedCountry;
  
  bool _isLoading = false;
  bool _loadingCountries = true;
  bool _loadingLocation = false;

  // List of countries from backend
  List<Country> _countries = [];

  @override
  void initState() {
    super.initState();
    
    // Initialize controllers
    final address = widget.initialAddress;
    _streetController = TextEditingController(text: address?.street ?? '');
    _cityController = TextEditingController(text: address?.city ?? '');
    _stateController = TextEditingController(text: address?.state ?? '');
    _zipController = TextEditingController(text: address?.zipCode ?? '');
    
    _selectedType = address?.type ?? 'home';
    
    // Load countries and get current location
    _loadCountries();
    _getCurrentLocation();
  }

  Future<void> _loadCountries() async {
    try {
      final countries = await CountryService.getCountries();
      setState(() {
        _countries = countries;
        _loadingCountries = false;
        
        // Set initial country
        final address = widget.initialAddress;
        if (address?.country != null) {
          _selectedCountry = countries.firstWhere(
            (country) => country.code == address!.country,
            orElse: () => countries.first,
          );
        } else {
          // Default to Cameroon
          _selectedCountry = countries.firstWhere(
            (country) => country.code == 'CM',
            orElse: () => countries.first,
          );
        }
      });
    } catch (e) {
      setState(() {
        _loadingCountries = false;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      setState(() {
        _loadingLocation = true;
      });

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _selectedLocation = LatLng(position.latitude, position.longitude);
        _markers = {
          Marker(
            markerId: const MarkerId('selected_location'),
            position: _selectedLocation,
            draggable: true,
            onDragEnd: _onMarkerDragEnd,
          ),
        };
      });

      // Move camera to current location
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: _selectedLocation,
            zoom: 16.0,
          ),
        ),
      );

      // Get address from coordinates
      _getAddressFromCoordinates(_selectedLocation);
    } catch (e) {
// print('Error getting location: $e');
    } finally {
      setState(() {
        _loadingLocation = false;
      });
    }
  }

  Future<void> _getAddressFromCoordinates(LatLng location) async {
    try {
// print('Getting address for coordinates: ${location.latitude}, ${location.longitude}');
      
      List<Placemark> placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );

// print('Geocoding result: ${placemarks.length} placemarks found');

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
// print('First placemark: ${placemark.toString()}');
        
        setState(() {
          _streetController.text = '${placemark.street ?? ''} ${placemark.subThoroughfare ?? ''}'.trim();
          _cityController.text = placemark.locality ?? '';
          _stateController.text = placemark.administrativeArea ?? '';
          _zipController.text = placemark.postalCode ?? '';
          
          // Try to find country by ISO code, but don't override user selection
          if (placemark.isoCountryCode != null && _selectedCountry == null && _countries.isNotEmpty) {
            final countryCode = placemark.isoCountryCode!.toUpperCase();
            try {
              final country = _countries.firstWhere(
                (c) => c.code == countryCode,
              );
              _selectedCountry = country;
            } catch (e) {
              // Country not found in our list, use default
              _selectedCountry = _countries.first;
            }
          }
        });
      } else {
// print('No placemarks found for the location');
        // Show a message to user
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not get address for this location'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e, stackTrace) {
// print('Error getting address: $e');
// print('Stack trace: $stackTrace');
      
      // Show error message to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error getting address: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _onMarkerDragEnd(LatLng newLocation) {
    setState(() {
      _selectedLocation = newLocation;
    });
    _getAddressFromCoordinates(newLocation);
  }

  void _onMapTap(LatLng location) {
    setState(() {
      _selectedLocation = location;
      _markers = {
        Marker(
          markerId: const MarkerId('selected_location'),
          position: location,
          draggable: true,
          onDragEnd: _onMarkerDragEnd,
        ),
      };
    });
    _getAddressFromCoordinates(location);
  }

  @override
  void dispose() {
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    super.dispose();
  }

  void _saveAddress() async {
    if (!_formKey.currentState!.validate() || _selectedCountry == null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final address = Address(
        id: widget.initialAddress?.id, // Don't generate ID for new addresses
        type: _selectedType,
        street: _streetController.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim().isEmpty ? null : _stateController.text.trim(),
        zipCode: _zipController.text.trim().isEmpty ? null : _zipController.text.trim(),
        country: _selectedCountry?.code ?? 'CM', // Force country code, default to CM
        isDefault: widget.initialAddress?.isDefault ?? false,
      );

      widget.onSave(address);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving address: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(widget.initialAddress == null ? 'Add Address' : 'Edit Address'),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Map Section
            Container(
              height: 300,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: _selectedLocation,
                        zoom: 16.0,
                      ),
                      onMapCreated: (GoogleMapController controller) {
                        _mapController = controller;
                      },
                      onTap: _onMapTap,
                      markers: _markers,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: false,
                      mapType: MapType.normal,
                    ),
                    if (_loadingLocation)
                      Container(
                        color: Colors.black54,
                        child: const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: FloatingActionButton.small(
                        onPressed: _getCurrentLocation,
                        backgroundColor: Colors.white,
                        child: const Icon(Icons.my_location, color: AppTheme.primaryColor),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Form Section
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tap on the map to select location or fill details manually',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Address Type
                    const Text(
                      'Address Type',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.borderColor),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedType,
                          isExpanded: true,
                          items: const [
                            DropdownMenuItem(value: 'home', child: Text('Home')),
                            DropdownMenuItem(value: 'work', child: Text('Work')),
                            DropdownMenuItem(value: 'other', child: Text('Other')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedType = value!;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Street Address
                    const Text(
                      'Street Address',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _streetController,
                      decoration: InputDecoration(
                        hintText: 'Enter street address',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppTheme.borderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppTheme.primaryColor),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Street address is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // City
                    const Text(
                      'City',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _cityController,
                      decoration: InputDecoration(
                        hintText: 'Enter city',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppTheme.borderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppTheme.primaryColor),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'City is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // State
                    const Text(
                      'State/Province',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _stateController,
                      decoration: InputDecoration(
                        hintText: 'Enter state or province',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppTheme.borderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppTheme.primaryColor),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: null, // Made optional
                    ),
                    const SizedBox(height: 16),
                    
                    // ZIP Code
                    const Text(
                      'ZIP/Postal Code',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _zipController,
                      decoration: InputDecoration(
                        hintText: 'Enter postal code',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppTheme.borderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppTheme.primaryColor),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Country
                    const Text(
                      'Country',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.borderColor),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: _loadingCountries
                            ? const Center(child: CircularProgressIndicator())
                            : DropdownButton<Country>(
                                value: _selectedCountry,
                                hint: const Text('Select country'),
                                isExpanded: true,
                                items: _countries.map((country) {
                                  return DropdownMenuItem(
                                    value: country,
                                    child: Row(
                                      children: [
                                        Text(
                                          country.flag,
                                          style: const TextStyle(fontSize: 20),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            country.name,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedCountry = value;
                                  });
                                },
                              ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveAddress,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'Save Address',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
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
}
