import 'package:flutter/material.dart';

class YindiiAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final Color? backgroundColor;
  final Color? titleColor;
  final double elevation;
  final VoidCallback? onBackPressed;
  final bool showPolkaDots;

  const YindiiAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.backgroundColor,
    this.titleColor,
    this.elevation = 0,
    this.onBackPressed,
    this.showPolkaDots = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? const Color(0xFF2E7D32),
        // Yindii-style polka dot pattern (optional)
        image: showPolkaDots ? const DecorationImage(
          image: AssetImage('assets/images/polka_dots_pattern.png'),
          repeat: ImageRepeat.repeat,
          opacity: 0.1,
        ) : null,
      ),
      child: AppBar(
        title: Text(
          title,
          style: TextStyle(
            color: titleColor ?? Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: centerTitle,
        backgroundColor: Colors.transparent,
        elevation: elevation,
        leading: leading ?? (Navigator.canPop(context) 
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: onBackPressed ?? () => Navigator.pop(context),
              )
            : null),
        actions: actions,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class YindiiSliverAppBar extends StatelessWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final Color? backgroundColor;
  final Color? titleColor;
  final double expandedHeight;
  final Widget? flexibleSpace;
  final bool pinned;
  final bool floating;
  final VoidCallback? onBackPressed;

  const YindiiSliverAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.backgroundColor,
    this.titleColor,
    this.expandedHeight = 200.0,
    this.flexibleSpace,
    this.pinned = true,
    this.floating = false,
    this.onBackPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      title: Text(
        title,
        style: TextStyle(
          color: titleColor ?? Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? const Color(0xFF2E7D32),
      expandedHeight: expandedHeight,
      pinned: pinned,
      floating: floating,
      leading: leading ?? (Navigator.canPop(context) 
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: onBackPressed ?? () => Navigator.pop(context),
            )
          : null),
      actions: actions,
      iconTheme: const IconThemeData(color: Colors.white),
      flexibleSpace: flexibleSpace ?? FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                backgroundColor ?? const Color(0xFF2E7D32),
                (backgroundColor ?? const Color(0xFF2E7D32)).withOpacity(0.8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}