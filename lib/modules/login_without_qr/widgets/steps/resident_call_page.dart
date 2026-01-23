import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tesis_app/env/theme/app_theme.dart';
import 'package:tesis_app/modules/login_without_qr/widgets/succes_alerts/authorized_access.dart';
import 'package:tesis_app/modules/login_without_qr/widgets/rejected_alerts/entry_rejected.dart';
import 'package:tesis_app/modules/login_without_qr/widgets/informations/no_response_page.dart';
import 'package:tesis_app/shared/widgets/status_icon_animated.dart'
    show StatusIconAnimated;

enum CallSimResult { authorized, noAnswer, rejected }

enum _CallUiState { calling, noResponse, authorized, rejected }

class ResidentCallPage extends StatefulWidget {
  const ResidentCallPage({
    super.key,
    required this.onGoNextStep,
    this.maxAttempts = 2,
    this.callSeconds = 10,
    this.simulationAttempt1 = CallSimResult.noAnswer,
    this.simulationAttempt2 = CallSimResult.authorized,
  });

  final VoidCallback onGoNextStep;

  final int maxAttempts;
  final int callSeconds;
  final CallSimResult simulationAttempt1;
  final CallSimResult simulationAttempt2;

  @override
  State<ResidentCallPage> createState() => _ResidentCallPageState();
}

class _ResidentCallPageState extends State<ResidentCallPage> {
  _CallUiState _uiState = _CallUiState.calling;

  Timer? _tick;
  Timer? _transition;

  int _attempt = 1;
  int _elapsed = 0;

  @override
  void initState() {
    super.initState();
    _startCallAttempt(1);
  }

  @override
  void dispose() {
    _tick?.cancel();
    _transition?.cancel();
    super.dispose();
  }

  void _startCallAttempt(int attempt) {
    _tick?.cancel();
    _transition?.cancel();

    setState(() {
      _attempt = attempt;
      _uiState = _CallUiState.calling;
      _elapsed = 0;
    });

    _tick = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;

      if (_elapsed >= widget.callSeconds) {
        t.cancel();
        _finishAttempt();
      } else {
        setState(() => _elapsed++);
      }
    });
  }

  CallSimResult _resultForAttempt(int attempt) {
    return attempt == 1 ? widget.simulationAttempt1 : widget.simulationAttempt2;
  }

  void _finishAttempt() {
    final result = _resultForAttempt(_attempt);

    if (!mounted) return;

    if (result == CallSimResult.authorized) {
      setState(() => _uiState = _CallUiState.authorized);

      _transition = Timer(const Duration(seconds: 5), () {
        if (!mounted) return;
        widget.onGoNextStep();
      });
      return;
    }

    if (result == CallSimResult.rejected) {
      setState(() => _uiState = _CallUiState.rejected);
      return;
    }

    if (_attempt < widget.maxAttempts) {
      setState(() => _uiState = _CallUiState.noResponse);

      _transition = Timer(const Duration(seconds: 5), () {
        if (!mounted) return;
        _startCallAttempt(_attempt + 1);
      });
    } else {
      setState(() => _uiState = _CallUiState.rejected);
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (_uiState) {
      case _CallUiState.calling:
        return _CallingView(
          attempt: _attempt,
          maxAttempts: widget.maxAttempts,
          elapsedSeconds: _elapsed,
        );

      case _CallUiState.noResponse:
        return const NoResponsePage();

      case _CallUiState.authorized:
        return const AuthorizedAccess();

      case _CallUiState.rejected:
        return const EntryRejected();
    }
  }
}

class _CallingView extends StatelessWidget {
  const _CallingView({
    required this.attempt,
    required this.maxAttempts,
    required this.elapsedSeconds,
  });

  final int attempt;
  final int maxAttempts;
  final int elapsedSeconds;

  String _format(int s) {
    final m = (s ~/ 60).toString().padLeft(2, '0');
    final sec = (s % 60).toString().padLeft(2, '0');
    return '$m:$sec';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const StatusIconAnimated(
          color: AppTheme.greyBlocked,
          icon: Icons.call_outlined,
          size: 140,
          iconSize: 52,
        ),
        const SizedBox(height: 22),
        const Text(
          'Llamando al residente...',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 52,
            fontWeight: FontWeight.bold,
            color: AppTheme.dark,
            height: 1.05,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Espere la confirmación',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            color: AppTheme.hinText,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 22),
        Container(
          width: 180,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFD7DEE8)),
            boxShadow: [
              BoxShadow(
                blurRadius: 18,
                offset: const Offset(0, 10),
                color: Colors.black.withOpacity(0.06),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                'Intento $attempt de $maxAttempts',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.hinText,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _format(elapsedSeconds),
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.dark,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
