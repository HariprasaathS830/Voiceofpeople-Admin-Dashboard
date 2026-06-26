import 'package:app/core/app_theme.dart';
import 'package:app/services/analytics_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;

class HeatmapScreen extends StatefulWidget {
  const HeatmapScreen({super.key});

  @override
  State<HeatmapScreen> createState() => _HeatmapScreenState();
}

class _HeatmapScreenState extends State<HeatmapScreen> {
  final _analytics = AnalyticsService();
  final MapController _mapController = MapController();
  List<Map<String, dynamic>> _heatmapData = [];
  bool _loading = true;
  String? _error;
  ll.LatLng _center = const ll.LatLng(11.9416, 79.8083); // Default to Puducherry
  Map<String, dynamic>? _hoveredPoint;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final data = await _analytics.getHeatmapData();
      if (mounted) {
        setState(() {
          _heatmapData = data;
          _loading = false;

          // Dynamically adjust map center to the mean of all geocoded locations
          if (data.isNotEmpty) {
            double totalLat = 0;
            double totalLng = 0;
            for (final pt in data) {
              totalLat += pt['lat'] as double;
              totalLng += pt['lng'] as double;
            }
            _center = ll.LatLng(totalLat / data.length, totalLng / data.length);
          }
        });

        // Small delay to ensure MapController is attached before moving
        if (data.isNotEmpty) {
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) {
              _mapController.move(_center, 12.0);
            }
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Failed to load heatmap data. Ensure backend is running at http://localhost:3000.';
        });
      }
    }
  }

  Color _getWeightColor(int weight) {
    if (weight == 1) {
      return AppTheme.accent.withOpacity(0.5); // Cyan/blue for sparse
    } else if (weight == 2) {
      return AppTheme.warningAmber.withOpacity(0.6); // Amber for medium
    } else {
      return AppTheme.dangerRed.withOpacity(0.7); // Red for dense
    }
  }

  double _getWeightRadius(int weight) {
    // Return radius in screen pixels
    return 15.0 + (weight * 6.0);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.accent),
      );
    }

    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: AppTheme.dangerRed, size: 48),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _fetchData,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accent,
                foregroundColor: AppTheme.bgBase,
              ),
            ),
          ],
        ),
      );
    }

    // Calculations for summary stats
    final totalLocations = _heatmapData.length;
    final totalWeight = _heatmapData.fold<int>(0, (sum, item) => sum + (item['weight'] as int));
    final highestDensityPoint = _heatmapData.isEmpty
        ? null
        : _heatmapData.reduce((curr, next) =>
            (curr['weight'] as int) > (next['weight'] as int) ? curr : next);

    return LayoutBuilder(builder: (context, constraints) {
      final bool isWide = constraints.maxWidth > 950;

      final mapWidget = FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _center,
          initialZoom: 12.0,
          maxZoom: 18.0,
          minZoom: 3.0,
        ),
        children: [
          // Sleek Dark Maps Theme (CartoDB Dark Matter)
          TileLayer(
            urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
            subdomains: const ['a', 'b', 'c', 'd'],
            userAgentPackageName: 'com.civil.voiceofpeople.admin',
          ),
          
          // Density circles indicating heatmap data
          CircleLayer(
            circles: _heatmapData.map((pt) {
              final lat = pt['lat'] as double;
              final lng = pt['lng'] as double;
              final weight = pt['weight'] as int;

              return CircleMarker(
                point: ll.LatLng(lat, lng),
                radius: _getWeightRadius(weight),
                useRadiusInMeter: false,
                color: _getWeightColor(weight),
                borderColor: _getWeightColor(weight).withOpacity(1.0),
                borderStrokeWidth: 1.5,
              );
            }).toList(),
          ),

          // Simple marker layer to handle click interactions and highlight selected
          MarkerLayer(
            markers: _heatmapData.map((pt) {
              final lat = pt['lat'] as double;
              final lng = pt['lng'] as double;
              final weight = pt['weight'] as int;

              return Marker(
                point: ll.LatLng(lat, lng),
                width: _getWeightRadius(weight) * 2,
                height: _getWeightRadius(weight) * 2,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _hoveredPoint = pt;
                    });
                  },
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.transparent,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      );

      final sidebarWidget = Container(
        width: isWide ? 320 : double.infinity,
        decoration: BoxDecoration(
          color: AppTheme.bgSurface,
          border: Border(
            left: isWide
                ? const BorderSide(color: AppTheme.borderColor)
                : BorderSide.none,
            top: !isWide
                ? const BorderSide(color: AppTheme.borderColor)
                : BorderSide.none,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header stats
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Location Summary',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      IconButton(
                        onPressed: _fetchData,
                        icon: const Icon(Icons.refresh, size: 18, color: AppTheme.accent),
                        tooltip: 'Refresh data',
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildStatRow('Unique Hotspots', '$totalLocations'),
                  _buildStatRow('Total Mapped Users', '$totalWeight'),
                  if (highestDensityPoint != null)
                    _buildStatRow(
                      'Highest Density',
                      '${highestDensityPoint['address']} (${highestDensityPoint['weight']} users)',
                      isAddress: true,
                    ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppTheme.borderColor),
            
            // Legend
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('DENSITY LEGEND',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.8)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildLegendDot(AppTheme.accent, 'Low (1 user)'),
                      const SizedBox(width: 16),
                      _buildLegendDot(AppTheme.warningAmber, 'Medium (2 users)'),
                      const SizedBox(width: 16),
                      _buildLegendDot(AppTheme.dangerRed, 'High (3+ users)'),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppTheme.borderColor),

            // Top Locations List
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text(
                'HOTSPOT LOCATIONS',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            Expanded(
              child: _heatmapData.isEmpty
                  ? const Center(
                      child: Text('No location data available',
                          style: TextStyle(color: AppTheme.textSecondary)))
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: _heatmapData.length,
                      separatorBuilder: (_, __) => const Divider(height: 1, color: AppTheme.borderColor),
                      itemBuilder: (context, index) {
                        final pt = _heatmapData[index];
                        final isSelected = _hoveredPoint == pt;
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          selected: isSelected,
                          selectedTileColor: AppTheme.accent.withOpacity(0.08),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          title: Text(
                            pt['address'] as String,
                            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.w500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            'Lat: ${(pt['lat'] as double).toStringAsFixed(4)}, Lng: ${(pt['lng'] as double).toStringAsFixed(4)}',
                            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getWeightColor(pt['weight'] as int).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: _getWeightColor(pt['weight'] as int).withOpacity(0.4)),
                            ),
                            child: Text(
                              '${pt['weight']} User${(pt['weight'] as int) == 1 ? '' : 's'}',
                              style: TextStyle(
                                color: _getWeightColor(pt['weight'] as int).withOpacity(1.0),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              _hoveredPoint = pt;
                            });
                            _mapController.move(ll.LatLng(pt['lat'] as double, pt['lng'] as double), 14.5);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      );

      // Selected point overlay indicator on map
      final mapArea = Stack(
        children: [
          mapWidget,
          if (_hoveredPoint != null)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.bgCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Selected Hotspot',
                            style: TextStyle(color: AppTheme.accent, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _hoveredPoint!['address'] as String,
                            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Coordinates: ${(_hoveredPoint!['lat'] as double).toStringAsFixed(5)}, ${(_hoveredPoint!['lng'] as double).toStringAsFixed(5)}',
                            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getWeightColor(_hoveredPoint!['weight'] as int).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: _getWeightColor(_hoveredPoint!['weight'] as int).withOpacity(0.4)),
                          ),
                          child: Text(
                            '${_hoveredPoint!['weight']} Registered',
                            style: TextStyle(
                              color: _getWeightColor(_hoveredPoint!['weight'] as int).withOpacity(1.0),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        TextButton(
                          onPressed: () => setState(() => _hoveredPoint = null),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(40, 20),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text('Dismiss', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      );

      return isWide
          ? Row(
              children: [
                Expanded(child: mapArea),
                sidebarWidget,
              ],
            )
          : Column(
              children: [
                Expanded(flex: 3, child: mapArea),
                Expanded(flex: 2, child: sidebarWidget),
              ],
            );
    });
  }

  Widget _buildStatRow(String label, String value, {bool isAddress = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            maxLines: isAddress ? 1 : null,
            overflow: isAddress ? TextOverflow.ellipsis : null,
          ),
        ],
      ),
    );
  }

  Widget _buildLegendDot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10)),
      ],
    );
  }
}
