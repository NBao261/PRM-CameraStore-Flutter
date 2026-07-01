import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/store_remote_datasource.dart';
import '../../data/repositories/store_repository_impl.dart';
import '../../domain/entities/store_entity.dart';

class StoreMapScreen extends StatefulWidget {
  const StoreMapScreen({super.key});

  @override
  State<StoreMapScreen> createState() => _StoreMapScreenState();
}

class _StoreMapScreenState extends State<StoreMapScreen> {
  final MapController _mapController = MapController();

  StoreEntity? _store;
  LatLng? _userLocation;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    await Future.wait([
      _loadStore(),
      _loadUserLocation(),
    ]);

    setState(() => _isLoading = false);
  }

  Future<void> _loadStore() async {
    try {
      final apiClient = ApiClient();
      final ds = StoreRemoteDataSource(apiClient);
      final repo = StoreRepositoryImpl(ds);
      final stores = await repo.getStores();
      if (stores.isNotEmpty) {
        _store = stores.first;
      }
    } catch (e) {
      _error = 'Không thể tải thông tin cửa hàng';
    }
  }

  Future<void> _loadUserLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) return;

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      _userLocation = LatLng(position.latitude, position.longitude);
    } catch (_) {}
  }

  void _centerOnStore() {
    if (_store != null) {
      _mapController.move(
        LatLng(_store!.latitude, _store!.longitude),
        15.0,
      );
    }
  }

  void _centerOnUser() {
    if (_userLocation != null) {
      _mapController.move(_userLocation!, 15.0);
    }
  }

  Future<void> _openInGoogleMaps() async {
    if (_store == null) return;
    
    final lat = _store!.latitude;
    final lng = _store!.longitude;
    final name = Uri.encodeComponent(_store!.name);

    final webUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    final nativeUrl = Uri.parse('geo:$lat,$lng?q=$lat,$lng($name)');

    try {
      // 1. Try launching native Google Maps app
      bool launched = await launchUrl(nativeUrl, mode: LaunchMode.externalApplication);
      
      // 2. Fallback to web URL in external browser
      if (!launched) {
        launched = await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      }
      
      // 3. Fallback to platform default (which might be in-app browser)
      if (!launched) {
        await launchUrl(webUrl, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      // If everything fails (often happens on clean emulators with no browser)
      try {
        await launchUrl(webUrl, mode: LaunchMode.inAppBrowserView);
      } catch (e2) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Thiết bị chưa cài đặt ứng dụng Bản đồ hoặc Trình duyệt.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Store Location',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        actions: [
          // Store location button
          IconButton(
            onPressed: _store != null ? _centerOnStore : null,
            icon: Icon(
              Icons.store_rounded,
              color: _store != null ? const Color(0xFF4285F4) : AppColors.textHint,
            ),
            tooltip: 'Tìm cửa hàng',
          ),
          // My location button
          IconButton(
            onPressed: _userLocation != null ? _centerOnUser : null,
            icon: Icon(
              Icons.my_location,
              color: _userLocation != null
                  ? const Color(0xFF4285F4)
                  : AppColors.textHint,
            ),
            tooltip: 'Vị trí của tôi',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF4285F4)),
                  SizedBox(height: 16),
                  Text(
                    'Đang tải bản đồ...',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            )
          : _error != null && _store == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.map_outlined,
                          size: 64, color: AppColors.textHint),
                      const SizedBox(height: 16),
                      Text(_error!,
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 15)),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _loadData,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Thử lại'),
                      ),
                    ],
                  ),
                )
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    final storeLatLng = _store != null
        ? LatLng(_store!.latitude, _store!.longitude)
        : const LatLng(10.7739, 106.7030);

    return Column(
      children: [
        // ── Map section (top half) ────────────────────────
        Expanded(
          flex: 5,
          child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: storeLatLng,
              initialZoom: 15.0,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.camera_store_app',
                maxZoom: 19,
              ),
              MarkerLayer(
                markers: [
                  // Store marker with label
                  if (_store != null)
                    Marker(
                      point: storeLatLng,
                      width: 160,
                      height: 80,
                      alignment: Alignment.topCenter,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Pin icon
                          const Icon(
                            Icons.location_on,
                            color: Color(0xFF4285F4),
                            size: 44,
                          ),
                          // Label
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      Colors.black.withValues(alpha: 0.12),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              _store!.name,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF4285F4),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  // User location
                  if (_userLocation != null)
                    Marker(
                      point: _userLocation!,
                      width: 28,
                      height: 28,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF4285F4),
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF4285F4)
                                  .withValues(alpha: 0.3),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),

        // ── Store info section (bottom half) ──────────────
        Expanded(
          flex: 5,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: _store == null
                ? const Center(
                    child: Text('Không có thông tin cửa hàng',
                        style: TextStyle(color: AppColors.textHint)))
                : SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
                    child: Column(
                      children: [
                        // Store header
                        Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F0FE),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.store_rounded,
                                color: Color(0xFF4285F4),
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _store!.name,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _store!.address,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textSecondary,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),
                        const Divider(height: 1, color: Color(0xFFEEEEEE)),

                        // Hotline
                        _InfoListTile(
                          icon: Icons.phone_outlined,
                          iconColor: const Color(0xFF4285F4),
                          label: 'Hotline',
                          value: _store!.phone,
                          valueColor: const Color(0xFF4285F4),
                        ),
                        const Divider(
                            height: 1, color: Color(0xFFEEEEEE)),

                        // Working Hours
                        _InfoListTile(
                          icon: Icons.schedule_outlined,
                          iconColor: const Color(0xFF4285F4),
                          label: 'Working Hours',
                          value: _store!.openingHours,
                        ),
                        const Divider(
                            height: 1, color: Color(0xFFEEEEEE)),

                        // Address
                        _InfoListTile(
                          icon: Icons.location_on_outlined,
                          iconColor: const Color(0xFF4285F4),
                          label: 'Address',
                          value: _store!.address,
                        ),

                        const SizedBox(height: 24),

                        // Open in Google Maps button
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: _openInGoogleMaps,
                            icon: const Icon(Icons.navigation_rounded,
                                size: 20),
                            label: const Text(
                              'Open in Google Maps',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4285F4),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
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
    );
  }
}

// ── Info row matching the reference UI ────────────────────
class _InfoListTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoListTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Icon(icon, size: 22, color: iconColor),
          const SizedBox(width: 14),
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: valueColor ?? AppColors.textSecondary,
              ),
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
