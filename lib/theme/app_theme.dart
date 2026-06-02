import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';

const String _outfit = 'Outfit';

abstract final class AppRadius {
  static const double small = 8.0;
  static const double medium = 12.0;
  static const double large = 14.0;
  static const double xl = 20.0;
  static const double full = 9999.0;
}

abstract final class AppShadows {
  static const BoxShadow small = BoxShadow(
    color: Color(0x14000000),
    blurRadius: 4,
    offset: Offset(0, 2),
  );
  static List<BoxShadow> get medium => [
        const BoxShadow(color: Color(0x1A000000), blurRadius: 8, offset: Offset(0, 4)),
        const BoxShadow(color: Color(0x0A000000), blurRadius: 2, offset: Offset(0, 1)),
      ];
  static List<BoxShadow> get large => [
        const BoxShadow(color: Color(0x1F000000), blurRadius: 20, offset: Offset(0, 8)),
        const BoxShadow(color: Color(0x0A000000), blurRadius: 4, offset: Offset(0, 2)),
      ];
}

abstract final class AppTheme {
  static ThemeData get light => _buildTheme(
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: AppColors.primary,
          onPrimary: Colors.white,
          primaryContainer: AppColors.primary50,
          onPrimaryContainer: AppColors.primary900,
          secondary: AppColors.secondary,
          onSecondary: Colors.white,
          secondaryContainer: AppColors.secondary50,
          onSecondaryContainer: AppColors.secondary900,
          tertiary: AppColors.success,
          onTertiary: Colors.white,
          tertiaryContainer: AppColors.success50,
          onTertiaryContainer: AppColors.successForeground,
          error: AppColors.danger,
          onError: Colors.white,
          errorContainer: AppColors.danger50,
          onErrorContainer: AppColors.dangerForeground,
          surface: AppColors.background,
          onSurface: AppColors.foreground,
          surfaceContainerHighest: AppColors.content2,
          onSurfaceVariant: AppColors.defaultGray,
          outline: AppColors.content3,
          outlineVariant: AppColors.divider,
          shadow: Colors.black,
          scrim: Color(0x80000000),
          inverseSurface: AppColors.gray900,
          onInverseSurface: AppColors.gray100,
          inversePrimary: AppColors.primary200,
        ),
        scaffoldBg: AppColors.background,
        cardBg: AppColors.content1,
        cardBorder: AppColors.content3,
        inputFill: AppColors.content2,
        inputBorder: AppColors.content3,
        appBarBg: AppColors.background,
        appBarFg: AppColors.foreground,
        navBg: AppColors.background,
        selectedNav: AppColors.primary,
        unselectedNav: AppColors.gray500,
        navIndicator: AppColors.primary50,
        dividerColor: AppColors.divider,
        hintColor: AppColors.defaultGray,
        statusBarBrightness: Brightness.dark,
      );

  static ThemeData get dark => _buildTheme(
        colorScheme: const ColorScheme(
          brightness: Brightness.dark,
          primary: AppColors.primary,
          onPrimary: Colors.white,
          primaryContainer: AppColors.primary800,
          onPrimaryContainer: AppColors.primary100,
          secondary: AppColors.secondary,
          onSecondary: Colors.white,
          secondaryContainer: AppColors.secondary800,
          onSecondaryContainer: AppColors.secondary100,
          tertiary: AppColors.success,
          onTertiary: Colors.white,
          tertiaryContainer: AppColors.successForeground,
          onTertiaryContainer: AppColors.success50,
          error: AppColors.danger,
          onError: Colors.white,
          errorContainer: AppColors.dangerForeground,
          onErrorContainer: AppColors.danger50,
          surface: AppColors.darkBackground,
          onSurface: AppColors.darkForeground,
          surfaceContainerHighest: AppColors.darkContent2,
          onSurfaceVariant: AppColors.gray400,
          outline: AppColors.darkContent3,
          outlineVariant: AppColors.darkContent2,
          shadow: Colors.black,
          scrim: Color(0x80000000),
          inverseSurface: AppColors.gray100,
          onInverseSurface: AppColors.gray900,
          inversePrimary: AppColors.primary700,
        ),
        scaffoldBg: AppColors.darkBackground,
        cardBg: AppColors.darkContent1,
        cardBorder: AppColors.darkContent3,
        inputFill: AppColors.darkContent1,
        inputBorder: AppColors.darkContent3,
        appBarBg: AppColors.darkContent1,
        appBarFg: AppColors.darkForeground,
        navBg: AppColors.darkContent1,
        selectedNav: AppColors.primary,
        unselectedNav: AppColors.gray500,
        navIndicator: AppColors.primary900,
        dividerColor: AppColors.darkDivider,
        hintColor: AppColors.gray500,
        statusBarBrightness: Brightness.light,
      );

  static ThemeData _buildTheme({
    required ColorScheme colorScheme,
    required Color scaffoldBg,
    required Color cardBg,
    required Color cardBorder,
    required Color inputFill,
    required Color inputBorder,
    required Color appBarBg,
    required Color appBarFg,
    required Color navBg,
    required Color selectedNav,
    required Color unselectedNav,
    required Color navIndicator,
    required Color dividerColor,
    required Color hintColor,
    required Brightness statusBarBrightness,
  }) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: _outfit,
      textTheme: _buildTextTheme(colorScheme.onSurface),
      scaffoldBackgroundColor: scaffoldBg,

      appBarTheme: AppBarTheme(
        backgroundColor: appBarBg,
        foregroundColor: appBarFg,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: statusBarBrightness,
        ),
        titleTextStyle: TextStyle(
          fontFamily: _outfit,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: appBarFg,
        ),
        iconTheme: IconThemeData(color: appBarFg),
        actionsIconTheme: IconThemeData(color: appBarFg),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          disabledBackgroundColor: colorScheme.primary.withValues(alpha: 0.5),
          disabledForegroundColor: colorScheme.onPrimary.withValues(alpha: 0.7),
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          minimumSize: const Size(64, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
          textStyle: const TextStyle(
            fontFamily: _outfit,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          minimumSize: const Size(64, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
          textStyle: const TextStyle(
            fontFamily: _outfit,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.small),
          ),
          textStyle: const TextStyle(
            fontFamily: _outfit,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.secondary,
          foregroundColor: colorScheme.onSecondary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          minimumSize: const Size(64, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
          textStyle: const TextStyle(
            fontFamily: _outfit,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
      ),

      cardTheme: CardThemeData(
        color: cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.large),
          side: BorderSide(color: cardBorder),
        ),
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputFill,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: BorderSide(color: inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: BorderSide(color: inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        hintStyle: TextStyle(
          fontFamily: _outfit,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: hintColor,
        ),
        labelStyle: TextStyle(
          fontFamily: _outfit,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: hintColor,
        ),
        floatingLabelStyle: TextStyle(
          fontFamily: _outfit,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: colorScheme.primary,
        ),
        errorStyle: TextStyle(
          fontFamily: _outfit,
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: colorScheme.error,
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerHighest,
        selectedColor: colorScheme.primaryContainer,
        disabledColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        labelStyle: TextStyle(
          fontFamily: _outfit,
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        ),
        secondaryLabelStyle: TextStyle(
          fontFamily: _outfit,
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: colorScheme.primary,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        side: BorderSide.none,
        elevation: 0,
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: navBg,
        indicatorColor: navIndicator,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black.withValues(alpha: 0.06),
        elevation: 8,
        height: 64,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          return IconThemeData(
            color: states.contains(WidgetState.selected) ? selectedNav : unselectedNav,
            size: 24,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return TextStyle(
            fontFamily: _outfit,
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected) ? FontWeight.w600 : FontWeight.w400,
            color: states.contains(WidgetState.selected) ? selectedNav : unselectedNav,
          );
        }),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: navBg,
        selectedItemColor: selectedNav,
        unselectedItemColor: unselectedNav,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(fontFamily: _outfit, fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontFamily: _outfit, fontSize: 12, fontWeight: FontWeight.w400),
      ),

      dividerTheme: DividerThemeData(color: dividerColor, thickness: 1, space: 1),

      dialogTheme: DialogThemeData(
        backgroundColor: cardBg,
        elevation: 8,
        shadowColor: Colors.black.withValues(alpha: 0.12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        titleTextStyle: TextStyle(
          fontFamily: _outfit,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
        contentTextStyle: TextStyle(
          fontFamily: _outfit,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: colorScheme.onSurfaceVariant,
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: TextStyle(
          fontFamily: _outfit,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: colorScheme.onInverseSurface,
        ),
        actionTextColor: colorScheme.inversePrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.medium)),
        behavior: SnackBarBehavior.floating,
        elevation: 4,
      ),

      tabBarTheme: TabBarThemeData(
        labelColor: colorScheme.primary,
        unselectedLabelColor: hintColor,
        indicatorColor: colorScheme.primary,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: dividerColor,
        labelStyle: const TextStyle(fontFamily: _outfit, fontSize: 14, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontFamily: _outfit, fontSize: 14, fontWeight: FontWeight.w400),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected) ? Colors.white : colorScheme.outline),
        trackColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected) ? colorScheme.primary : colorScheme.surfaceContainerHighest),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),

      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected) ? colorScheme.primary : Colors.transparent),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: BorderSide(color: colorScheme.outline, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),

      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected) ? colorScheme.primary : hintColor),
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        linearTrackColor: colorScheme.primaryContainer,
        circularTrackColor: colorScheme.primaryContainer,
        linearMinHeight: 4,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 4,
        focusElevation: 6,
        hoverElevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.large)),
      ),

      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        minVerticalPadding: 12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.small)),
        titleTextStyle: TextStyle(
          fontFamily: _outfit,
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        ),
        subtitleTextStyle: TextStyle(
          fontFamily: _outfit,
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: hintColor,
        ),
        leadingAndTrailingTextStyle: TextStyle(
          fontFamily: _outfit,
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: hintColor,
        ),
      ),

      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: colorScheme.inverseSurface.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(AppRadius.small),
        ),
        textStyle: TextStyle(
          fontFamily: _outfit,
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: colorScheme.onInverseSurface,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: cardBg,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        ),
        modalElevation: 16,
        dragHandleColor: dividerColor,
        dragHandleSize: const Size(40, 4),
      ),

      popupMenuTheme: PopupMenuThemeData(
        color: cardBg,
        elevation: 8,
        shadowColor: Colors.black.withValues(alpha: 0.12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.medium)),
        textStyle: TextStyle(
          fontFamily: _outfit,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: colorScheme.onSurface,
        ),
        labelTextStyle: WidgetStateProperty.all(
          TextStyle(fontFamily: _outfit, fontSize: 14, fontWeight: FontWeight.w400, color: colorScheme.onSurface),
        ),
      ),

      badgeTheme: BadgeThemeData(
        backgroundColor: colorScheme.primary,
        textColor: colorScheme.onPrimary,
        textStyle: const TextStyle(fontFamily: _outfit, fontSize: 10, fontWeight: FontWeight.w600),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      ),

      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          backgroundColor: colorScheme.surfaceContainerHighest,
          foregroundColor: colorScheme.onSurface,
          selectedBackgroundColor: colorScheme.primary,
          selectedForegroundColor: colorScheme.onPrimary,
          side: BorderSide(color: dividerColor),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.small)),
          textStyle: const TextStyle(fontFamily: _outfit, fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  static TextTheme _buildTextTheme(Color c) => TextTheme(
        displayLarge: TextStyle(fontFamily: _outfit, fontSize: 57, fontWeight: FontWeight.w700, letterSpacing: -0.25, color: c),
        displayMedium: TextStyle(fontFamily: _outfit, fontSize: 45, fontWeight: FontWeight.w700, color: c),
        displaySmall: TextStyle(fontFamily: _outfit, fontSize: 36, fontWeight: FontWeight.w600, color: c),
        headlineLarge: TextStyle(fontFamily: _outfit, fontSize: 32, fontWeight: FontWeight.w600, color: c),
        headlineMedium: TextStyle(fontFamily: _outfit, fontSize: 28, fontWeight: FontWeight.w600, color: c),
        headlineSmall: TextStyle(fontFamily: _outfit, fontSize: 24, fontWeight: FontWeight.w600, color: c),
        titleLarge: TextStyle(fontFamily: _outfit, fontSize: 22, fontWeight: FontWeight.w600, color: c),
        titleMedium: TextStyle(fontFamily: _outfit, fontSize: 16, fontWeight: FontWeight.w500, letterSpacing: 0.15, color: c),
        titleSmall: TextStyle(fontFamily: _outfit, fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1, color: c),
        bodyLarge: TextStyle(fontFamily: _outfit, fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 0.5, color: c),
        bodyMedium: TextStyle(fontFamily: _outfit, fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: 0.25, color: c),
        bodySmall: TextStyle(fontFamily: _outfit, fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 0.4, color: c),
        labelLarge: TextStyle(fontFamily: _outfit, fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.1, color: c),
        labelMedium: TextStyle(fontFamily: _outfit, fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.5, color: c),
        labelSmall: TextStyle(fontFamily: _outfit, fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.5, color: c),
      );
}
