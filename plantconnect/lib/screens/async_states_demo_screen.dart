import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

/// Module 3.47 — Handling Errors, Loaders, and Empty States Gracefully
///
/// Demonstrates:
///   - Loading state (CircularProgressIndicator, FutureBuilder)
///   - Error state (friendly message + Retry button)
///   - Empty state (illustration + CTA)
///   - StreamBuilder state handling
///   - Pattern reference card for each state type
class AsyncStatesDemoScreen extends StatefulWidget {
  const AsyncStatesDemoScreen({super.key});

  @override
  State<AsyncStatesDemoScreen> createState() => _AsyncStatesDemoScreenState();
}

class _AsyncStatesDemoScreenState extends State<AsyncStatesDemoScreen> {
  // ── FutureBuilder demo ────────────────────────────────────────────────────
  // Holds the active Future so pressing "Retry" creates a new one
  late Future<List<String>> _plantsFuture;

  // Controls whether the simulated fetch succeeds or fails
  bool _simulateError = false;

  // ── Empty-state demo ──────────────────────────────────────────────────────
  final List<String> _myPlants = [];

  // ── StreamBuilder demo ────────────────────────────────────────────────────
  late StreamController<_StreamState> _streamController;
  _StreamState _streamState = _StreamState.loading;

  @override
  void initState() {
    super.initState();
    _plantsFuture = _fetchPlants();
    _streamController = StreamController<_StreamState>.broadcast();
    _startStreamSimulation();
  }

  @override
  void dispose() {
    _streamController.close();
    super.dispose();
  }

  // ── Simulated async fetch (succeeds normally, fails when _simulateError) ──
  Future<List<String>> _fetchPlants() async {
    await Future.delayed(const Duration(seconds: 2));
    if (_simulateError) {
      throw Exception('Network unreachable — please check your connection.');
    }
    return ['🌹 Rose', '🌵 Cactus', '🌿 Fern', '🌷 Tulip', '🍀 Clover'];
  }

  void _retry() {
    setState(() {
      _plantsFuture = _fetchPlants();
    });
  }

  // ── Stream simulation cycle: loading → data → error → empty ──────────────
  void _startStreamSimulation() async {
    final states = [
      _StreamState.loading,
      _StreamState.hasData,
      _StreamState.hasError,
      _StreamState.empty,
      _StreamState.hasData,
    ];
    for (final s in states) {
      await Future.delayed(const Duration(seconds: 2));
      if (!_streamController.isClosed) {
        _streamController.add(s);
        if (mounted) setState(() => _streamState = s);
      }
    }
  }

  void _resetStream() {
    setState(() => _streamState = _StreamState.loading);
    _startStreamSimulation();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Errors, Loaders & Empty States'),
        backgroundColor: Colors.deepOrange[700],
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── SECTION 1: FutureBuilder demo ─────────────────────────────
          _SectionHeader(
            icon: Icons.hourglass_top,
            title: '1. FutureBuilder — Loading / Error / Data',
            color: Colors.deepOrange,
          ),
          const SizedBox(height: 10),

          // Error toggle
          Card(
            child: SwitchListTile(
              title: const Text('Simulate network error'),
              subtitle: const Text('Toggle then press Retry'),
              value: _simulateError,
              activeColor: Colors.red,
              onChanged: (v) {
                setState(() {
                  _simulateError = v;
                  _plantsFuture = _fetchPlants();
                });
              },
            ),
          ),
          const SizedBox(height: 10),

          // FutureBuilder widget
          Card(
            clipBehavior: Clip.antiAlias,
            child: SizedBox(
              height: 240,
              child: FutureBuilder<List<String>>(
                future: _plantsFuture,
                builder: (context, snapshot) {
                  // ── Loading ─────────────────────────────────────────
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const _LoadingView(
                      message: 'Fetching plants…',
                    );
                  }

                  // ── Error ───────────────────────────────────────────
                  if (snapshot.hasError) {
                    return _ErrorView(
                      message: 'Could not load plants.',
                      detail: 'Network unreachable — check your connection.',
                      onRetry: _retry,
                    );
                  }

                  // ── Data ────────────────────────────────────────────
                  final plants = snapshot.data!;
                  return _DataListView(items: plants);
                },
              ),
            ),
          ),
          const SizedBox(height: 20),

          // ── SECTION 2: Empty State demo ───────────────────────────────
          _SectionHeader(
            icon: Icons.inbox_outlined,
            title: '2. Empty State',
            color: Colors.indigo,
          ),
          const SizedBox(height: 10),

          Card(
            clipBehavior: Clip.antiAlias,
            child: SizedBox(
              height: 240,
              child: _myPlants.isEmpty
                  ? _EmptyView(
                      icon: Icons.eco_outlined,
                      title: 'No plants yet',
                      subtitle: 'Tap the button below to add your first plant!',
                      cta: 'Add a Plant',
                      onAction: () {
                        setState(() {
                          _myPlants.add(
                            '🌱 Plant #${_myPlants.length + 1}',
                          );
                        });
                      },
                    )
                  : _DataListView(
                      items: _myPlants,
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: Colors.red),
                        tooltip: 'Clear all',
                        onPressed: () =>
                            setState(() => _myPlants.clear()),
                      ),
                    ),
            ),
          ),

          // Add button when list has items
          if (_myPlants.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: OutlinedButton.icon(
                onPressed: () => setState(() =>
                    _myPlants.add('🌱 Plant #${_myPlants.length + 1}')),
                icon: const Icon(Icons.add),
                label: const Text('Add another plant'),
              ),
            ),

          const SizedBox(height: 20),

          // ── SECTION 3: StreamBuilder simulation ───────────────────────
          _SectionHeader(
            icon: Icons.stream,
            title: '3. StreamBuilder — All States in Sequence',
            color: Colors.teal,
          ),
          const SizedBox(height: 10),

          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                // State indicator strip
                Container(
                  color: cs.surfaceContainerHighest,
                  padding: const EdgeInsets.symmetric(
                      vertical: 8, horizontal: 16),
                  child: Row(
                    children: _StreamState.values
                        .map((s) => Expanded(
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 400),
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 3),
                                height: 6,
                                decoration: BoxDecoration(
                                  color: s == _streamState
                                      ? _streamStateColor(s)
                                      : Colors.grey[300],
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ),

                // Stream content
                SizedBox(
                  height: 180,
                  child: StreamBuilder<_StreamState>(
                    stream: _streamController.stream,
                    initialData: _StreamState.loading,
                    builder: (context, snapshot) {
                      final state =
                          snapshot.data ?? _StreamState.loading;
                      return switch (state) {
                        _StreamState.loading => const _LoadingView(
                            message: 'Stream connecting…',
                          ),
                        _StreamState.hasError => _ErrorView(
                            message: 'Stream error occurred.',
                            detail:
                                'The data source reported an error.',
                            onRetry: _resetStream,
                          ),
                        _StreamState.empty => _EmptyView(
                            icon: Icons.water_drop_outlined,
                            title: 'No stream events',
                            subtitle: 'The stream returned no data',
                            cta: 'Replay',
                            onAction: _resetStream,
                          ),
                        _StreamState.hasData => _DataListView(items: const [
                            '📡 Live event received',
                            '✅ Data is streaming',
                            '🌿 3 plants loaded',
                          ]),
                      };
                    },
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    'Auto-cycles: loading → data → error → empty → data',
                    style: TextStyle(
                        color: Colors.grey[500], fontSize: 11),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── SECTION 4: Pattern reference ──────────────────────────────
          _SectionHeader(
            icon: Icons.lightbulb_outline,
            title: '4. Patterns Reference',
            color: Colors.amber[700]!,
          ),
          const SizedBox(height: 10),

          _PatternCard(
            state: 'Loading',
            color: Colors.blue,
            icon: Icons.hourglass_empty,
            dos: [
              'Show CircularProgressIndicator at center',
              'Disable inputs while loading',
              'Use skeleton/shimmer for long lists',
            ],
            donts: [
              "Don't show a blank white screen",
              "Don't nest multiple spinners",
              "Don't block the whole UI for tiny ops",
            ],
            code: 'if (snapshot.connectionState ==\n'
                '    ConnectionState.waiting) {\n'
                '  return const Center(\n'
                '    child: CircularProgressIndicator(),\n'
                '  );\n'
                '}',
          ),
          const SizedBox(height: 12),

          _PatternCard(
            state: 'Error',
            color: Colors.red,
            icon: Icons.error_outline,
            dos: [
              'Show a friendly, human-readable message',
              'Always provide a Retry button',
              'Log the real error for debugging',
            ],
            donts: [
              "Don't expose raw stack traces",
              "Don't use generic \"Error\" text",
              "Don't leave the user with no action",
            ],
            code: 'if (snapshot.hasError) {\n'
                '  log("Error: \${snapshot.error}");\n'
                '  return _ErrorView(\n'
                '    message: "Could not load data.",\n'
                '    onRetry: () => setState(() {\n'
                '      _future = fetchData();\n'
                '    }),\n'
                '  );\n'
                '}',
          ),
          const SizedBox(height: 12),

          _PatternCard(
            state: 'Empty',
            color: Colors.indigo,
            icon: Icons.inbox_outlined,
            dos: [
              'Explain why it\'s empty & what to do',
              'Show an icon/illustration',
              'Provide a CTA ("Add first item")',
            ],
            donts: [
              "Don't show a blank screen",
              "Don't use generic \"No data\" only",
              "Don't hide the empty state in a Snackbar",
            ],
            code: 'if (!snapshot.hasData ||\n'
                '    snapshot.data!.isEmpty) {\n'
                '  return _EmptyView(\n'
                '    title: "No items yet",\n'
                '    cta: "Add your first item",\n'
                '    onAction: _openCreateDialog,\n'
                '  );\n'
                '}',
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Color _streamStateColor(_StreamState s) => switch (s) {
        _StreamState.loading => Colors.blue,
        _StreamState.hasData => Colors.green,
        _StreamState.hasError => Colors.red,
        _StreamState.empty => Colors.orange,
      };
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable state widgets
// ─────────────────────────────────────────────────────────────────────────────

/// Loading state widget
class _LoadingView extends StatelessWidget {
  final String message;
  const _LoadingView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(message,
              style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        ],
      ),
    );
  }
}

/// Error state widget — friendly message + retry
class _ErrorView extends StatelessWidget {
  final String message;
  final String detail;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.message,
    required this.detail,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off_outlined,
                size: 48, color: Colors.red[400]),
            const SizedBox(height: 12),
            Text(message,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
            const SizedBox(height: 6),
            Text(detail,
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[400],
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Empty state widget — icon + subtitle + CTA button
class _EmptyView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String cta;
  final VoidCallback onAction;

  const _EmptyView({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.cta,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 52, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text(title,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
            const SizedBox(height: 6),
            Text(subtitle,
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.add, size: 18),
              label: Text(cta),
            ),
          ],
        ),
      ),
    );
  }
}

/// Success / data list view
class _DataListView extends StatelessWidget {
  final List<String> items;
  final Widget? trailing;

  const _DataListView({required this.items, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (trailing != null)
          Align(alignment: Alignment.centerRight, child: trailing!),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) => ListTile(
              dense: true,
              leading: Icon(Icons.check_circle_outline,
                  color: Colors.green[600], size: 20),
              title: Text(items[i],
                  style: const TextStyle(fontSize: 14)),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Pattern reference card
// ─────────────────────────────────────────────────────────────────────────────
class _PatternCard extends StatefulWidget {
  final String state;
  final Color color;
  final IconData icon;
  final List<String> dos;
  final List<String> donts;
  final String code;

  const _PatternCard({
    required this.state,
    required this.color,
    required this.icon,
    required this.dos,
    required this.donts,
    required this.code,
  });

  @override
  State<_PatternCard> createState() => _PatternCardState();
}

class _PatternCardState extends State<_PatternCard> {
  bool _showCode = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: widget.color.withOpacity(0.1),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Icon(widget.icon, color: widget.color, size: 22),
                const SizedBox(width: 8),
                Text('${widget.state} State',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: widget.color,
                        fontSize: 15)),
                const Spacer(),
                TextButton(
                  onPressed: () =>
                      setState(() => _showCode = !_showCode),
                  child: Text(_showCode ? 'Hide code' : 'Show code',
                      style: TextStyle(color: widget.color, fontSize: 12)),
                ),
              ],
            ),
          ),

          if (_showCode)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: const Color(0xFF1E1E2E),
              child: Text(
                widget.code,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  color: Color(0xFF89DDFF),
                  height: 1.6,
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _DosDonts(items: widget.dos, isDo: true)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _DosDonts(items: widget.donts, isDo: false)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _DosDonts extends StatelessWidget {
  final List<String> items;
  final bool isDo;

  const _DosDonts({required this.items, required this.isDo});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(isDo ? '✅ Do' : '❌ Don\'t',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: isDo ? Colors.green[700] : Colors.red[700],
            )),
        const SizedBox(height: 6),
        ...items.map(
          (t) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  isDo ? Icons.arrow_right : Icons.close,
                  size: 14,
                  color: isDo ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(t,
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey[700])),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section header helper
// ─────────────────────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stream simulation states
// ─────────────────────────────────────────────────────────────────────────────
enum _StreamState { loading, hasData, hasError, empty }
