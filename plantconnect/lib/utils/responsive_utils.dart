import 'package:flutter/material.dart';

/// Utility class for responsive design helpers
class ResponsiveUtils {
  /// Detects if the device is a tablet (width > 600)
  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width > 600;
  }

  /// Detects if the device is in landscape orientation
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// Detects if the device is in portrait orientation
  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  /// Gets the screen width
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Gets the screen height
  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// Returns responsive padding based on screen size
  static EdgeInsets responsivePadding(BuildContext context) {
    final isMobile = !isTablet(context);
    return EdgeInsets.all(isMobile ? 16.0 : 24.0);
  }

  /// Returns responsive font size based on screen size
  static double responsiveFontSize(
    BuildContext context, {
    required double mobileSize,
    required double tabletSize,
  }) {
    return isTablet(context) ? tabletSize : mobileSize;
  }

  /// Returns grid columns based on device type
  static int getGridColumns(double screenWidth) {
    if (screenWidth < 600) {
      return 1;
    } else if (screenWidth < 900) {
      return 2;
    } else {
      return 3;
    }
  }

  /// Returns the device type as a string
  static String getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) {
      return 'Phone';
    } else if (width < 1200) {
      return 'Tablet';
    } else {
      return 'Desktop';
    }
  }

  /// Checks if keyboard is visible
  static bool isKeyboardVisible(BuildContext context) {
    return MediaQuery.of(context).viewInsets.bottom > 0;
  }

  /// Gets the safe area padding
  static EdgeInsets getSafeAreaPadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }

  /// Returns text scale factor
  static double getTextScaleFactor(BuildContext context) {
    return MediaQuery.of(context).textScaleFactor;
  }
}

/// Breakpoint constants for responsive design
class ResponsiveBreakpoints {
  // Mobile breakpoint
  static const double mobile = 0;

  // Tablet breakpoint
  static const double tablet = 600;

  // Large tablet / small desktop
  static const double large = 900;

  // Desktop breakpoint
  static const double desktop = 1200;
}

/// Responsive sizes constants
class ResponsiveSizes {
  // Padding sizes
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  // Border radius
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;

  // Icon sizes
  static const double iconSmall = 20.0;
  static const double iconMedium = 24.0;
  static const double iconLarge = 32.0;

  // Font sizes for mobile
  static const double fontSizeSmallMobile = 12.0;
  static const double fontSizeMediumMobile = 14.0;
  static const double fontSizeLargeMobile = 16.0;
  static const double fontSizeXLargeMobile = 20.0;
  static const double fontSizeHeadingMobile = 24.0;

  // Font sizes for tablet
  static const double fontSizeSmallTablet = 14.0;
  static const double fontSizeMediumTablet = 16.0;
  static const double fontSizeLargeTablet = 18.0;
  static const double fontSizeXLargeTablet = 22.0;
  static const double fontSizeHeadingTablet = 28.0;
}
