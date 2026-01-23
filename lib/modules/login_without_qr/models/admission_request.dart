import 'package:tesis_app/modules/login_without_qr/widgets/informations/information_id_widget.dart';
import 'package:tesis_app/modules/login_without_qr/models/resident_data.dart';

enum AdmissionReason { visit, delivery, taxi }

extension AdmissionReasonX on AdmissionReason {
  String get label {
    switch (this) {
      case AdmissionReason.visit:
        return 'Visita';
      case AdmissionReason.delivery:
        return 'Delivery / Pedido';
      case AdmissionReason.taxi:
        return 'Taxi';
    }
  }
}

class AdmissionRequestModel {
  IdParsedData? idData;
  ResidentFound? destination;
  AdmissionReason? reason;

  String get fullName {
    final d = idData;
    if (d == null) return '-';
    return '${d.names} ${d.surnames}'.trim();
  }

  String get identification => idData?.identification ?? '-';

  String get destinoLabel {
    final d = destination;
    if (d == null) return '-';
    return 'Manzana ${d.manzana} - Villa ${d.villa}';
  }

  String get residentName => destination?.residentName ?? '-';

  String get reasonLabel => reason?.label ?? '-';
}
