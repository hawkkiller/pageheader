import 'package:flutter/material.dart';
import 'package:pageheader/page_header.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with SingleTickerProviderStateMixin {
  late final tabController = TabController(length: 3, vsync: this);

  int currentIndex = 0;
  void onTap(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          onTap: onTap,
          currentIndex: currentIndex,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'TabBar'),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
          ],
        ),
        body: SafeArea(
          child: switch (currentIndex) {
            0 => const _TabBarExample(),
            _ => throw UnimplementedError('No widget for index $currentIndex'),
          },
        ),
      ),
    );
  }
}

class _TabBarExample extends StatelessWidget {
  const _TabBarExample();

  @override
  Widget build(BuildContext context) {
    SliverAppBar;
    return DefaultTabController(
      length: 3,
      child: CustomScrollView(
        slivers: [
          // pg.CupertinoSliverNavigationBar(
          //   largeTitle: const Text('My App Title, Very long title, lorem ipsum dolor'),
          //   bottom: const TabBar(
          //     tabs: [Tab(text: 'Tab 1'), Tab(text: 'Tab 2'), Tab(text: 'Tab 3')],
          //   ),
          // ),
          PageHeader(
            title: 'My App Title, Very long title, lorem ipsum dolor',
            bottom: TabBar(tabs: [Tab(text: 'Tab 1'), Tab(text: 'Tab 2'), Tab(text: 'Tab 3')]),
            bottomMode: BottomMode.floating,
          ),
          SliverList.builder(
            itemBuilder: (context, index) {
              return ListTile(title: Text('Item $index'));
            },
            itemCount: 100,
          ),
        ],
      ),
    );
  }
}
