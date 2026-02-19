import 'package:flutter/material.dart';
import 'package:tesis_app/env/theme/app_theme.dart';
import 'package:tesis_app/modules/login_without_qr/models/admission_request.dart';
import 'package:tesis_app/modules/login_without_qr/widgets/cards/card_reason.dart';
import 'package:tesis_app/modules/login_without_qr/widgets/informations/review_application.dart';

enum _ReasonUiState { select, review }

class ReasonAdmissionPage extends StatefulWidget {
  const ReasonAdmissionPage({
    super.key,
    required this.model,
    required this.onBack,
    required this.onCallResident,
    required this.onEditDestination,
  });

  final AdmissionRequestModel model;
  final VoidCallback onBack;
  final VoidCallback onCallResident;
  final VoidCallback onEditDestination;

  @override
  State<ReasonAdmissionPage> createState() => _ReasonAdmissionPageState();
}

class _ReasonAdmissionPageState extends State<ReasonAdmissionPage> {
  _ReasonUiState _uiState = _ReasonUiState.select;

  void _selectReason(AdmissionReason reason) {
    setState(() {
      widget.model.reason = reason;
      _uiState = _ReasonUiState.review;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_uiState == _ReasonUiState.review) {
      return ReviewApplication(
        model: widget.model,
        onCallResident: widget.onCallResident,
        onEditDestination: () {
          widget.onEditDestination();
        },
      );
    }

    return Stack(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Motivo de ingreso',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 52,
                fontWeight: FontWeight.bold,
                color: AppTheme.dark,
              ),
            ),
            const SizedBox(height: 35),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ReasonCard(
                  icon: Icons.person_outline_rounded,
                  title: 'Visita',
                  isSelected: widget.model.reason == AdmissionReason.visit,
                  onTap: () => _selectReason(AdmissionReason.visit),
                ),
                const SizedBox(width: 18),
                ReasonCard(
                  icon: Icons.local_shipping_outlined,
                  title: 'Delivery / Pedido',
                  isSelected: widget.model.reason == AdmissionReason.delivery,
                  onTap: () => _selectReason(AdmissionReason.delivery),
                ),
                const SizedBox(width: 18),
                ReasonCard(
                  icon: Icons.local_taxi_outlined,
                  title: 'Taxi',
                  isSelected: widget.model.reason == AdmissionReason.taxi,
                  onTap: () => _selectReason(AdmissionReason.taxi),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
        Positioned(
          left: 20,
          bottom: 12,
          child: OutlinedButton.icon(
            onPressed: widget.onBack,
            icon: const Icon(Icons.arrow_back_rounded, size: 18),
            label: const Text(
              'Volver',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.dark,
              side: const BorderSide(color: Color(0xFFD7DEE8)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
