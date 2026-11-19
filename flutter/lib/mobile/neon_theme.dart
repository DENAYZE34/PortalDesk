import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'glass/glass.dart';

/// PortalDesk look on phones and Windows: flat graphite surfaces from the
/// design system in `glass/glass.dart`. Other desktop platforms keep the stock
/// theme.
bool get kNeon =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.windows);

class Neon {
  static const Color bg = Glass.base;
  static const Color bar = Glass.base;
  static const Color surface = Glass.surface;
  static const Color surfaceHigh = Glass.raised;
  static const Color line = Color(0x14EDEDED);
  static const Color text = Glass.text;
  static const Color muted = Glass.muted;
}
