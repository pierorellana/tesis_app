class ResidentFound {
  final String manzana;
  final String villa;
  final String residentName;
  final String? celular;
  final int? viviendaPk;

  const ResidentFound({
    required this.manzana,
    required this.villa,
    required this.residentName,
    this.celular,
    this.viviendaPk,
  });
}
