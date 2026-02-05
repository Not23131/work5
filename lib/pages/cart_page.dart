import 'package:flutter/material.dart';
import '../service/cart_service.dart';
import '../service/sale_service.dart';
import '../model/cart_item.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  Widget build(BuildContext context) {
    final items = CartService.items;
    int totalPrice = items.fold(0, (sum, i) => sum + i.total);

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text("Order Review"),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 255, 211, 211),
      ),
      body: Column(
        children: [
          // 🛒 รายการสินค้า
          Expanded(
            child: items.isEmpty
                ? const Center(
                    child: Text(
                      "ไม่มีสินค้าในตะกร้า",
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final item = items[i];
                      return Dismissible(
                        key: ValueKey(item.name),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          padding: const EdgeInsets.only(right: 20),
                          alignment: Alignment.centerRight,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) {
                          setState(() {
                            CartService.removeItem(item.name);
                          });
                        },
                        child: CartItemWidget(
                          item: item,
                          onChanged: () => setState(() {}),
                        ),
                      );
                    },
                  ),
          ),

          // 💰 Bottom Panel
          Container(
            height: 220,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  blurRadius: 12,
                  color: Colors.black.withOpacity(0.15),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // ยอดรวม
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "ยอดรวมทั้งหมด",
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      "฿$totalPrice",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Spacer(),

                // ปุ่มยืนยันสั่งซื้อ
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: items.isEmpty
                        ? null
                        : () async {
                            // Confirm dialog
                            bool confirm = await showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text("ยืนยันการสั่งซื้อ"),
                                content: const Text(
                                    "คุณต้องการยืนยันการสั่งซื้อสินค้าหรือไม่?"),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text("ยกเลิก"),
                                  ),
                                  ElevatedButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text("ยืนยัน"),
                                  ),
                                ],
                              ),
                            );

                            if (confirm) {
                              try {
                                // Save cart to Firestore
                                await SaleService.saveCart(items);
                                // Clear local cart
                                CartService.clear();
                                if (context.mounted) Navigator.pop(context);
                              } catch (e) {
                                // Show error
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          "เกิดข้อผิดพลาด: ${e.toString()}"),
                                    ),
                                  );
                                }
                              }
                            }
                          },
                    child: const Text(
                      "ยืนยันการสั่งซื้อ",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =========================
// Cart Item Widget
// =========================
class CartItemWidget extends StatelessWidget {
  final CartItem item;
  final VoidCallback onChanged;

  const CartItemWidget({super.key, required this.item, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // ชื่อ + ราคา
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "฿${item.price}",
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),

          // Qty Controls
          Column(
            children: [
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  CartService.increase(item.name);
                  onChanged();
                },
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, anim) =>
                    ScaleTransition(scale: anim, child: child),
                child: Text(
                  item.qty.toString(),
                  key: ValueKey(item.qty),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: () {
                  CartService.decrease(item.name);
                  onChanged();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
