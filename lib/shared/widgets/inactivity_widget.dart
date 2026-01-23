import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tesis_app/env/theme/app_theme.dart';
import 'package:tesis_app/shared/providers/functional_provider.dart';
import 'package:tesis_app/shared/helpers/global_helper.dart' as GlobalHelper;

class InactivityGuard extends StatefulWidget {
  const InactivityGuard({
    super.key,
    required this.child,
    this.timeoutSeconds = 30,
    this.warningSeconds = 8,
  });

  final Widget child;
  final int timeoutSeconds;
  final int warningSeconds;

  @override
  State<InactivityGuard> createState() => _InactivityGuardState();
}

class _InactivityGuardState extends State<InactivityGuard> {
  Timer? _tick;
  OverlayEntry? _overlay;
  int _remaining = 0;
  bool _bannerVisible = false;

  bool _isActiveModule(GlobalHelper.EntryMethodItem item) {
    return item != GlobalHelper.EntryMethodItem.none;
  }

  @override
  void dispose() {
    _stopTimersAndBanner();
    super.dispose();
  }

  void _stopTimersAndBanner() {
    _tick?.cancel();
    _tick = null;
    _hideBanner();
  }

  void _resetCountdown() {
    _remaining = widget.timeoutSeconds;
    if (_bannerVisible) _hideBanner();

    _tick?.cancel();
    _tick = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;

      _remaining--;

      if (_remaining <= widget.warningSeconds && _remaining > 0) {
        _showOrUpdateBanner(_remaining);
      }

      if (_remaining <= 0) {
        t.cancel();
        _hideBanner();
        _resetToHome();
      }
    });
  }

  void _registerActivity() {
    if (_tick == null) return;
    _resetCountdown();
  }

  void _resetToHome() {
    final fp = context.read<FunctionalProvider>();
    fp.setEntryMethodItem(GlobalHelper.EntryMethodItem.none);
  }

  void _showOrUpdateBanner(int seconds) {
    if (_overlay == null) {
      _overlay = OverlayEntry(
        builder: (_) => _InactivityTopBanner(seconds: seconds),
      );
      Overlay.of(context, rootOverlay: true).insert(_overlay!);
      _bannerVisible = true;
    } else {
      _overlay!.markNeedsBuild();
      _overlay!.remove();
      _overlay = OverlayEntry(
        builder: (_) => _InactivityTopBanner(seconds: seconds),
      );
      Overlay.of(context, rootOverlay: true).insert(_overlay!);
      _bannerVisible = true;
    }
  }

  void _hideBanner() {
    _overlay?.remove();
    _overlay = null;
    _bannerVisible = false;
  }

  @override
  Widget build(BuildContext context) {
    final entry = context
        .select<FunctionalProvider, GlobalHelper.EntryMethodItem>(
          (p) => p.entryMethodItem,
        );

    final active = _isActiveModule(entry);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (active) {
        _tick ?? _resetCountdown();
      } else {
        _stopTimersAndBanner();
      }
    });

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _registerActivity(),
      onPointerMove: (_) => _registerActivity(),
      onPointerSignal: (_) => _registerActivity(),
      child: NotificationListener<ScrollNotification>(
        onNotification: (n) {
          _registerActivity();
          return false;
        },
        child: widget.child,
      ),
    );
  }
}

class _InactivityTopBanner extends StatelessWidget {
  const _InactivityTopBanner({required this.seconds});

  final int seconds;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 10,
      left: 0,
      right: 0,
      child: IgnorePointer(
        ignoring: true,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              'Se reiniciará por inactividad en $seconds segundos',
              style: const TextStyle(
                decoration: TextDecoration.none,
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
