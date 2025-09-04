import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../services/address_service.dart';
import '../../shared/theme/app_colors.dart';
import 'dart:async';

class CustomAddressAutocompleteField extends StatefulWidget {
  final TextEditingController controller;
  final String? labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final Function(String)? onChanged;
  final Function(String)? onAddressSelected;
  final Function(PlaceDetails)? onPlaceSelected;
  final String? Function(String?)? validator;
  final bool enabled;

  const CustomAddressAutocompleteField({
    super.key,
    required this.controller,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.onChanged,
    this.onAddressSelected,
    this.onPlaceSelected,
    this.validator,
    this.enabled = true,
  });

  @override
  State<CustomAddressAutocompleteField> createState() => _CustomAddressAutocompleteFieldState();
}

class _CustomAddressAutocompleteFieldState extends State<CustomAddressAutocompleteField> {
  List<PlacePrediction> _suggestions = [];
  bool _isLoading = false;
  Timer? _debounceTimer;
  final OverlayPortalController _overlayController = OverlayPortalController();
  final LayerLink _layerLink = LayerLink();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    print('🔧 CustomAddressAutocompleteField initialized');
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus) {
      // Add delay for web to allow tap events to complete
      if (kIsWeb) {
        Timer(const Duration(milliseconds: 200), () {
          if (!_focusNode.hasFocus && mounted) {
            _hideSuggestions();
          }
        });
      } else {
        _hideSuggestions();
      }
    }
  }

  void _onTextChanged(String value) {
    if (widget.onChanged != null) {
      widget.onChanged!(value);
    }

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      _fetchSuggestions(value);
    });
  }

  Future<void> _fetchSuggestions(String input) async {
    if (input.length < 2) {
      _hideSuggestions();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final suggestions = await AddressService.getAddressSuggestions(input);
      setState(() {
        _suggestions = suggestions;
        _isLoading = false;
      });

      if (suggestions.isNotEmpty) {
        print('📋 [AUTOCOMPLETE] Got ${suggestions.length} suggestions:');
        for (int i = 0; i < suggestions.length; i++) {
          final suggestion = suggestions[i];
          print('   ${i + 1}. "${suggestion.description}" (ID: ${suggestion.placeId})');
        }
        _showSuggestions();
      } else {
        print('📭 [AUTOCOMPLETE] No suggestions found');
        _hideSuggestions();
      }
    } catch (e) {
      setState(() {
        _suggestions = [];
        _isLoading = false;
      });
      _hideSuggestions();
    }
  }

  void _showSuggestions() {
    _overlayController.show();
  }

  void _hideSuggestions() {
    _overlayController.hide();
  }

  void _handleSuggestionSelection(PlacePrediction prediction) {
    print('🎯 TAP/SELECTION: Starting selection for "${prediction.description}"');
    
    // For web, prevent focus loss during selection
    if (kIsWeb) {
      _focusNode.requestFocus();
    }
    
    // Call selection handler
    _onSuggestionSelected(prediction);
    
    // Clean up UI with proper sequencing for web
    if (mounted) {
      setState(() {
        _suggestions.clear();
      });
    }
    
    _hideSuggestions();
    
    // Unfocus with delay on web to ensure events complete
    if (kIsWeb) {
      Timer(const Duration(milliseconds: 100), () {
        if (mounted) {
          _focusNode.unfocus();
        }
      });
    } else {
      _focusNode.unfocus();
    }
  }

  void _onSuggestionSelected(PlacePrediction prediction) async {
    print('🎯 SELECTION: Starting selection for "${prediction.description}"');
    
    // Set text immediately
    widget.controller.text = prediction.description ?? '';
    
    // Call onAddressSelected callback immediately (synchronous)
    if (widget.onAddressSelected != null) {
      print('📞 SELECTION: Calling onAddressSelected callback');
      widget.onAddressSelected!(prediction.description ?? '');
      print('✅ SELECTION: onAddressSelected callback completed');
    }

    // Call onChanged callback immediately (synchronous) 
    if (widget.onChanged != null) {
      print('📞 SELECTION: Calling onChanged callback');
      widget.onChanged!(widget.controller.text);
      print('✅ SELECTION: onChanged callback completed');
    }

    // Handle place details asynchronously (but don't wait)
    if (widget.onPlaceSelected != null && prediction.placeId != null) {
      print('🔍 SELECTION: Fetching place details in background');
      AddressService.getPlaceDetails(prediction.placeId!).then((placeDetails) {
        if (placeDetails != null) {
          print('📞 SELECTION: Calling onPlaceSelected callback with details');
          widget.onPlaceSelected!(placeDetails);
          print('✅ SELECTION: onPlaceSelected callback completed');
        }
      }).catchError((e) {
        print('❌ SELECTION: Place details fetch failed: $e');
      });
    }

    print('🎯 SELECTION: Selection completed');
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: OverlayPortal(
        controller: _overlayController,
        overlayChildBuilder: (context) => _buildSuggestionsOverlay(),
        child: TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          enabled: widget.enabled,
          onChanged: _onTextChanged,
          validator: widget.validator,
          decoration: InputDecoration(
            labelText: widget.labelText,
            hintText: widget.hintText,
            prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,
            suffixIcon: _isLoading 
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : null,
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
        ),
      ),
    );
  }

  Widget _buildSuggestionsOverlay() {
    // Get the render box to calculate proper width
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    final double fieldWidth = renderBox?.size.width ?? (MediaQuery.of(context).size.width - 32);
    
    return CompositedTransformFollower(
      link: _layerLink,
      targetAnchor: Alignment.bottomLeft,
      followerAnchor: Alignment.topLeft,
      offset: const Offset(0, 8),
      child: Material(
        elevation: kIsWeb ? 16 : 8, // Higher elevation on web for better visibility
        borderRadius: BorderRadius.circular(8),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 200),
          width: fieldWidth.clamp(200.0, MediaQuery.of(context).size.width - 32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Add a debug header
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, size: 16, color: Colors.blue[600]),
                    const SizedBox(width: 4),
                    Text(
                      'Click any address to populate fields',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.blue[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: _suggestions.length,
                  itemBuilder: (context, index) {
                    final suggestion = _suggestions[index];
                    return Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey[200]!,
                            width: 0.5,
                          ),
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: kIsWeb 
                          ? GestureDetector(
                              onTap: () {
                                print('🎯 WEB-TAP: User tapped suggestion "${suggestion.description}"');
                                _handleSuggestionSelection(suggestion);
                              },
                              child: _buildSuggestionContent(suggestion, index),
                            )
                          : InkWell(
                              onTap: () {
                                print('🎯 MOBILE-TAP: User tapped suggestion "${suggestion.description}"');
                                _handleSuggestionSelection(suggestion);
                              },
                              child: _buildSuggestionContent(suggestion, index),
                            ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionContent(PlacePrediction suggestion, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.blue[100],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Icon(
            Icons.location_on,
            color: Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  suggestion.mainText ?? suggestion.description ?? '',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (suggestion.secondaryText != null)
                  Text(
                    suggestion.secondaryText!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 12,
            color: Colors.grey[400],
          ),
        ],
      ),
    );
  }
}