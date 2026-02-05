class Cart {
  static Map<String, int> items = {};

  static void addItem(String name) {
    items[name] = (items[name] ?? 0) + 1;
  }

  static void removeItem(String name) {
    if (!items.containsKey(name)) return;

    if (items[name]! > 1) {
      items[name] = items[name]! - 1;
    } else {
      items.remove(name);
    }
  }

  static double getTotalPrice(Map foods) {
    double total = 0;
    items.forEach((name, qty) {
      total += foods[name]["price"] * qty;
    });
    return total;
  }
}
