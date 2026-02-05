import 'package:flutter/material.dart';
import '../widgets/food_item.dart';
import 'cart_page.dart';

class FoodListPage extends StatefulWidget {
  const FoodListPage({super.key});

  @override
  State<FoodListPage> createState() => _FoodListPageState();
}

class _FoodListPageState extends State<FoodListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("รายการอาหาร"),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartPage()),
              );
              setState(() {});
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // หมวดอาหารคาว
            const Text("อาหารคาว", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: const [
                  SizedBox(
                    width: 120, // กำหนดความกว้างคงที่
                    child: FoodItem(name: "โจ้ก", imagePath: "assets/images/joke.jpg"),
                  ),
                  SizedBox(width: 10),
                  SizedBox(
                    width: 120,
                    child: FoodItem(name: "ข้าวมันไก่", imagePath: "assets/images/chick.jpg"),
                  ),
                  SizedBox(width: 10),
                  SizedBox(
                    width: 120,
                    child: FoodItem(name: "ข้าวหมูกรอบ", imagePath: "assets/images/pork.webp"),
                  ),
                  SizedBox(width: 10),
                  SizedBox(
                    width: 120,
                    child: FoodItem(name: "หมูย่าง", imagePath: "assets/images/grill.webp"),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // หมวดของหวาน
            const Text("ของหวาน", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: const [
                  SizedBox(
                    width: 120,
                    child: FoodItem(name: "เค้กช็อกโกแลต", imagePath: "assets/images/cake.jpg"),
                  ),
                  SizedBox(width: 10),
                  SizedBox(
                    width: 120,
                    child: FoodItem(name: "บิงซู", imagePath: "assets/images/bingsu.jpg"),
                  ),
                  SizedBox(width: 10),
                  SizedBox(
                    width: 120,
                    child: FoodItem(name: "โรตี", imagePath: "assets/images/roll.jpg"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
