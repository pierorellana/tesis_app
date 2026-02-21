import 'package:flutter/material.dart';
import 'package:tesis_app/env/theme/app_theme.dart';

class IdParsedData {
  final String names;
  final String surnames;
  final String identification;

  const IdParsedData({
    required this.names,
    required this.surnames,
    required this.identification,
  });
}

class ConfirmIdDataWidget extends StatelessWidget {
  const ConfirmIdDataWidget({
    super.key,
    required this.data,
    required this.onConfirm,
    required this.onRetry,
  });

  final IdParsedData data;
  final VoidCallback onConfirm;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Confirme sus datos',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 45,
            fontWeight: FontWeight.w900,
            color: AppTheme.dark,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          width: 400,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
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
              _Field(label: 'Nombre completo', value: data.surnames),
              const SizedBox(height: 12),
              _Field(label: 'Identificación', value: data.identification),
            ],
          ),
        ),
        const SizedBox(height: 26),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 220,
              height: 58,
              child: ElevatedButton.icon(
                onPressed: onConfirm,
                icon: const Icon(Icons.check_rounded),
                label: const Text(
                  'Sí, son correctos',
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
              width: 150,
              height: 58,
              child: OutlinedButton(
                onPressed: onRetry,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.dark,
                  side: const BorderSide(color: Color(0xFFD7DEE8)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Repetir foto',
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

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.hinText,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            color: AppTheme.dark,
            fontWeight: FontWeight.bold,
            height: 1.05,
          ),
        ),
      ],
    );
  }
}
