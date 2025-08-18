import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Breakpoints for responsive design
class AppBreakpoints {
  static const double mobile = 480;
  static const double tablet = 768;
  static const double desktop = 1024;
  static const double largeDesktop = 1440;
}

/// Responsive layout widget that adapts to different screen sizes
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  final double mobileBreakpoint;
  final double tabletBreakpoint;
  final double desktopBreakpoint;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.mobileBreakpoint = AppBreakpoints.mobile,
    this.tabletBreakpoint = AppBreakpoints.tablet,
    this.desktopBreakpoint = AppBreakpoints.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        
        if (width >= desktopBreakpoint && desktop != null) {
          return desktop!;
        } else if (width >= tabletBreakpoint && tablet != null) {
          return tablet!;
        } else {
          return mobile;
        }
      },
    );
  }

  /// Static method to get current screen type
  static ScreenType getScreenType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width >= AppBreakpoints.desktop) {
      return ScreenType.desktop;
    } else if (width >= AppBreakpoints.tablet) {
      return ScreenType.tablet;
    } else {
      return ScreenType.mobile;
    }
  }

  /// Static method to check if current screen is mobile
  static bool isMobile(BuildContext context) {
    return getScreenType(context) == ScreenType.mobile;
  }

  /// Static method to check if current screen is tablet
  static bool isTablet(BuildContext context) {
    return getScreenType(context) == ScreenType.tablet;
  }

  /// Static method to check if current screen is desktop
  static bool isDesktop(BuildContext context) {
    return getScreenType(context) == ScreenType.desktop;
  }
}

enum ScreenType {
  mobile,
  tablet,
  desktop,
}

/// Responsive padding that adapts to screen size
class ResponsivePadding extends StatelessWidget {
  final Widget child;
  final EdgeInsets mobilePadding;
  final EdgeInsets? tabletPadding;
  final EdgeInsets? desktopPadding;

  const ResponsivePadding({
    super.key,
    required this.child,
    this.mobilePadding = const EdgeInsets.all(16),
    this.tabletPadding,
    this.desktopPadding,
  });

  @override
  Widget build(BuildContext context) {
    final screenType = ResponsiveLayout.getScreenType(context);
    
    EdgeInsets padding;
    switch (screenType) {
      case ScreenType.desktop:
        padding = desktopPadding ?? tabletPadding ?? mobilePadding;
        break;
      case ScreenType.tablet:
        padding = tabletPadding ?? mobilePadding;
        break;
      case ScreenType.mobile:
        padding = mobilePadding;
        break;
    }

    return Padding(
      padding: padding,
      child: child,
    );
  }
}

/// Responsive spacing widget
class ResponsiveSpacing extends StatelessWidget {
  final double mobileSpacing;
  final double? tabletSpacing;
  final double? desktopSpacing;
  final Axis axis;

  const ResponsiveSpacing({
    super.key,
    required this.mobileSpacing,
    this.tabletSpacing,
    this.desktopSpacing,
    this.axis = Axis.vertical,
  });

  @override
  Widget build(BuildContext context) {
    final screenType = ResponsiveLayout.getScreenType(context);
    
    double spacing;
    switch (screenType) {
      case ScreenType.desktop:
        spacing = desktopSpacing ?? tabletSpacing ?? mobileSpacing;
        break;
      case ScreenType.tablet:
        spacing = tabletSpacing ?? mobileSpacing;
        break;
      case ScreenType.mobile:
        spacing = mobileSpacing;
        break;
    }

    return SizedBox(
      width: axis == Axis.horizontal ? spacing : null,
      height: axis == Axis.vertical ? spacing : null,
    );
  }
}

/// Responsive grid that adapts column count based on screen size
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int mobileColumns;
  final int? tabletColumns;
  final int? desktopColumns;
  final double spacing;
  final double runSpacing;
  final double childAspectRatio;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.mobileColumns = 1,
    this.tabletColumns,
    this.desktopColumns,
    this.spacing = 16,
    this.runSpacing = 16,
    this.childAspectRatio = 1,
  });

  @override
  Widget build(BuildContext context) {
    final screenType = ResponsiveLayout.getScreenType(context);
    
    int columns;
    switch (screenType) {
      case ScreenType.desktop:
        columns = desktopColumns ?? tabletColumns ?? mobileColumns;
        break;
      case ScreenType.tablet:
        columns = tabletColumns ?? mobileColumns;
        break;
      case ScreenType.mobile:
        columns = mobileColumns;
        break;
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: spacing,
        mainAxisSpacing: runSpacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }
}

/// Responsive text that scales based on screen size
class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final double? mobileScale;
  final double? tabletScale;
  final double? desktopScale;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const ResponsiveText(
    this.text, {
    super.key,
    required this.style,
    this.mobileScale = 1.0,
    this.tabletScale = 1.1,
    this.desktopScale = 1.2,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    final screenType = ResponsiveLayout.getScreenType(context);
    
    double scale;
    switch (screenType) {
      case ScreenType.desktop:
        scale = desktopScale ?? tabletScale ?? mobileScale ?? 1.0;
        break;
      case ScreenType.tablet:
        scale = tabletScale ?? mobileScale ?? 1.0;
        break;
      case ScreenType.mobile:
        scale = mobileScale ?? 1.0;
        break;
    }

    return Text(
      text,
      style: style.copyWith(
        fontSize: (style.fontSize ?? 14) * scale,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// Responsive container with adaptive width constraints
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double? mobileMaxWidth;
  final double? tabletMaxWidth;
  final double? desktopMaxWidth;
  final EdgeInsets? padding;
  final bool centerContent;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.mobileMaxWidth,
    this.tabletMaxWidth = 768,
    this.desktopMaxWidth = 1200,
    this.padding,
    this.centerContent = true,
  });

  @override
  Widget build(BuildContext context) {
    final screenType = ResponsiveLayout.getScreenType(context);
    
    double? maxWidth;
    switch (screenType) {
      case ScreenType.desktop:
        maxWidth = desktopMaxWidth;
        break;
      case ScreenType.tablet:
        maxWidth = tabletMaxWidth;
        break;
      case ScreenType.mobile:
        maxWidth = mobileMaxWidth;
        break;
    }

    Widget content = child;
    
    if (maxWidth != null) {
      content = ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: content,
      );
    }

    if (padding != null) {
      content = Padding(
        padding: padding!,
        child: content,
      );
    }

    if (centerContent) {
      content = Center(child: content);
    }

    return content;
  }
}

/// Utility functions for responsive design
class ResponsiveUtils {
  /// Get responsive value based on screen size
  static T getResponsiveValue<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    final screenType = ResponsiveLayout.getScreenType(context);
    
    switch (screenType) {
      case ScreenType.desktop:
        return desktop ?? tablet ?? mobile;
      case ScreenType.tablet:
        return tablet ?? mobile;
      case ScreenType.mobile:
        return mobile;
    }
  }

  /// Get responsive font size
  static double getResponsiveFontSize(
    BuildContext context,
    double baseFontSize,
  ) {
    final screenType = ResponsiveLayout.getScreenType(context);
    
    switch (screenType) {
      case ScreenType.desktop:
        return baseFontSize * 1.2;
      case ScreenType.tablet:
        return baseFontSize * 1.1;
      case ScreenType.mobile:
        return baseFontSize;
    }
  }

  /// Get responsive spacing
  static double getResponsiveSpacing(
    BuildContext context,
    double baseSpacing,
  ) {
    final screenType = ResponsiveLayout.getScreenType(context);
    
    switch (screenType) {
      case ScreenType.desktop:
        return baseSpacing * 1.5;
      case ScreenType.tablet:
        return baseSpacing * 1.25;
      case ScreenType.mobile:
        return baseSpacing;
    }
  }

  /// Get responsive border radius
  static double getResponsiveBorderRadius(
    BuildContext context,
    double baseBorderRadius,
  ) {
    final screenType = ResponsiveLayout.getScreenType(context);
    
    switch (screenType) {
      case ScreenType.desktop:
        return baseBorderRadius * 1.2;
      case ScreenType.tablet:
        return baseBorderRadius * 1.1;
      case ScreenType.mobile:
        return baseBorderRadius;
    }
  }
}