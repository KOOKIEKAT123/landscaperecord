import 'package:flutter/material.dart';
import 'screens/overview_screen.dart';
import 'screens/records_screen.dart';
import 'screens/new_entry_screen.dart';

void main() {
  runApp(const LandscapeRecordApp());
}

class LandscapeRecordApp extends StatelessWidget {
  const LandscapeRecordApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Landscape Record',
      theme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      const OverviewScreen(),
      const RecordsScreen(),
      const NewEntryScreen(),
    ];

    return Scaffold(
      body: screens[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Overview'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Records'),
          BottomNavigationBarItem(
              icon: Icon(Icons.add_location_alt), label: 'New Entry'),
        ],
      ),
    );
  }
}
