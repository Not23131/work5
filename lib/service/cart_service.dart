import '../model/cart_item.dart';

class CartService {
  static final List<CartItem> _items = [];

  static List<CartItem> get items => _items;

  static void addItem(String name, int price) {
    final index = _items.indexWhere((i) => i.name == name);
    if (index >= 0) {
      _items[index].qty++;
    } else {
      _items.add(CartItem(name: name, price: price));
    }
  }

  static void removeItem(String name) {
    _items.removeWhere((i) => i.name == name);
  }

  static void increase(String name) {
    _items.firstWhere((i) => i.name == name).qty++;
  }

  static void decrease(String name) {
    final item = _items.firstWhere((i) => i.name == name);
    if (item.qty > 1) {
      item.qty--;
    }
  }

  static int get totalPrice => _items.fold(0, (sum, i) => sum + i.total);

  static void clear() {
    _items.clear();
  }
}
