import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/cart_item.dart';

class SaleService {
  static Future<void> saveSale({required int price, required int pc}) async {
    final int total = price * pc;

    await FirebaseFirestore.instance.collection('sales').add({
      'price': price,
      'pc': pc,
      'total': total,
      'net_price': total,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> saveCart(List<CartItem> items) async {
    final total = items.fold(0, (sum, i) => sum + i.price * i.qty);

    await FirebaseFirestore.instance.collection("orders").add({
      "items": items
          .map(
            (i) => {
              "name": i.name,
              "price": i.price,
              "qty": i.qty,
              "total": i.price * i.qty,
            },
          )
          .toList(),
      "total": total,
      "timestamp": FieldValue.serverTimestamp(),
    });
  }
}
