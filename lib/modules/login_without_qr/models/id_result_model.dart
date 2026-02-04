import 'package:tesis_app/modules/login_without_qr/widgets/informations/information_id_widget.dart';

class IdStepResult {
  final IdParsedData data;
  final String fotoCedulaBase64;

  const IdStepResult({
    required this.data,
    required this.fotoCedulaBase64,
  });
}
