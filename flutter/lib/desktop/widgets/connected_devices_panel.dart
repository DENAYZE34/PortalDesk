// A live, cross-window list of currently connected remote sessions, shown
// as a docked panel on the right of the main window while at least one
// session is open. Each remote-desktop sub-window only knows about its own
// tabs (DesktopTabController is scoped per window), so this polls every
// open remote-desktop window's existing kWindowEventGetSessionIdList
// handler (remote_tab_page.dart) over the same DesktopMultiWindow channel
// already used elsewhere, rather than adding a new one.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:get/get.dart';

import '../../common.dart';
import '../../consts.dart';
import '../../models/platform_model.dart';
import '../../utils/multi_window_manager.dart';

const _bg = Color(0xFF121214);
const _fg = Color(0xFFF2F2F2);
const _border = Color(0x1AFFFFFF);
const _ok = Color(0xFF34D399);

class ConnectedDevice {
  final String peerId;
  final String sessionId;
  final int windowId;
  const ConnectedDevice(this.peerId, this.sessionId, this.windowId);
}

class ConnectedDevicesModel {
  ConnectedDevicesModel._();
  static final instance = ConnectedDevicesModel._();

  final devices = <ConnectedDevice>[].obs;

  Future<void> refresh() async {
    final next = <ConnectedDevice>[];
    for (final windowId in RustDeskMultiWindowManager.instance.remoteDesktopWindows) {
      try {
        final res = await DesktopMultiWindow.invokeMethod(
            windowId, kWindowEventGetSessionIdList, '');
        if (res is! String || res.isEmpty) continue;
        for (final entry in res.split(';')) {
          final parts = entry.split(',');
          if (parts.length != 2) continue;
          next.add(ConnectedDevice(parts[0], parts[1], windowId));
        }
      } catch (_) {
        // A window that closed mid-poll just contributes nothing this tick.
      }
    }
    devices.value = next;
  }
}

class ConnectedDevicesPanel extends StatefulWidget {
  const ConnectedDevicesPanel({super.key});

  @override
  State<ConnectedDevicesPanel> createState() => _ConnectedDevicesPanelState();
}

class _ConnectedDevicesPanelState extends State<ConnectedDevicesPanel> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    ConnectedDevicesModel.instance.refresh();
    _timer = Timer.periodic(
        const Duration(seconds: 2), (_) => ConnectedDevicesModel.instance.refresh());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final devices = ConnectedDevicesModel.instance.devices;
      if (devices.isEmpty) return const SizedBox.shrink();
      return Container(
        width: 220,
        margin: const EdgeInsets.fromLTRB(0, 8, 12, 8),
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          color: _bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Подключения (${devices.length})',
                style: const TextStyle(
                    color: _fg, fontSize: 13, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            for (final d in devices) _deviceTile(d),
          ],
        ),
      );
    });
  }

  Widget _deviceTile(ConnectedDevice d) {
    final alias = bind.mainGetPeerOptionSync(id: d.peerId, key: 'alias');
    final label = alias.isNotEmpty ? alias : d.peerId;
    return InkWell(
      onTap: () => windowOnTop(d.windowId),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            const DecoratedBox(
              decoration: BoxDecoration(shape: BoxShape.circle, color: _ok),
              child: SizedBox(width: 7, height: 7),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: _fg, fontSize: 12.5)),
            ),
          ],
        ),
      ),
    );
  }
}
