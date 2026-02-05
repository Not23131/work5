import 'package:flutter/material.dart';
import '../data/food_data.dart';
import '../service/location_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import '../service/cart_service.dart';

class FoodDetailPage extends StatefulWidget {
  final String name;
  const FoodDetailPage({super.key, required this.name});

  @override
  State<FoodDetailPage> createState() => _FoodDetailPageState();
}

class _FoodDetailPageState extends State<FoodDetailPage> {
  String gpsText = "กำลังหาตำแหน่ง...";
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    loadLocation();
    initVideo();
  }

  void initVideo() {
    final food = FoodData.foods[widget.name]!;
    _controller = VideoPlayerController.asset(food["video"])
      ..initialize().then((_) => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> loadLocation() async {
    final food = FoodData.foods[widget.name]!;
    final pos = await LocationService.getCurrentLocation();
    final dist = LocationService.distanceKm(
      pos.latitude,
      pos.longitude,
      food["lat"],
      food["lng"],
    );

    setState(() {
      gpsText =
          "📍 ${pos.latitude.toStringAsFixed(5)}, ${pos.longitude.toStringAsFixed(5)}\n"
          "🚗 ระยะทาง ${dist.toStringAsFixed(2)} กม.";
    });
  }

  Widget infoCard({required Widget child}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(padding: const EdgeInsets.all(12), child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    final food = FoodData.foods[widget.name]!;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
        centerTitle: true,
        backgroundColor: Colors.deepOrange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🎥 Video Header
            if (_controller.value.isInitialized)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    ),
                    IconButton(
                      iconSize: 60,
                      color: Colors.white,
                      icon: Icon(
                        _controller.value.isPlaying
                            ? Icons.pause_circle
                            : Icons.play_circle,
                      ),
                      onPressed: () {
                        setState(() {
                          _controller.value.isPlaying
                              ? _controller.pause()
                              : _controller.play();
                        });
                      },
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 16),

            // 📍 Location
            infoCard(
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(child: Text(gpsText)),
                ],
              ),
            ),

            // 🥬 Ingredients - Expandable
            ExpansionTile(
              leading: const Icon(Icons.kitchen),
              title: const Text(
                "🥬 วัตถุดิบ",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              children: food["ingredients"]
                  .map<Widget>((i) => Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 16),
                        child: Row(
                          children: [
                            const Text("• ", style: TextStyle(fontSize: 16)),
                            Expanded(
                                child: Text(
                              i,
                              style: const TextStyle(fontSize: 16),
                            )),
                          ],
                        ),
                      ))
                  .toList(),
            ),

            // 👨‍🍳 Steps - Expandable
            ExpansionTile(
              leading: const Icon(Icons.menu_book),
              title: const Text(
                "👨‍🍳 วิธีทำ",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              children: food["steps"]
                  .asMap()
                  .entries
                  .map<Widget>((e) => Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 16),
                        child: Text(
                          "${e.key + 1}. ${e.value}",
                          style: const TextStyle(fontSize: 16),
                        ),
                      ))
                  .toList(),
            ),

            const SizedBox(height: 24),

            // 🧭 Navigation Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.map),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  final lat = food["lat"];
                  final lng = food["lng"];
                  final uri = Uri.parse(
                      "https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving");
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri,
                        mode: LaunchMode.externalApplication);
                  }
                },
                label: const Text(
                  "นำทางไปยังร้าน",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // 🛒 Cart Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.shopping_cart),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  CartService.addItem(widget.name, food["price"]);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("เพิ่มลงตะกร้าแล้ว 🛒")),
                  );
                },
                label: Text(
                  "เพิ่มลงตะกร้า • ${food["price"]} บาท",
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
