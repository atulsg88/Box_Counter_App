import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // App already initialized — safe to ignore on hot restart
    Firebase.app();
  }

  runApp(const ObjectCounterApp());
}
                     
class ObjectCounterApp extends StatelessWidget {
  const ObjectCounterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Box Detection Counter',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.deepPurpleAccent,
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardColor: const Color(0xFF1E1E1E),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: const DetectionCounterPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class DetectionCounterPage extends StatefulWidget {
  const DetectionCounterPage({super.key});

  @override
  State<DetectionCounterPage> createState() => _DetectionCounterPageState();
}

class _DetectionCounterPageState extends State<DetectionCounterPage> {
  late FirebaseFirestore _firestore;
  String _selectedPeriod = 'today'; // today, month, year

  @override
  void initState() {
    super.initState();
    _firestore = FirebaseFirestore.instance;
  }

  Map<String, int> _aggregateByBoxType(List<QueryDocumentSnapshot> docs) {
    final counts = <String, int>{};
    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final boxType = (data['box_type'] as String?) ?? 'Unknown';
      final label = boxType.isEmpty ? 'Unknown' : boxType;
      counts[label] = (counts[label] ?? 0) + 1;
    }
    return counts;
  }

  Future<List<QueryDocumentSnapshot>> _getBoxScans() async {
    final now = DateTime.now();
    final todayStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final monthStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}';
    final yearStr = '${now.year}';

    // Fetch all documents (same approach as Factory_Box_Tracker web app)
    final snapshot = await _firestore
        .collection('box_scans')
        .get();

    // Client-side filtering by date/month/year string fields
    final filtered = snapshot.docs.where((doc) {
      final data = doc.data();
      switch (_selectedPeriod) {
        case 'today':
          return data['date'] == todayStr;
        case 'month':
          return data['month'] == monthStr;
        case 'year':
          return data['year'] == yearStr;
        default:
          return true;
      }
    }).toList();

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Box Counts'),
      ),
      body: Column(
        children: [
          // Period selector
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: ['today', 'month', 'year'].map((period) {
                final isSelected = _selectedPeriod == period;
                return ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedPeriod = period;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSelected
                        ? Colors.deepPurpleAccent
                        : Colors.grey.shade700,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    period[0].toUpperCase() + period.substring(1),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<QueryDocumentSnapshot>>(
              future: _getBoxScans(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'No data found.\nRun your Python script to send data.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                final docs = snapshot.data!;
                final counts = _aggregateByBoxType(docs);
                final totalCount = docs.length;

                if (counts.isEmpty) {
                  return const Center(
                    child: Text(
                      'No boxes detected yet.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                final sortedItems = counts.entries.toList()
                  ..sort((a, b) => b.value.compareTo(a.value));

                return Column(
                  children: [
                    // Total Count Card
                    Card(
                      elevation: 6,
                      color: Colors.deepPurpleAccent,
                      margin: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Boxes',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              totalCount.toString(),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Box Type Counts
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16.0, 0, 16.0, 8.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Breakdown by Type:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),

                    Expanded(
                      child: ListView.builder(
                        itemCount: sortedItems.length,
                        itemBuilder: (context, index) {
                          final item = sortedItems[index];
                          final boxType = item.key;
                          final count = item.value;
                          final percentage =
                              (count / totalCount * 100).toStringAsFixed(1);

                          return Card(
                            elevation: 4,
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              leading: const Icon(
                                Icons.widgets_outlined,
                                color: Colors.deepPurpleAccent,
                                size: 30,
                              ),
                              title: Text(
                                boxType.isNotEmpty
                                    ? boxType[0].toUpperCase() + boxType.substring(1)
                                    : 'Unknown',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              subtitle: Text(
                                '$percentage%',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color:
                                      Colors.deepPurpleAccent.withAlpha(51),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  count.toString(),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepPurpleAccent,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
