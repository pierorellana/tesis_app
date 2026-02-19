import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tesis_app/env/theme/app_theme.dart';
import 'package:tesis_app/modules/login_without_qr/models/admission_request.dart';
import 'package:tesis_app/modules/login_without_qr/models/id_result_model.dart';
import 'package:tesis_app/modules/login_without_qr/models/resident_data.dart';
import 'package:tesis_app/modules/login_without_qr/widgets/steps/capture_plate_page.dart';
import 'package:tesis_app/modules/login_without_qr/widgets/steps/destination_page.dart';
import 'package:tesis_app/modules/login_without_qr/widgets/steps/id_page.dart';
import 'package:tesis_app/modules/login_without_qr/widgets/steps/reason_admission_page.dart';
import 'package:tesis_app/modules/login_without_qr/widgets/steps/resident_call_page.dart';
import 'package:tesis_app/modules/login_without_qr/widgets/steps/validation_face_page.dart';
import 'package:tesis_app/shared/helpers/global_helper.dart' as GlobalHelper;
import 'package:tesis_app/shared/providers/functional_provider.dart';

class IngresoQrFlowPage extends StatefulWidget {
  const IngresoQrFlowPage({super.key});

  @override
  State<IngresoQrFlowPage> createState() => _IngresoQrFlowPageState();
}

class _IngresoQrFlowPageState extends State<IngresoQrFlowPage> {
  int _currentStep = 0;
  String? _fotoCedulaBase64;

  final AdmissionRequestModel _request = AdmissionRequestModel();

  void _goToStep(int index) {
    if (index == _currentStep) return;
    setState(() => _currentStep = index);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppTheme.white, AppTheme.greyBlocked],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _StepsHeader(
                currentIndex: _currentStep,
                onTapStep: _goToStep,
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: Builder(
                builder: (context) {
                  if (_currentStep == 0) {
                    return IdPage(
                      onBack: () {
                        context.read<FunctionalProvider>().setEntryMethodItem(
                          GlobalHelper.EntryMethodItem.none,
                        );
                      },
                      onConfirmed: (IdStepResult result) {
                        _request.idData = result.data;
                        _fotoCedulaBase64 = result.fotoCedulaBase64;
                        setState(() => _currentStep = 1);
                      },
                    );
                  }

                  if (_currentStep == 1) {
                    return ValidationFacePage(
                      onBack: () => setState(() => _currentStep = 0),
                      fotoCedulaBase64: _fotoCedulaBase64 ?? '',
                      onSuccessNext: () => setState(() => _currentStep = 2),
                    );
                  }

                  if (_currentStep == 2) {
                    return DestinationPage(
                      onBack: () => setState(() => _currentStep = 1),
                      onConfirmed: (ResidentFound resident) {
                        _request.destination = resident;
                        setState(() => _currentStep = 3);
                      },
                    );
                  }

                  if (_currentStep == 3) {
                    return ReasonAdmissionPage(
                      model: _request,
                      onBack: () => setState(() => _currentStep = 2),
                      onEditDestination: () => setState(() => _currentStep = 2),
                      onCallResident: () => setState(() => _currentStep = 4),
                    );
                  }

                  if (_currentStep == 4) {
                    return ResidentCallPage(
                      callSeconds: 10,
                      simulationAttempt1: CallSimResult.noAnswer,
                      simulationAttempt2: CallSimResult.authorized,
                      onGoNextStep: () => setState(() => _currentStep = 5),
                    );
                  }

                  if (_currentStep == 5) {
                    return CapturePlate(
                      onBack: () => setState(() => _currentStep = 4),
                      onFinishGoHome: () {
                        context.read<FunctionalProvider>().setEntryMethodItem(
                          GlobalHelper.EntryMethodItem.none,
                        );
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepsHeader extends StatelessWidget {
  const _StepsHeader({required this.currentIndex, required this.onTapStep});

  final int currentIndex;
  final ValueChanged<int> onTapStep;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 62,
      child: Row(
        children: List.generate(GlobalHelper.ingresoQrSteps.length, (i) {
          final isActive = i == currentIndex;
          final isCompleted = i < currentIndex;

          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onTapStep(i),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _StepDot(
                          index: i + 1,
                          isActive: isActive,
                          isCompleted: isCompleted,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          GlobalHelper.ingresoQrSteps[i].label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isActive
                                ? AppTheme.primaryColor
                                : isCompleted
                                ? AppTheme.dark
                                : AppTheme.hinText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                if (i != GlobalHelper.ingresoQrSteps.length - 1)
                  _Connector(isCompleted: i < currentIndex),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  const _StepDot({
    required this.index,
    required this.isActive,
    required this.isCompleted,
  });

  final int index;
  final bool isActive;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    final Color activeColor = AppTheme.primaryColor;

    if (isCompleted) {
      return Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: activeColor,
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              offset: const Offset(0, 6),
              color: activeColor.withOpacity(0.18),
            ),
          ],
        ),
        child: const Icon(Icons.check, size: 18, color: Colors.white),
      );
    }

    if (isActive) {
      return Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: activeColor,
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              offset: const Offset(0, 6),
              color: activeColor.withOpacity(0.18),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          '$index',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
        ),
      );
    }

    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFE9EEF4),
        border: Border.all(color: const Color(0xFFD7DEE8), width: 1),
      ),
      alignment: Alignment.center,
      child: Text(
        '$index',
        style: const TextStyle(
          color: Color(0xFF7C8896),
          fontWeight: FontWeight.w800,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _Connector extends StatelessWidget {
  const _Connector({required this.isCompleted});

  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 2,
      margin: const EdgeInsets.only(bottom: 22),
      decoration: BoxDecoration(
        color: isCompleted ? AppTheme.primaryColor : const Color(0xFFD7DEE8),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
