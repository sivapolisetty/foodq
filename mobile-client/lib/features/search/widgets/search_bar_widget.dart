import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class SearchBarWidget extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onSearch;
  final bool isLoading;
  final String hintText;
  final VoidCallback? onClear;

  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.onSearch,
    this.isLoading = false,
    this.hintText = 'Search...',
    this.onClear,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _performSearch() {
    final query = widget.controller.text.trim();
    if (query.isNotEmpty) {
      _focusNode.unfocus();
      widget.onSearch(query);
    }
  }

  void _clearSearch() {
    widget.controller.clear();
    if (widget.onClear != null) {
      widget.onClear!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [AppTheme.subtleShadow],
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(
            color: Colors.grey[500],
            fontSize: 16,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: AppTheme.primaryGreen,
            size: 24,
          ),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.isLoading)
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              else if (widget.controller.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: _clearSearch,
                  color: Colors.grey[500],
                ),
              Container(
                margin: const EdgeInsets.only(right: 8),
                child: IconButton(
                  onPressed: widget.isLoading ? null : _performSearch,
                  icon: Icon(
                    Icons.arrow_forward,
                    color: widget.isLoading ? Colors.grey : AppTheme.primaryGreen,
                  ),
                ),
              ),
            ],
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        textInputAction: TextInputAction.search,
        onSubmitted: (_) => _performSearch(),
      ),
    );
  }
}