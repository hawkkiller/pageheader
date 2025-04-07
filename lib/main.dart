import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pageheader/page_header.dart';

import 'pageheader_fork.dart' as pg;

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              // pg.CupertinoSliverNavigationBar.search(
              //   largeTitle: Text('My App Title'),
              //   automaticallyImplyTitle: false,
              //   searchField: CupertinoSearchTextField(),
              // ),
              PageHeader(
                title: Text('My App Title'),
              ),
              SliverList.builder(
                itemBuilder: (context, index) {
                  return ListTile(title: Text('Item $index'));
                },
                itemCount: 100,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
