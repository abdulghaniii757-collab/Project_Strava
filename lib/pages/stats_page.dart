import 'package:flutter/material.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  String selectedFilter = 'Berlari';

  final List<Map<String, String>> sampleRoutes = [
    {
      'title': 'Rute Monas Loop',
      'distance': '5.2 km',
      'type': 'Berlari',
      'elevation': '12m elevation',
    },
    {
      'title': 'Gowes PIK 2 Coast',
      'distance': '18.5 km',
      'type': 'Bersepeda',
      'elevation': '25m elevation',
    },
    {
      'title': 'Pluit Park Jogging Route',
      'distance': '3.1 km',
      'type': 'Berjalan',
      'elevation': '5m elevation',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Peta & Rute Popular',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background Simulator Peta / Visual GPS
          Container(
            width: double.infinity,
            height: double.infinity,
            color: const Color(0xFF1E1E1E),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.map_outlined,
                    size: 90,
                    color: Colors.deepOrange.withOpacity(0.8),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Peta GPS Aktif',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Menampilkan rute terbaik di sekitarmu',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),

          // Baris Pencarian & Filter Jenis Olahraga di Atas Peta
          Positioned(
            top: 12,
            left: 16,
            right: 16,
            child: Column(
              children: [
                // Search Bar
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Colors.grey[800]!),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.search, color: Colors.deepOrange),
                      SizedBox(width: 10),
                      Text(
                        'Cari lokasi, kota, atau rute...',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Filter Chip Olahraga (Berlari, Bersepeda, Berjalan)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['Berlari', 'Bersepeda', 'Berjalan'].map((
                      filter,
                    ) {
                      final isSelected = selectedFilter == filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(
                            filter,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.grey,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: Colors.deepOrange,
                          backgroundColor: Colors.grey[900],
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                selectedFilter = filter;
                              });
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Sheet / Card Rekomendasi Rute di Bawah
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 220,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black54,
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Rekomendasi Rute Terdekat',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: sampleRoutes.length,
                      itemBuilder: (context, index) {
                        final route = sampleRoutes[index];
                        return Container(
                          width: 200,
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[800]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.directions_run,
                                    color: Colors.deepOrange,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      route['title']!,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                route['distance']!,
                                style: const TextStyle(
                                  color: Colors.deepOrange,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${route['type']} • ${route['elevation']}',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
