import 'Bayraklar.dart';
import 'VeritabaniYardimcisi.dart';

class Bayraklardao {
  Future<List<Bayraklar>> rasgele5Getir() async {
    var db = await VeritabaniYardimcisi.veritabaniErisim();

    List<Map<String, dynamic>> maps = await db.rawQuery(
      "SELECT * FROM bayraklar ORDER BY RANDOM() LIMIT 100",
    );

    return maps.map((map) => Bayraklar.fromMap(map)).toList();
  }

  Future<List<Bayraklar>> rasgele3YanlisGetir(int bayrakId) async {
    var db = await VeritabaniYardimcisi.veritabaniErisim();

    List<Map<String, dynamic>> maps = await db.rawQuery(
      "SELECT * FROM bayraklar WHERE bayrak_id != ? ORDER BY RANDOM() LIMIT 3",
      [bayrakId],
    );

    return maps.map((map) => Bayraklar.fromMap(map)).toList();
  }
}
