import 'package:flutter/material.dart';

class MotorsportColors {
  static const asphalt = Color(0xFF101114);
  static const asphaltLight = Color(0xFF1A1C21);
  static const carbon = Color(0xFF24272E);
  static const pitRed = Color(0xFFE10600);
  static const racingYellow = Color(0xFFFFC400);
  static const white = Color(0xFFF6F7F9);
  static const muted = Color(0xFFA7ADB8);
}

ThemeData buildMotorsportTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: MotorsportColors.pitRed,
    brightness: Brightness.dark,
    primary: MotorsportColors.pitRed,
    secondary: MotorsportColors.racingYellow,
    surface: MotorsportColors.asphaltLight,
  );

  return ThemeData(
    colorScheme: colorScheme,
    scaffoldBackgroundColor: MotorsportColors.asphalt,
    useMaterial3: true,
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      backgroundColor: MotorsportColors.asphalt,
      foregroundColor: MotorsportColors.white,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: MotorsportColors.white,
        fontSize: 22,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.3,
      ),
    ),
    cardTheme: CardThemeData(
      color: MotorsportColors.asphaltLight,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: const BorderSide(color: Color(0xFF30343D)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: MotorsportColors.pitRed,
        foregroundColor: MotorsportColors.white,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontWeight: FontWeight.w800),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: MotorsportColors.white,
        side: const BorderSide(color: MotorsportColors.pitRed, width: 1.4),
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: MotorsportColors.pitRed,
      foregroundColor: MotorsportColors.white,
      extendedTextStyle: TextStyle(fontWeight: FontWeight.w800),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: MotorsportColors.carbon,
      labelStyle: const TextStyle(color: MotorsportColors.muted),
      hintStyle: const TextStyle(color: Color(0xFF7D8490)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFF383D47)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: MotorsportColors.pitRed,
          width: 1.8,
        ),
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: MotorsportColors.carbon,
      selectedColor: MotorsportColors.pitRed,
      labelStyle: const TextStyle(color: MotorsportColors.white),
      side: const BorderSide(color: Color(0xFF383D47)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return MotorsportColors.pitRed;
          }
          return MotorsportColors.carbon;
        }),
        foregroundColor: WidgetStateProperty.all(MotorsportColors.white),
        side: WidgetStateProperty.all(
          const BorderSide(color: Color(0xFF383D47)),
        ),
      ),
    ),
    textTheme:
        const TextTheme(
          headlineSmall: TextStyle(fontWeight: FontWeight.w900),
          titleLarge: TextStyle(fontWeight: FontWeight.w900),
          titleMedium: TextStyle(fontWeight: FontWeight.w800),
          labelLarge: TextStyle(
            fontWeight: FontWeight.w800,
            letterSpacing: 0.4,
          ),
        ).apply(
          bodyColor: MotorsportColors.white,
          displayColor: MotorsportColors.white,
        ),
  );
}

class RaceScaffoldBackground extends StatelessWidget {
  const RaceScaffoldBackground({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF17191F), MotorsportColors.asphalt],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -120,
            right: -80,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: MotorsportColors.pitRed.withValues(alpha: 0.18),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class RaceHeader extends StatelessWidget {
  const RaceHeader({
    required this.title,
    required this.subtitle,
    this.icon = Icons.sports_motorsports_outlined,
    super.key,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF2A2E36), Color(0xFF17191F)],
        ),
        border: Border.all(color: const Color(0xFF363B45)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: MotorsportColors.pitRed,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: MotorsportColors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: MotorsportColors.muted,
                  ),
                ),
              ],
            ),
          ),
          const RacingStripes(),
        ],
      ),
    );
  }
}

class RacingStripes extends StatelessWidget {
  const RacingStripes({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 52,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: const [
          _Stripe(color: MotorsportColors.pitRed),
          SizedBox(width: 4),
          _Stripe(color: MotorsportColors.white),
          SizedBox(width: 4),
          _Stripe(color: MotorsportColors.racingYellow),
        ],
      ),
    );
  }
}

class _Stripe extends StatelessWidget {
  const _Stripe({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(99),
      ),
    );
  }
}
