import 'package:flutter/material.dart';
import 'package:tesis_app/env/theme/app_theme.dart';
import 'package:tesis_app/modules/login_without_qr/models/admission_request.dart';

class ReviewApplication extends StatelessWidget {
  const ReviewApplication({
    super.key,
    required this.model,
    required this.onCallResident,
    required this.onEditDestination,
  });

  final AdmissionRequestModel model;
  final VoidCallback onCallResident;
  final VoidCallback onEditDestination;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Revise su solicitud',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 52,
            fontWeight: FontWeight.w900,
            color: AppTheme.dark,
            height: 1.05,
          ),
        ),
        const SizedBox(height: 18),
        Container(
          width: 460,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFD7DEE8), width: 1),
            boxShadow: [
              BoxShadow(
                blurRadius: 18,
                offset: const Offset(0, 10),
                color: Colors.black.withOpacity(0.06),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Section(
                title: 'Visitante',
                lines: [model.fullName, 'CI: ${model.identification}'],
                strongFirst: true,
              ),
              const Divider(color: Color(0xFFD7DEE8), height: 32),
              _Section(
                title: 'Destino',
                lines: [model.destinoLabel, model.residentName],
                strongFirst: true,
              ),
              const Divider(color: Color(0xFFD7DEE8), height: 32),
              _Section(
                title: 'Motivo',
                lines: [model.reasonLabel],
                strongFirst: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 26),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 260,
              height: 58,
              child: ElevatedButton.icon(
                onPressed: onCallResident,
                icon: const Icon(Icons.call_outlined),
                label: const Text(
                  'Llamar al residente',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            SizedBox(
              width: 170,
              height: 58,
              child: OutlinedButton(
                onPressed: onEditDestination,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.dark,
                  side: const BorderSide(color: Color(0xFFD7DEE8)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Editar destino',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.lines,
    required this.strongFirst,
  });

  final String title;
  final List<String> lines;
  final bool strongFirst;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.hinText,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        ...List.generate(lines.length, (i) {
          final isStrong = strongFirst && i == 0;
          return Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              lines[i],
              style: TextStyle(
                fontSize: isStrong ? 18 : 14,
                fontWeight: isStrong ? FontWeight.w900 : FontWeight.w600,
                color: AppTheme.dark,
              ),
            ),
          );
        }),
      ],
    );
  }
}
