import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:tesis_app/env/theme/app_theme.dart';
import 'package:tesis_app/modules/home/widgets/card_selection.dart';
import 'package:tesis_app/shared/helpers/global_helper.dart';
import 'package:tesis_app/shared/helpers/responsive.dart';
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final r = context.responsive;
            final isShort = constraints.maxHeight < 650;
            final isWide = constraints.maxWidth >= 1000;

            final paddingV = (constraints.maxHeight * 0.08).clamp(18.0, 80.0);

            final iconBox = (r.dp(4.2)).clamp(52.0, 72.0);
            final iconSize = (r.dp(2.2)).clamp(28.0, 36.0);

            final titleSize = (r.dp(2.6)).clamp(30.0, 50.0);
            final subtitleSize = (r.dp(1.3)).clamp(14.0, 22.0);

            final cardWidth = (constraints.maxWidth * (isWide ? 0.28 : 0.42))
                .clamp(230.0, 330.0);
            final cardHeight = (constraints.maxHeight * (isShort ? 0.28 : 0.32))
                .clamp(200.0, 270.0);

            final cardIconSize = (r.dp(2.6)).clamp(36.0, 64.0);
            final cardTitleSize = (r.dp(1.6)).clamp(18.0, 26.0);
            final cardSubtitleSize = (r.dp(1.1)).clamp(12.0, 16.0);

            final gapTitle = (constraints.maxHeight * 0.02).clamp(10.0, 18.0);
            final gapCards = (constraints.maxHeight * 0.05).clamp(20.0, 44.0);
            final wrapSpacing = (constraints.maxWidth * 0.02).clamp(12.0, 26.0);
            final wrapRunSpacing = (constraints.maxHeight * 0.02).clamp(
              12.0,
              24.0,
            );

            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                  minWidth: constraints.maxWidth,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: paddingV),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Container(
                            width: iconBox,
                            height: iconBox,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              Symbols.home_filled_rounded,
                              color: Colors.white,
                              size: iconSize,
                            ),
                          ),
                          SizedBox(height: gapTitle),
                          Text(
                            'Bienvenido(a)',
                            style: TextStyle(
                              fontSize: titleSize,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.dark,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Seleccione su método de ingreso',
                            style: TextStyle(
                              fontSize: subtitleSize,
                              color: AppTheme.hinText,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: gapCards),
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: wrapSpacing,
                            runSpacing: wrapRunSpacing,
                            children: [
                              OptionCard(
                                icon: Symbols.qr_code_2_rounded,
                                title: 'Escanear QR',
                                subtitle: 'Use su código QR',
                                width: cardWidth,
                                height: cardHeight,
                                iconSize: cardIconSize,
                                titleSize: cardTitleSize,
                                subtitleSize: cardSubtitleSize,
                                onTap: () => fp.setEntryMethodItem(
                                  EntryMethodItem.scanQr,
                                ),
                              ),
                              OptionCard(
                                icon: Icons.badge_outlined,
                                title: 'Ingreso sin QR',
                                subtitle: 'Identifíquese manualmente',
                                width: cardWidth,
                                height: cardHeight,
                                iconSize: cardIconSize,
                                titleSize: cardTitleSize,
                                subtitleSize: cardSubtitleSize,
                                onTap: () =>
                                    fp.setEntryMethodItem(EntryMethodItem.noQr),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Text(
                        'Para asistencia, contacte al personal de seguridad.',
                        style: TextStyle(
                          fontSize: (r.dp(1.0)).clamp(12.0, 16.0),
                          color: AppTheme.hinText,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
