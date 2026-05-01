class KeretaModel {
  final int id;
  final String namaKa;
  final String nomorKa;

  KeretaModel({
    required this.id,
    required this.namaKa,
    required this.nomorKa,
  });

  factory KeretaModel.fromJson(Map<String, dynamic> json) {
    return KeretaModel(
      id: json['ka_id'],
      namaKa: json['nama_ka'],
      nomorKa: json['nomor_ka'],
    );
  }
}
