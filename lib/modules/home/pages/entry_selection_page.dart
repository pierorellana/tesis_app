import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:tesis_app/env/theme/app_theme.dart';
import 'package:tesis_app/modules/home/widgets/card_selection.dart';
import 'package:tesis_app/shared/helpers/global_helper.dart';
import 'package:tesis_app/shared/providers/functional_provider.dart';

class EntrySelectionPage extends StatefulWidget {
  const EntrySelectionPage({super.key});

  @override
  State<EntrySelectionPage> createState() => _EntrySelectionPageState();
}

class _EntrySelectionPageState extends State<EntrySelectionPage> {
  @override
  Widget build(BuildContext context) {
    final fp = context.read<FunctionalProvider>();

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppTheme.white, AppTheme.greyBlocked],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 70),
          child: Column(
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Symbols.home_filled_rounded,
                  color: Colors.white,
                  size: 34,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Bienvenido(a)',
                style: TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.dark,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Seleccione su método de ingreso',
                style: TextStyle(
                  fontSize: 20,
                  color: AppTheme.hinText,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 46),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OptionCard(
                    icon: Symbols.qr_code_2_rounded,
                    title: 'Escanear QR',
                    subtitle: 'Use su código QR',
                    onTap: () =>
                        fp.setEntryMethodItem(EntryMethodItem.scanQr),
                  ),
                  const SizedBox(width: 22),
                  OptionCard(
                    icon: Icons.badge_outlined,
                    title: 'Ingreso sin QR',
                    subtitle: 'Identifíquese manualmente',
                    onTap: () => fp.setEntryMethodItem(EntryMethodItem.noQr),
                  ),
                ],
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  'Para asistencia, contacte al personal de seguridad.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.hinText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
