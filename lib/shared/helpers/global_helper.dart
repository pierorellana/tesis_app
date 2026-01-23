import 'package:flutter/material.dart' hide Title;
import 'package:logger/logger.dart';

enum EntryMethodItem {
  none,
  scanQr,
  noQr,
  validatingQr,
  successValidation,
  rejectValidation,
}

enum IngresoQrStep { id, rostro, destino, motivo, llamada, placa, fin }

enum IdUiState { camera, reading, confirm }

class IngresoQrStepInfo {
  final IngresoQrStep step;
  final String label;

  const IngresoQrStepInfo(this.step, this.label);
}

const ingresoQrSteps = <IngresoQrStepInfo>[
  IngresoQrStepInfo(IngresoQrStep.id, 'ID'),
  IngresoQrStepInfo(IngresoQrStep.rostro, 'Rostro'),
  IngresoQrStepInfo(IngresoQrStep.destino, 'Destino'),
  IngresoQrStepInfo(IngresoQrStep.motivo, 'Motivo'),
  IngresoQrStepInfo(IngresoQrStep.llamada, 'Llamada'),
  IngresoQrStepInfo(IngresoQrStep.placa, 'Placa'),
  // IngresoQrStepInfo(IngresoQrStep.fin, 'Fin'),
];

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class GlobalHelper {
  static final logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: false,
    ),
  );

  static routeRemoveSlideTransition({
    required BuildContext context,
    required Widget page,
  }) {
    return Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return page;
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween = Tween(begin: begin, end: end);
          var offsetAnimation = animation.drive(
            tween.chain(CurveTween(curve: curve)),
          );
          return SlideTransition(position: offsetAnimation, child: child);
        },
      ),
      (route) => false,
    );
  }

  static bool validatorCedula(String cedula) {
    try {
      if (cedula.length == 10) {
        final digitoRegion = int.parse(cedula.substring(0, 2));

        if (digitoRegion >= 1 && digitoRegion <= 24) {
          final ultimoDigito = int.parse(cedula.substring(9, 10));

          var pares =
              int.parse(cedula.substring(1, 2)) +
              int.parse(cedula.substring(3, 4)) +
              int.parse(cedula.substring(5, 6)) +
              int.parse(cedula.substring(7, 8));

          var numero1 = int.parse(cedula.substring(0, 1));
          numero1 = (numero1 * 2);
          if (numero1 > 9) {
            numero1 = (numero1 - 9);
          }

          var numero3 = int.parse(cedula.substring(2, 3));
          numero3 = (numero3 * 2);
          if (numero3 > 9) {
            numero3 = (numero3 - 9);
          }

          var numero5 = int.parse(cedula.substring(4, 5));
          numero5 = (numero5 * 2);
          if (numero5 > 9) {
            numero5 = (numero5 - 9);
          }

          var numero7 = int.parse(cedula.substring(6, 7));
          numero7 = (numero7 * 2);
          if (numero7 > 9) {
            numero7 = (numero7 - 9);
          }

          var numero9 = int.parse(cedula.substring(8, 9));
          numero9 = (numero9 * 2);
          if (numero9 > 9) {
            numero9 = (numero9 - 9);
          }

          var impares = numero1 + numero3 + numero5 + numero7 + numero9;

          final sumaTotal = (pares + impares);

          final primerDigitoSuma = sumaTotal.toString().substring(0, 1);

          var decena = (int.parse(primerDigitoSuma) + 1) * 10;

          var digitoValidador = decena - sumaTotal;

          if (digitoValidador == 10) {
            digitoValidador = 0;
          }

          if (digitoValidador == ultimoDigito) {
            return true;
          } else {
            return false;
          }
        } else {
          return false;
        }
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  static RegExp text = RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+');
  static RegExp number = RegExp(r'^[0-9]+$');
  static String supportNumber = '+593958994583';

  static GlobalKey genKey() {
    GlobalKey key = GlobalKey();
    return key;
  }

  static dismissKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  static String capitalizeEachWord(String text) {
    try {
      if (text.isEmpty) return text;
      return text
          .replaceAll('-', ' ')
          .split(' ')
          .map(
            (word) => word.isNotEmpty
                ? word[0].toUpperCase() + word.substring(1).toLowerCase()
                : '',
          )
          .join(' ');
    } on Exception catch (e) {
      GlobalHelper.logger.e('Error en metodo capitalizeEachWord: $e');
      return text;
    }
  }
}
