import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:nabeelaljirbi_app/core/const/app_colors.dart';
import 'package:nabeelaljirbi_app/core/style/global_text_style.dart';

class MapPickerDialog extends StatefulWidget {
  final LatLng initialLocation;
  final String initialAddress;

  const MapPickerDialog({
    super.key,
    required this.initialLocation,
    required this.initialAddress,
  });

  @override
  State<MapPickerDialog> createState() => _MapPickerDialogState();
}

class _MapPickerDialogState extends State<MapPickerDialog> {
  late MapController _mapController;
  late LatLng _currentCenter;
  String _currentAddress = '';
  bool _isReverseGeocoding = false;
  bool _isSearching = false;
  bool _isMoving = false;

  final TextEditingController _searchController = TextEditingController();
  final List<Map<String, dynamic>> _predictions = [];
  Timer? _searchDebounce;
  Timer? _geocodeDebounce;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _currentCenter = widget.initialLocation;
    _currentAddress = widget.initialAddress;
    _searchController.text = widget.initialAddress;
  }

  @override
  void dispose() {
    _mapController.dispose();
    _searchController.dispose();
    _searchDebounce?.cancel();
    _geocodeDebounce?.cancel();
    super.dispose();
  }

  // Detect current device location
  Future<void> _detectCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar('error'.tr, 'location_service_disabled'.tr);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Get.snackbar('error'.tr, 'location_permission_denied'.tr);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        Get.snackbar('error'.tr, 'location_permission_permanently_denied'.tr);
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final newLatLng = LatLng(position.latitude, position.longitude);
      _mapController.move(newLatLng, 16.0);
      setState(() {
        _currentCenter = newLatLng;
      });
      _triggerReverseGeocode(newLatLng);
    } catch (e) {
      debugPrint('Error detecting current location: $e');
    }
  }

  // Reverse Geocoding with a debounce to prevent excessive API hits
  void _triggerReverseGeocode(LatLng target) {
    _geocodeDebounce?.cancel();
    setState(() {
      _isReverseGeocoding = true;
    });

    _geocodeDebounce = Timer(const Duration(milliseconds: 600), () async {
      try {
        final uri = Uri.https('nominatim.openstreetmap.org', '/reverse', {
          'lat': target.latitude.toString(),
          'lon': target.longitude.toString(),
          'format': 'json',
          'addressdetails': '1',
        });

        final response = await http.get(
          uri,
          headers: {
            'User-Agent': 'NabeelAljirbi-FlutterApp/1.0.0 (admin@nabeelaljirbi.com)',
            'Accept': 'application/json',
            'Accept-Language': 'en-US,en;q=0.9,ar;q=0.8',
          },
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = json.decode(response.body);
          final displayName = data['display_name'] ?? '';
          if (mounted) {
            setState(() {
              _currentAddress = displayName;
              _isReverseGeocoding = false;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              _isReverseGeocoding = false;
            });
          }
        }
      } catch (e) {
        debugPrint('Error reverse geocoding: $e');
        if (mounted) {
          setState(() {
            _isReverseGeocoding = false;
          });
        }
      }
    });
  }

  // Search Address Location
  void _searchLocation(String query) {
    _searchDebounce?.cancel();
    if (query.trim().isEmpty) {
      setState(() {
        _predictions.clear();
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    _searchDebounce = Timer(const Duration(milliseconds: 600), () async {
      try {
        final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
          'q': query,
          'format': 'json',
          'addressdetails': '1',
          'limit': '5',
        });

        final response = await http.get(
          uri,
          headers: {
            'User-Agent': 'NabeelAljirbi-FlutterApp/1.0.0 (admin@nabeelaljirbi.com)',
            'Accept': 'application/json',
            'Accept-Language': 'en-US,en;q=0.9,ar;q=0.8',
          },
        );

        if (response.statusCode == 200) {
          final List<dynamic> data = json.decode(response.body);
          if (mounted) {
            setState(() {
              _predictions.clear();
              _predictions.addAll(data.cast<Map<String, dynamic>>());
              _isSearching = false;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              _isSearching = false;
            });
          }
        }
      } catch (e) {
        debugPrint('Error searching location: $e');
        if (mounted) {
          setState(() {
            _isSearching = false;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isRtl = Get.locale?.languageCode == 'ar';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'location'.tr,
          style: globalTextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xff2D2D2D),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xff2D2D2D)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Flutter Map
          Positioned.fill(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _currentCenter,
                initialZoom: 15.0,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all,
                ),
                onPositionChanged: (camera, hasGesture) {
                  if (hasGesture) {
                    setState(() {
                      _currentCenter = camera.center;
                    });
                    _triggerReverseGeocode(camera.center);
                  }
                },
                onMapEvent: (MapEvent event) {
                  if (event is MapEventMoveStart) {
                    setState(() {
                      _isMoving = true;
                    });
                  } else if (event is MapEventMoveEnd) {
                    setState(() {
                      _isMoving = false;
                    });
                  }
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c'],
                  userAgentPackageName: 'com.example.nabeelaljirbi_app',
                ),
              ],
            ),
          ),

          // Central Marker Pin
          Center(
            child: Container(
              margin: const EdgeInsets.only(bottom: 35),
              child: AnimatedScale(
                scale: _isMoving ? 1.2 : 1.0,
                duration: const Duration(milliseconds: 150),
                child: Icon(
                  Icons.location_on_sharp,
                  size: 44,
                  color: AppColors.primaryColor,
                  shadows: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Search Card Overlay
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _searchLocation,
                    textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                    decoration: InputDecoration(
                      hintText: 'search_location'.tr,
                      hintStyle: globalTextStyle(
                        fontSize: 14,
                        color: const Color(0xff94A3B8),
                      ),
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF64748B)),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Color(0xFF64748B)),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _predictions.clear();
                                });
                              },
                            )
                          : (_isSearching
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: Padding(
                                    padding: EdgeInsets.all(12.0),
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.primaryColor,
                                    ),
                                  ),
                                )
                              : null),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    style: globalTextStyle(
                      fontSize: 14,
                      color: const Color(0xFF2D2D2D),
                    ),
                  ),
                ),

                // Predictions Dropdown
                if (_predictions.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    constraints: const BoxConstraints(maxHeight: 220),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 15,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: _predictions.length,
                      separatorBuilder: (context, index) => const Divider(
                        height: 1,
                        color: Color(0xFFF1F5F9),
                      ),
                      itemBuilder: (context, index) {
                        final item = _predictions[index];
                        return ListTile(
                          leading: const Icon(
                            Icons.location_on_outlined,
                            color: Color(0xFF64748B),
                            size: 20,
                          ),
                          title: Text(
                            item['display_name'] ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: globalTextStyle(
                              fontSize: 14,
                              color: const Color(0xFF2D2D2D),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          onTap: () {
                            final lat = double.tryParse(item['lat']?.toString() ?? '');
                            final lon = double.tryParse(item['lon']?.toString() ?? '');
                            if (lat != null && lon != null) {
                              final selectedLatLng = LatLng(lat, lon);
                              _mapController.move(selectedLatLng, 16.0);
                              setState(() {
                                _currentCenter = selectedLatLng;
                                _currentAddress = item['display_name'] ?? '';
                                _searchController.text = item['display_name'] ?? '';
                                _predictions.clear();
                              });
                              FocusScope.of(context).unfocus();
                            }
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),

          // Detect My Location Floating Button
          Positioned(
            bottom: 180,
            right: isRtl ? null : 16,
            left: isRtl ? 16 : null,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              onPressed: _detectCurrentLocation,
              child: const Icon(Icons.my_location, size: 20),
            ),
          ),

          // Details Card Footer
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 15,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'location'.tr,
                      style: globalTextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Color(0xFF64748B),
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: _isReverseGeocoding
                              ? Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  child: const LinearProgressIndicator(
                                    color: AppColors.primaryColor,
                                    backgroundColor: Color(0xFFF1F5F9),
                                  ),
                                )
                              : Text(
                                  _currentAddress.isNotEmpty
                                      ? _currentAddress
                                      : 'move_marker_desc'.tr,
                                  style: globalTextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF1E293B),
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Confirm Selection Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        onPressed: _isReverseGeocoding
                            ? null
                            : () {
                                Navigator.of(context).pop({
                                  'lat': _currentCenter.latitude,
                                  'lng': _currentCenter.longitude,
                                  'address': _currentAddress,
                                });
                              },
                        child: Text(
                          'confirm_location'.tr,
                          style: globalTextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
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
}
