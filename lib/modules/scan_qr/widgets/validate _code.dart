import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tesis_app/env/theme/app_theme.dart';
import 'package:tesis_app/shared/helpers/global_helper.dart';
import 'package:tesis_app/shared/providers/functional_provider.dart';
import 'package:tesis_app/shared/widgets/filled_button.dart';

class ValidateCodeWidget extends StatefulWidget {
  const ValidateCodeWidget({super.key});

  @override
  State<ValidateCodeWidget> createState() => _ValidateCodeWidgetState();
}

class _ValidateCodeWidgetState extends State<ValidateCodeWidget> {
  void _cancel(BuildContext context) {
    context.read<FunctionalProvider>().setEntryMethodItem(
      EntryMethodItem.scanQr,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppTheme.white, AppTheme.greyBlocked],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 22),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 86,
                  height: 86,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 86,
                        height: 86,
                        child: CircularProgressIndicator(
                          strokeWidth: 6,
                          valueColor: AlwaysStoppedAnimation(
                            AppTheme.primaryColor.withOpacity(0.75),
                          ),
                          backgroundColor: AppTheme.primaryColor.withOpacity(
                            0.12,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.shield_outlined,
                        size: 48,
                        color: AppTheme.primaryColor,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 26),
                const Text(
                  'Validando código...',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 44,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.dark,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Espere un momento',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: AppTheme.hinText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 26),
                FilledButtonWidget(
                  text: "Cancelar",
                  width: 30,
                  color: AppTheme.primaryColor,
                  onPressed: () => _cancel(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
