import 'package:flutter/material.dart';

// Placeholder widget - Cart functionality replaced by direct order placement
class CartItemWidget extends StatelessWidget {
  final dynamic item; // Accept any type to avoid compilation errors
  final VoidCallback? onRemove;
  final Function(int)? onQuantityChanged;
  final Function(String)? onInstructionsChanged;

  const CartItemWidget({
    super.key,
    this.item,
    this.onRemove,
    this.onQuantityChanged,
    this.onInstructionsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}