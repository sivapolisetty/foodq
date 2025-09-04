import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/location_provider.dart';
import 'location_selection_modal.dart';

class LocationHeader extends ConsumerWidget {
  final VoidCallback? onLocationChanged;
  
  const LocationHeader({
    Key? key,
    this.onLocationChanged,
  }) : super(key: key);

  void _showLocationModal(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LocationSelectionModal(
        onLocationSelected: (address, lat, lng) {
          // Location is already set in the modal via the provider
          onLocationChanged?.call();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationState = ref.watch(locationProvider);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        child: InkWell(
          onTap: () => _showLocationModal(context, ref),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                // Location icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.location_on,
                    color: Color(0xFF4CAF50),
                    size: 20,
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Address content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Takeaway label
                      Text(
                        'Take away near by',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      
                      const SizedBox(height: 2),
                      
                      // Address or prompt
                      if (locationState.address != null)
                        Text(
                          locationState.address!.formattedAddress,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF212121),
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                      else if (locationState.isLoading)
                        Row(
                          children: [
                            SizedBox(
                              height: 12,
                              width: 12,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.grey[600]!,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Getting location...',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        )
                      else if (locationState.error != null)
                        Text(
                          'Location unavailable',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.red[600],
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      else
                        Text(
                          'Set your location',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),
                
                // Dropdown arrow
                Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.grey[600],
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CompactLocationHeader extends ConsumerWidget {
  final VoidCallback? onLocationChanged;
  
  const CompactLocationHeader({
    Key? key,
    this.onLocationChanged,
  }) : super(key: key);

  void _showLocationModal(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LocationSelectionModal(
        onLocationSelected: (address, lat, lng) {
          onLocationChanged?.call();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationState = ref.watch(locationProvider);
    
    return InkWell(
      onTap: () => _showLocationModal(context, ref),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.location_on,
              color: const Color(0xFF4CAF50),
              size: 16,
            ),
            const SizedBox(width: 6),
            
            if (locationState.address != null)
              Flexible(
                child: Text(
                  locationState.address!.formattedAddress,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF212121),
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              )
            else if (locationState.isLoading)
              Text(
                'Getting location...',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              )
            else
              Text(
                'Set location',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
            
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              color: Colors.grey[600],
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}