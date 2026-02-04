import 'package:flutter/material.dart';
import 'package:tesis_app/env/theme/app_theme.dart';
import 'package:tesis_app/modules/login_without_qr/models/resident_data.dart';

class ConfirmResident extends StatelessWidget {
  const ConfirmResident({
    super.key,
    required this.data,
    required this.onConfirm,
    required this.onChangeDestination,
  });

  final ResidentFound data;
  final VoidCallback onConfirm;
  final VoidCallback onChangeDestination;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Confirme el residente',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 52,
            fontWeight: FontWeight.w900,
            color: AppTheme.dark,
          ),
        ),
        const SizedBox(height: 18),
        Container(
          width: 500,
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
              Row(
                children: [
                  const Icon(
                    Icons.home_outlined,
                    color: AppTheme.primaryColor,
                    size: 26,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Destino',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.hinText,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${data.manzana} / ${data.villa}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.dark,
                            height: 1.05,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: Color(0xFFD7DEE8), height: 1),
              const SizedBox(height: 16),
              Text(
                'Residente',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.hinText,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                data.residentName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.dark,
                  height: 1.05,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 26),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 170,
              height: 58,
              child: ElevatedButton.icon(
                onPressed: onConfirm,
                icon: const Icon(Icons.check_rounded),
                label: const Text(
                  'Confirmar',
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
              width: 190,
              height: 58,
              child: OutlinedButton(
                onPressed: onChangeDestination,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.dark,
                  side: const BorderSide(color: Color(0xFFD7DEE8)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Cambiar destino',
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
