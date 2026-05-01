class DepoModel {
  final int id;
  final String kodeDepo;
  final String namaDepo;

  DepoModel({
    required this.id,
    required this.kodeDepo,
    required this.namaDepo,
  });

  factory DepoModel.fromJson(Map<String, dynamic> json) {
    return DepoModel(
      id: json['depo_id'],
      kodeDepo: json['kode_depo'],
      namaDepo: json['nama_depo'],
    );
  }
}
