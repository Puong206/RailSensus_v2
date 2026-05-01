import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:railsensus/data/models/sensus_model.dart';

void main() {
  test('parsing sensus model', () {
    const jsonString = '{"sensus_id": 6, "user_id": 8, "loko_id": 8, "ka_id": 468, "trust_score": 2, "lokasi": "test", "foto_bukti": "/test.jpg", "waktu_sensus": "2026-05-21T17:37:38.000Z", "Lokomotif": {"tipe_model": "CC 201", "seri_model": "89 16"}, "Keretum": {"nama_ka": "Cilawalu Tanker"}, "User": {"username": "arya"}}';
    final model = SensusModel.fromJson(jsonDecode(jsonString));
    expect(model.id, 6);
    print('SUCCESS: ' + model.namaKa.toString());
  });
}
