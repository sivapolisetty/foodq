import 'package:flutter/material.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import '../services/location_service.dart';
import '../../shared/theme/app_colors.dart';

/// Address autocomplete field with Google Places suggestions
/// Provides real-time address suggestions as the user types
class AddressAutocompleteField extends StatefulWidget {
  final TextEditingController controller;
  final String? labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final Function(String)? onChanged;
  final Function(LocationAddress)? onAddressSelected;
  final String? Function(String?)? validator;
  final bool enabled;

  const AddressAutocompleteField({
    super.key,
    required this.controller,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.onChanged,
    this.onAddressSelected,
    this.validator,
    this.enabled = true,
  });

  @override
  State<AddressAutocompleteField> createState() => _AddressAutocompleteFieldState();
}

class _AddressAutocompleteFieldState extends State<AddressAutocompleteField> {
  static const String _googleApiKey = 'AIzaSyCZ4ulfUP-2FaLe90Ar1zoQBimcVJu8ZFM';
  
  @override
  void initState() {
    super.initState();
    print('🔧 AddressAutocompleteField initialized with API key: ${_googleApiKey.substring(0, 10)}...');
  }
  
  @override
  Widget build(BuildContext context) {
    print('🏗️ Building AddressAutocompleteField widget...');
    
    // Wrap in a try-catch to handle any initialization errors
    try {
      return GooglePlaceAutoCompleteTextField(
      textEditingController: widget.controller,
      googleAPIKey: _googleApiKey,
      inputDecoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        filled: true,
        fillColor: widget.enabled ? Colors.white : Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      // enabled: widget.enabled, // Note: enabled parameter not available in this widget
      debounceTime: 400, // Wait 400ms before making API call
      countries: const ["us"], // Restrict to US addresses for restaurants
      isLatLngRequired: true,
      getPlaceDetailWithLatLng: (Prediction prediction) async {
        print('🏠 Address selected: ${prediction.description}');
        print('📍 Place ID: ${prediction.placeId}');
        
        if (prediction.lat != null && prediction.lng != null) {
          print('📍 Coordinates: ${prediction.lat}, ${prediction.lng}');
          
          // Get detailed address information
          final address = await LocationService.getAddressFromCoordinates(
            double.parse(prediction.lat!),
            double.parse(prediction.lng!),
          );
          
          if (address != null && widget.onAddressSelected != null) {
            // Update the address with the selected formatted address
            final updatedAddress = LocationAddress(
              street: address.street,
              locality: address.locality,
              subLocality: address.subLocality,
              administrativeArea: address.administrativeArea,
              postalCode: address.postalCode,
              country: address.country,
              latitude: address.latitude,
              longitude: address.longitude,
              formattedAddress: prediction.description ?? address.formattedAddress,
            );
            
            widget.onAddressSelected!(updatedAddress);
          }
        }
      },
      itemClick: (Prediction prediction) {
        print('🎯 Item clicked: ${prediction.description}');
        widget.controller.text = prediction.description ?? '';
        widget.controller.selection = TextSelection.fromPosition(
          TextPosition(offset: widget.controller.text.length),
        );
        
        if (widget.onChanged != null) {
          widget.onChanged!(widget.controller.text);
        }
      },
      seperatedBuilder: const Divider(),
      containerHorizontalPadding: 0,
      itemBuilder: (context, index, Prediction prediction) {
        return Container(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const Icon(
                Icons.location_on,
                color: Colors.grey,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      prediction.description ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (prediction.structuredFormatting?.secondaryText != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        prediction.structuredFormatting!.secondaryText!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
    } catch (e) {
      print('❌ Error initializing GooglePlaceAutoCompleteTextField: $e');
      print('🔧 Falling back to regular TextFormField...');
      
      // Fallback to regular TextFormField if Google Places fails
      return TextFormField(
        controller: widget.controller,
        decoration: InputDecoration(
          labelText: widget.labelText,
          hintText: widget.hintText ?? 'Enter address manually',
          prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          suffixIcon: const Icon(Icons.warning, color: Colors.orange),
        ),
        onChanged: widget.onChanged,
        validator: widget.validator,
        maxLines: 2,
      );
    }
  }
}

/// Simple address autocomplete field that only returns the text
class SimpleAddressAutocompleteField extends StatelessWidget {
  final TextEditingController controller;
  final String? labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;
  final bool enabled;
  final int maxLines;

  const SimpleAddressAutocompleteField({
    super.key,
    required this.controller,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.onChanged,
    this.validator,
    this.enabled = true,
    this.maxLines = 1,
  });

  static const String _googleApiKey = 'AIzaSyCZ4ulfUP-2FaLe90Ar1zoQBimcVJu8ZFM';

  @override
  Widget build(BuildContext context) {
    return GooglePlaceAutoCompleteTextField(
      textEditingController: controller,
      googleAPIKey: _googleApiKey,
      inputDecoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey[50],
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16, 
          vertical: maxLines > 1 ? 16 : 12,
        ),
      ),
      // enabled: enabled, // Note: enabled parameter not available in this widget
      debounceTime: 400,
      countries: const ["us"],
      isLatLngRequired: false,
      getPlaceDetailWithLatLng: (Prediction prediction) {
        print('📍 Simple autocomplete selected: ${prediction.description}');
      },
      itemClick: (Prediction prediction) {
        controller.text = prediction.description ?? '';
        controller.selection = TextSelection.fromPosition(
          TextPosition(offset: controller.text.length),
        );
        
        if (onChanged != null) {
          onChanged!(controller.text);
        }
      },
      seperatedBuilder: const Divider(),
      containerHorizontalPadding: 0,
      itemBuilder: (context, index, Prediction prediction) {
        return Container(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const Icon(
                Icons.location_on,
                color: Colors.grey,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  prediction.description ?? '',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}