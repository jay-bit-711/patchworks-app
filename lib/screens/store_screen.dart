import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'agent_chat_screen.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  List<dynamic> materials = [];

  @override
  void initState() {
    super.initState();
    _loadMaterials();
  }

  Future<void> _loadMaterials() async {
    try {
      final String response = await rootBundle.loadString('material.json');
      final data = await json.decode(response);
      setState(() {
        materials = data['materials'];
      });
    } catch (e) {
      debugPrint("Error loading materials: $e");
    }
  }

  String _getImageForId(String id) {
    switch (id) {
      case 'sand_lorry':
        return 'https://images.unsplash.com/photo-1530263114838-c7827bd3fbce?auto=format&fit=crop&w=400&q=80'; // Sand/Truck
      case 'brick_red':
        return 'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?auto=format&fit=crop&w=400&q=80'; // Red Bricks
      case 'brick_hollow':
        return 'https://images.unsplash.com/photo-1590060417673-42846ea9f0c1?auto=format&fit=crop&w=400&q=80'; // Hollow blocks
      case 'ready_mix':
        return 'https://images.unsplash.com/photo-1536895058696-a69b1c7ba34f?auto=format&fit=crop&w=400&q=80'; // Concrete mixer
      case 'cement_lorry':
        return 'https://images.unsplash.com/photo-1517581177682-a085bb7ffb15?auto=format&fit=crop&w=400&q=80'; // Cement bags
      case 'steel_tmt':
        return 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?auto=format&fit=crop&w=400&q=80'; // Steel bars
      default:
        return 'https://images.unsplash.com/photo-1504307651254-35680f356dfd?auto=format&fit=crop&w=400&q=80'; // General construction
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        title: const Text('Material Store', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF161B22),
        elevation: 0,
      ),
      body: Stack(
        children: [
          materials.isEmpty 
            ? const Center(child: CircularProgressIndicator(color: Colors.orange))
            : GridView.builder(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 80),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: materials.length > 8 ? 8 : materials.length,
                itemBuilder: (context, index) {
                  final item = materials[index];
                  return _buildMaterialCard(item);
                },
              ),
          
          // Floating Agent Material Entry
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton.extended(
              backgroundColor: Colors.orange,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AgentChatScreen(agentId: 'material')),
                );
              },
              icon: const Icon(Icons.auto_awesome, color: Colors.white),
              label: const Text('Ask Agent Material', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialCard(dynamic item) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              child: Image.network(
                _getImageForId(item['id']),
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.white10,
                  child: const Icon(Icons.image_not_supported, color: Colors.white24),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'],
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${item['price_per_unit_inr']} / ${item['unit']}',
                  style: const TextStyle(color: Color(0xFF3FB950), fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.withOpacity(0.1),
                      side: const BorderSide(color: Colors.orange, width: 0.5),
                      padding: const EdgeInsets.symmetric(vertical: 0),
                      minimumSize: const Size(0, 32),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {},
                    child: const Text('Order Now', style: TextStyle(fontSize: 12, color: Colors.orange, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
