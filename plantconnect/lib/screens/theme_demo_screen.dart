import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

/// Module 3.46 — Themed UI Demo Screen
///
/// Shows:
///   - Theme toggle switch (dark ↔ light)
///   - ThemeMode selector (system / light / dark)
///   - Live colour palette from the active theme
///   - Real widget samples that react to the active theme
///   - Persistence note (SharedPreferences)
class ThemeDemoScreen extends StatelessWidget {
  const ThemeDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final cs = Theme.of(context).colorScheme;
    final isDark = theme.isDark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dark Mode & Theming'),
        // AppBar colour comes entirely from the active ThemeData
        actions: [
          // Quick toggle directly in AppBar
          Transform.scale(
            scale: 0.85,
            child: Switch(
              value: theme.mode == ThemeMode.dark,
              onChanged: (v) => context.read<ThemeProvider>().toggleTheme(v),
              thumbIcon: WidgetStateProperty.resolveWith(
                (states) => Icon(
                  states.contains(WidgetState.selected)
                      ? Icons.dark_mode
                      : Icons.light_mode,
                  size: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Mode indicator ──────────────────────────────────────────
            _ModeCard(currentMode: theme.mode),
            const SizedBox(height: 20),

            // ── Toggle switch ───────────────────────────────────────────
            _SectionLabel('Toggle Theme'),
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Icon(Icons.light_mode, color: cs.primary),
                    const SizedBox(width: 12),
                    const Text('Light', style: TextStyle(fontSize: 15)),
                    const Spacer(),
                    Switch(
                      value: isDark,
                      onChanged: (v) =>
                          context.read<ThemeProvider>().toggleTheme(v),
                    ),
                    const Text('Dark', style: TextStyle(fontSize: 15)),
                    const SizedBox(width: 12),
                    Icon(Icons.dark_mode, color: cs.primary),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── ThemeMode selector (system / light / dark) ──────────────
            _SectionLabel('Theme Mode'),
            const SizedBox(height: 10),
            Card(
              child: Column(
                children: [
                  _ThemeModeOption(
                    label: 'System (follows device)',
                    icon: Icons.phone_android,
                    value: ThemeMode.system,
                    current: theme.mode,
                    onSelect: (m) =>
                        context.read<ThemeProvider>().setThemeMode(m),
                  ),
                  _ThemeModeOption(
                    label: 'Light Mode',
                    icon: Icons.wb_sunny_outlined,
                    value: ThemeMode.light,
                    current: theme.mode,
                    onSelect: (m) =>
                        context.read<ThemeProvider>().setThemeMode(m),
                  ),
                  _ThemeModeOption(
                    label: 'Dark Mode',
                    icon: Icons.nightlight_outlined,
                    value: ThemeMode.dark,
                    current: theme.mode,
                    onSelect: (m) =>
                        context.read<ThemeProvider>().setThemeMode(m),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Live colour palette ─────────────────────────────────────
            _SectionLabel('Active Colour Palette'),
            const SizedBox(height: 10),
            _ColorPalette(cs: cs),
            const SizedBox(height: 20),

            // ── Widget samples that use theme colours ───────────────────
            _SectionLabel('Theme-Aware Widgets'),
            const SizedBox(height: 10),
            _WidgetShowcase(cs: cs),
            const SizedBox(height: 20),

            // ── Persistence note ────────────────────────────────────────
            _ConceptCard(
              icon: Icons.save_outlined,
              title: 'Persisted via SharedPreferences',
              body: 'Your choice is saved locally — restart the app and the '
                  'same theme will be applied automatically.\n\n'
                  'Key: "theme_mode"  |  Values: "light", "dark", "system"',
            ),
            const SizedBox(height: 20),

            // ── Best practices ──────────────────────────────────────────
            _ConceptCard(
              icon: Icons.tips_and_updates_outlined,
              title: 'Best Practices',
              body: '• Never hard-code colours — use Theme.of(context).colorScheme\n'
                  '• Use ColorScheme.fromSeed() for consistent Material 3 palettes\n'
                  '• Put theme definitions in a separate file (app_themes.dart)\n'
                  '• Provide system / light / dark options to users\n'
                  '• ThemeProvider must wrap MaterialApp (at the root)',
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Mode card at the top
// ─────────────────────────────────────────────────────────────────────────────
class _ModeCard extends StatelessWidget {
  final ThemeMode currentMode;
  const _ModeCard({required this.currentMode});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final (label, emoji) = switch (currentMode) {
      ThemeMode.dark => ('Dark Mode', '🌙'),
      ThemeMode.light => ('Light Mode', '☀️'),
      ThemeMode.system => ('System Default', '📱'),
      _ => ('Unknown', '?'),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cs.primary, cs.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 40)),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Currently: $label',
                  style: TextStyle(
                    color: cs.onPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  )),
              Text('Tap the switch or selector below to change',
                  style: TextStyle(
                    color: cs.onPrimary.withOpacity(0.75),
                    fontSize: 12,
                  )),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ThemeMode radio row
// ─────────────────────────────────────────────────────────────────────────────
class _ThemeModeOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final ThemeMode value;
  final ThemeMode current;
  final ValueChanged<ThemeMode> onSelect;

  const _ThemeModeOption({
    required this.label,
    required this.icon,
    required this.value,
    required this.current,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final selected = value == current;
    final cs = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(icon, color: selected ? cs.primary : null),
      title: Text(label,
          style: TextStyle(
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            color: selected ? cs.primary : null,
          )),
      trailing: selected
          ? Icon(Icons.check_circle, color: cs.primary)
          : const Icon(Icons.radio_button_unchecked, color: Colors.grey),
      onTap: () => onSelect(value),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Colour palette swatches from the active ColorScheme
// ─────────────────────────────────────────────────────────────────────────────
class _ColorPalette extends StatelessWidget {
  final ColorScheme cs;
  const _ColorPalette({required this.cs});

  @override
  Widget build(BuildContext context) {
    final swatches = [
      (cs.primary, 'primary', cs.onPrimary),
      (cs.secondary, 'secondary', cs.onSecondary),
      (cs.tertiary, 'tertiary', cs.onTertiary),
      (cs.surface, 'surface', cs.onSurface),
      (cs.error, 'error', cs.onError),
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: swatches
          .map(
            (s) => Container(
              width: (MediaQuery.sizeOf(context).width - 52) / 5,
              height: 64,
              decoration: BoxDecoration(
                color: s.$1,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              alignment: Alignment.center,
              child: Text(
                s.$2,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: s.$3,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widgets that auto-adopt the active theme
// ─────────────────────────────────────────────────────────────────────────────
class _WidgetShowcase extends StatelessWidget {
  final ColorScheme cs;
  const _WidgetShowcase({required this.cs});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Buttons
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.eco, size: 16),
                  label: const Text('Elevated'),
                ),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.star_outline, size: 16),
                  label: const Text('Outlined'),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('Text Button'),
                ),
              ],
            ),
            const Divider(height: 24),

            // Chip
            Wrap(
              spacing: 8,
              children: [
                Chip(
                  label: const Text('Rose'),
                  avatar: const Text('🌹'),
                  backgroundColor: cs.primaryContainer,
                  labelStyle: TextStyle(color: cs.onPrimaryContainer),
                ),
                Chip(
                  label: const Text('Cactus'),
                  avatar: const Text('🌵'),
                  backgroundColor: cs.secondaryContainer,
                  labelStyle: TextStyle(color: cs.onSecondaryContainer),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Progress indicator
            LinearProgressIndicator(
              value: 0.65,
              backgroundColor: cs.surfaceContainerHighest,
              color: cs.primary,
              borderRadius: BorderRadius.circular(4),
              minHeight: 8,
            ),
            const SizedBox(height: 6),
            Text('All widgets use Theme.of(context).colorScheme — no hardcoded colours', 
                style: TextStyle(fontSize: 11, color: cs.onSurface.withOpacity(0.6))),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Theme.of(context).colorScheme.onSurface,
            )),
      ],
    );
  }
}

class _ConceptCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _ConceptCard({
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.primaryContainer.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.primary.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: cs.primary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                      fontSize: 13,
                    )),
                const SizedBox(height: 6),
                Text(body,
                    style: TextStyle(
                      color: cs.onSurface.withOpacity(0.75),
                      fontSize: 12,
                      height: 1.5,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
