// Centered, backdrop-blurred "update available" card for Windows/desktop,
// shown once per new version on top of the existing update machinery
// (Rust-side do_check_software_update -> stateGlobal.updateUrl, and the
// existing handleUpdate() downloader in update_progress.dart). This file
// only adds the attention-grabbing presentation; it does not change how
// updates are detected or installed.
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart' hide Dialog;
import 'package:flutter/material.dart' as material show Dialog;
import 'package:http/http.dart' as http;

import '../../mobile/neon_theme.dart';
import '../../mobile/update_logic.dart';
import '../../models/platform_model.dart';
import 'update_progress.dart';

const String _kReleaseApi =
    'https://api.github.com/repos/DENAYZE34/PortalDesk/releases/latest';

/// Shows the modal once for [updateUrl]'s version, fetching "what's new"
/// notes from the same GitHub release the Rust side already found. Safe to
/// call multiple times; the dialog itself is what the caller debounces via
/// the existing 'portal-update-closed' local option.
Future<void> showPortalUpdateDialog(
    BuildContext context, String updateUrl) async {
  final version = updateUrl.split('/').last;
  var notes = <String>[];
  try {
    final resp = await http
        .get(Uri.parse(_kReleaseApi),
            headers: {'Accept': 'application/vnd.github+json'})
        .timeout(const Duration(seconds: 8));
    if (resp.statusCode == 200) {
      final body = (jsonDecode(resp.body) as Map<String, dynamic>)['body'];
      notes = parseReleaseNotes(body is String ? body : null, max: 8);
    }
  } catch (_) {
    // Best-effort: the dialog still offers the update without a changelog.
  }
  if (!context.mounted) return;

  await showDialog<void>(
    context: context,
    barrierColor: Colors.black.withOpacity(0.45),
    builder: (ctx) => _PortalUpdateDialog(
        version: version, updateUrl: updateUrl, notes: notes),
  );
}

class _PortalUpdateDialog extends StatelessWidget {
  final String version;
  final String updateUrl;
  final List<String> notes;
  const _PortalUpdateDialog(
      {required this.version, required this.updateUrl, required this.notes});

  @override
  Widget build(BuildContext context) {
    return material.Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(21),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: NeonPanel(
              glow: true,
              padding: const EdgeInsets.fromLTRB(26, 26, 26, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle, gradient: Neon.gradient),
                    child: const Icon(Icons.arrow_upward_rounded,
                        color: Colors.white, size: 22),
                  ),
                  const SizedBox(height: 16),
                  const Text('Доступно обновление',
                      style: TextStyle(
                          color: Neon.text,
                          fontSize: 19,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text('PortalDesk $version',
                      style: const TextStyle(color: Neon.muted, fontSize: 13)),
                  if (notes.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    const Text('Что нового',
                        style: TextStyle(
                            color: Neon.text,
                            fontSize: 13,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    for (final n in notes)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 6),
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle, color: Neon.cyan),
                                child: SizedBox(width: 5, height: 5),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                                child: Text(n,
                                    style: const TextStyle(
                                        color: Neon.muted,
                                        fontSize: 13,
                                        height: 1.4))),
                          ],
                        ),
                      ),
                  ],
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          style: TextButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12)),
                          onPressed: () {
                            bind.mainSetLocalOption(
                                key: 'portal-update-closed', value: version);
                            Navigator.of(context).pop();
                          },
                          child: const Text('Позже',
                              style: TextStyle(color: Neon.muted)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: Neon.gradient,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                Navigator.of(context).pop();
                                handleUpdate(updateUrl);
                              },
                              child: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: Center(
                                  child: Text('Обновить',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14)),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
