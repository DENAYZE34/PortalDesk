import 'package:flutter/material.dart';
import 'package:flutter_hbb/consts.dart';

import '../common.dart';
import 'glass/glass.dart';
import 'permission_logic.dart';

/// Checklist of the phone permissions needed to be controlled; refreshes when
/// the user comes back from the system settings.
class PermissionWizardPage extends StatefulWidget {
  const PermissionWizardPage({super.key});

  @override
  State<PermissionWizardPage> createState() => _PermissionWizardPageState();
}

class _PermissionWizardPageState extends State<PermissionWizardPage>
    with WidgetsBindingObserver {
  List<PermItem> _items = permissionItems(null);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refresh();
  }

  Future<void> _refresh() async {
    Map<dynamic, dynamic>? status;
    try {
      status = await gFFI.invokeMethodWithResult<Map<dynamic, dynamic>>(
          'permission_status');
    } catch (_) {}
    if (mounted) setState(() => _items = permissionItems(status));
  }

  Future<void> _fix(String key) async {
    try {
      await _open(key);
    } catch (_) {
      showToast('Не удалось открыть настройки');
    }
  }

  Future<void> _open(String key) async {
    switch (key) {
      case 'accessibility':
        await gFFI.invokeMethod(
            AndroidChannel.kStartAction, kActionAccessibilitySettings);
        break;
      case 'overlay':
        await gFFI.invokeMethod('open_overlay_settings');
        break;
      case 'battery':
        await gFFI.invokeMethod('open_battery_settings');
        break;
      default:
        await gFFI.invokeMethod(
            AndroidChannel.kStartAction, kActionApplicationDetailsSettings);
    }
  }

  @override
  Widget build(BuildContext context) {
    final missing = missingPermissions(_items);
    return AuroraBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Glass.text),
          title: const Text('Разрешения телефона',
              style: TextStyle(
                  color: Glass.text,
                  fontSize: 20,
                  fontWeight: FontWeight.w700)),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
          children: [
            GlassCard(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
              radius: 24,
              strength: 1.2,
              child: Row(children: [
                Icon(missing == 0 ? Icons.verified_rounded : Icons.info_rounded,
                    color: missing == 0 ? Glass.ok : Glass.warn, size: 26),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                      missing == 0
                          ? 'Всё включено, телефоном можно управлять'
                          : 'Не хватает разрешений: $missing',
                      style: const TextStyle(
                          color: Glass.text,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          height: 1.25)),
                ),
              ]),
            ),
            const SizedBox(height: 14),
            for (final e in _items) ...[
              _PermissionRow(item: e, onFix: () => _fix(e.key)),
              const SizedBox(height: 10),
            ],
            const SizedBox(height: 6),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                  'Запись экрана система спросит сама при первом подключении.',
                  style: TextStyle(
                      color: Glass.soft, fontSize: 13, height: 1.35)),
            ),
          ],
        ),
      ),
    );
  }
}

class _PermissionRow extends StatelessWidget {
  final PermItem item;
  final VoidCallback onFix;
  const _PermissionRow({required this.item, required this.onFix});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      radius: 22,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(
              item.granted
                  ? Icons.check_circle_rounded
                  : Icons.cancel_rounded,
              color: item.granted ? Glass.ok : Glass.bad,
              size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title,
                      style: const TextStyle(
                          color: Glass.text,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          height: 1.25)),
                  const SizedBox(height: 3),
                  Text(item.hint,
                      style: const TextStyle(
                          color: Glass.soft, fontSize: 13, height: 1.3)),
                ]),
          ),
        ]),
        // The button sits on its own line, so a long Russian title can never
        // collide with it.
        if (!item.granted) ...[
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: GlassButton(
                label: 'Включить',
                icon: Icons.tune_rounded,
                onPressed: onFix),
          ),
        ],
      ]),
    );
  }
}
