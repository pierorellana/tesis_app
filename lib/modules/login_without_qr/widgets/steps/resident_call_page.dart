import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tesis_app/env/theme/app_theme.dart';
import 'package:tesis_app/modules/login_without_qr/services/call_service.dart';
import 'package:tesis_app/modules/login_without_qr/services/create_access_service.dart';
import 'package:tesis_app/modules/login_without_qr/widgets/succes_alerts/authorized_access.dart';
import 'package:tesis_app/modules/login_without_qr/widgets/rejected_alerts/entry_rejected.dart';
import 'package:tesis_app/modules/login_without_qr/widgets/informations/no_response_page.dart';
import 'package:tesis_app/shared/widgets/status_icon_animated.dart'
    show StatusIconAnimated;

enum _CallUiState { calling, noResponse, authorized, rejected }

class ResidentCallPage extends StatefulWidget {
  const ResidentCallPage({
    super.key,
    required this.onGoNextStep,
    this.residentPhone,
    this.accesoPk,
  });

  final VoidCallback onGoNextStep;
  final String? residentPhone;
  final int? accesoPk;

  @override
  State<ResidentCallPage> createState() => _ResidentCallPageState();
}

class _ResidentCallPageState extends State<ResidentCallPage> {
  final CallService _callService = CallService();
  final AccessVisitService _accessVisitService = AccessVisitService();
  _CallUiState _uiState = _CallUiState.calling;

  Timer? _tick;
  Timer? _transition;
  Timer? _pollTimer;
  Timer? _attemptTimeout;
  bool _polling = false;

  int _elapsed = 0;
  int _attempts = 0;

  static const int _maxAttempts = 2;
  static const Duration _attemptTimeoutDuration = Duration(minutes: 2);

  @override
  void initState() {
    super.initState();
    _startCall();
  }

  @override
  void dispose() {
    _tick?.cancel();
    _transition?.cancel();
    _pollTimer?.cancel();
    _attemptTimeout?.cancel();
    super.dispose();
  }

  void _startCall() {
    _tick?.cancel();
    _transition?.cancel();
    _pollTimer?.cancel();
    _attemptTimeout?.cancel();
    _polling = false;
    _attempts = (_attempts + 1).clamp(1, _maxAttempts);

    setState(() {
      _uiState = _CallUiState.calling;
      _elapsed = 0;
    });

    _tick = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _elapsed++);
    });

    _attemptTimeout = Timer(_attemptTimeoutDuration, _handleAttemptTimeout);
    _sendCallRequest();
  }

  Future<void> _sendCallRequest() async {
    final accessPk = widget.accesoPk;
    if (accessPk == null) {
      return;
    }

    final payload = {
      "visitorName": "Edinson Ramirez",
    };

    final response = await _callService.getCall(
      context,
      accesoPk: accessPk,
      dataCall: payload,
    );
    if (!mounted) return;

    if (!response.error) {
      _startAccessVisitPolling(accessPk);
      return;
    }
    _handleNoResponse();
  }

  void _startAccessVisitPolling(int accessPk) {
    _pollTimer?.cancel();
    _polling = true;

    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      if (!_polling || !mounted) return;

      final response = await _accessVisitService.getAccessVisit(
        context,
        accesoPk: accessPk,
      );

      if (!mounted) return;

      if (response.error || response.data == null) {
        return;
      }

      final data = response.data!;
      if (data.finalizado == true) {
        if (data.puedeContinuar == true) {
          _showAuthorizedAndNext();
        } else {
          _showRejected();
        }
      }
    });
  }

  void _showAuthorizedAndNext() {
    _polling = false;
    _pollTimer?.cancel();
    _attemptTimeout?.cancel();
    _tick?.cancel();
    setState(() => _uiState = _CallUiState.authorized);

    _transition?.cancel();
    _transition = Timer(const Duration(seconds: 5), () {
      if (!mounted) return;
      widget.onGoNextStep();
    });
  }

  void _showRejected() {
    _polling = false;
    _pollTimer?.cancel();
    _attemptTimeout?.cancel();
    _transition?.cancel();
    _tick?.cancel();
    setState(() => _uiState = _CallUiState.rejected);
  }

  void _handleAttemptTimeout() {
    if (!mounted) return;
    _polling = false;
    _pollTimer?.cancel();
    _attemptTimeout?.cancel();
    _tick?.cancel();

    if (_attempts < _maxAttempts) {
      setState(() => _uiState = _CallUiState.noResponse);
      _transition?.cancel();
      _transition = Timer(const Duration(seconds: 2), () {
        if (!mounted) return;
        _startCall();
      });
    } else {
      _showRejected();
    }
  }

  void _handleNoResponse() {
    if (!mounted) return;
    _polling = false;
    _pollTimer?.cancel();
    _attemptTimeout?.cancel();
    _tick?.cancel();

    if (_attempts < _maxAttempts) {
      setState(() => _uiState = _CallUiState.noResponse);
      _transition?.cancel();
      _transition = Timer(const Duration(seconds: 2), () {
        if (!mounted) return;
        _startCall();
      });
    } else {
      _showRejected();
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (_uiState) {
      case _CallUiState.calling:
        return _CallingView(elapsedSeconds: _elapsed);

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
  const _CallingView({required this.elapsedSeconds});

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
          child: Text(
            _format(elapsedSeconds),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: AppTheme.dark,
              letterSpacing: 1.0,
            ),
          ),
        ),
      ],
    );
  }
}
