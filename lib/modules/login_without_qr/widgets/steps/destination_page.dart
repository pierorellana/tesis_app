import 'package:flutter/material.dart';
import 'package:tesis_app/env/theme/app_theme.dart';
import 'package:tesis_app/modules/login_without_qr/models/resident_data.dart';
import 'package:tesis_app/modules/login_without_qr/widgets/informations/confirm_resident.dart';
import 'package:tesis_app/shared/widgets/drop_down_button.dart';

enum _DestinationUiState { form, confirm }

class DestinationPage extends StatefulWidget {
  const DestinationPage({
    super.key,
    required this.onBack,
    required this.onConfirmed,
  });

  final VoidCallback onBack;
  final void Function(ResidentFound resident) onConfirmed;

  @override
  State<DestinationPage> createState() => _DestinationPageState();
}

class _DestinationPageState extends State<DestinationPage> {
  _DestinationUiState _uiState = _DestinationUiState.form;

  final _formKey = GlobalKey<FormState>();

  String? _manzana;
  String? _villa;

  bool _hasErrorManzana = false;
  bool _hasErrorVilla = false;

  ResidentFound? _found;

  final List<String> _manzanas = const ['1', '2', '3', '4', '5'];
  final List<String> _villas = const ['1', '2', '3', '4', '5', '12'];

  bool get _canSearch => _manzana != null && _villa != null;

  void _searchResident() {
    setState(() {
      _hasErrorManzana = _manzana == null;
      _hasErrorVilla = _villa == null;
    });

    final resident = ResidentFound(
      manzana: _manzana!,
      villa: _villa!,
      residentName: 'Pierre Orellana',
    );

    setState(() {
      _found = resident;
      _uiState = _DestinationUiState.confirm;
    });
  }

  void _changeDestination() {
    setState(() {
      _uiState = _DestinationUiState.form;
      _found = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_uiState == _DestinationUiState.confirm && _found != null) {
      return ConfirmResident(
        data: _found!,
        onConfirm: () => widget.onConfirmed(_found!),
        onChangeDestination: _changeDestination,
      );
    }

    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '¿A dónde se dirige?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 52,
              fontWeight: FontWeight.w900,
              color: AppTheme.dark,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: 420,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Manzana',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.dark,
                  ),
                ),
                const SizedBox(height: 8),
                DropDownButtonWidget<String>(
                  hint: 'Ej: 5',
                  value: _manzana,
                  hasError: _hasErrorManzana,
                  items: _manzanas
                      .map(
                        (m) => DropdownMenuItem<String>(
                          value: m,
                          child: Text(m),
                        ),
                      )
                      .toList(),
                  // validator: (v) {
                  //   if (v == null || (v.isEmpty)) {
                  //     return 'Seleccione una manzana';
                  //   }
                  //   return null;
                  // },
                  onChanged: (v) {
                    setState(() {
                      _manzana = v;
                      _hasErrorManzana = false;
                    });
        
                    _formKey.currentState?.validate();
                  },
                ),
                const SizedBox(height: 18),
                const Text(
                  'Villa',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.dark,
                  ),
                ),
                const SizedBox(height: 8),
                DropDownButtonWidget<String>(
                  hint: 'Ej: 12',
                  value: _villa,
                  hasError: _hasErrorVilla,
                  items: _villas
                      .map(
                        (v) => DropdownMenuItem<String>(
                          value: v,
                          child: Text(v),
                        ),
                      )
                      .toList(),
                  // validator: (v) {
                  //   if (v == null || (v.isEmpty)) {
                  //     return 'Seleccione una villa';
                  //   }
                  //   return null;
                  // },
                  onChanged: (v) {
                    setState(() {
                      _villa = v;
                      _hasErrorVilla = false;
                    });
        
                    _formKey.currentState?.validate();
                  },
                ),
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
                  onPressed: _canSearch ? _searchResident : null,
                  icon: const Icon(Icons.location_on_outlined),
                  label: const Text(
                    'Buscar residente',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppTheme.primaryColor
                        .withOpacity(0.35),
                    disabledForegroundColor: Colors.white.withOpacity(0.85),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              SizedBox(
                width: 140,
                height: 58,
                child: OutlinedButton(
                  onPressed: widget.onBack,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.dark,
                    side: const BorderSide(color: Color(0xFFD7DEE8)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Volver',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
