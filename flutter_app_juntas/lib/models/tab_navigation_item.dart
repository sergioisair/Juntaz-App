import 'package:flutter/material.dart';

class TabNavigationItem {

  final Widget title;
  final Icon icon;
  final int index;

  TabNavigationItem({

    @required this.title,
    @required this.icon,
    @required this.index,
  });

  static List<TabNavigationItem> get items => [
        TabNavigationItem(
          index: 0,
          icon: Icon(Icons.blur_circular, size: 30, color: Colors.red),
          title: Text("Home"),
        ),
        TabNavigationItem(
          index: 1,
          icon: Icon(Icons.blur_circular, size: 30, color: Colors.blue),
          title: Text("Críticos"),
        ),
        TabNavigationItem(
          index: 2,
          icon: Icon(Icons.blur_circular, size: 30, color: Colors.blue),
          title: Text("Críticos"),
        ),
        TabNavigationItem(
          index: 3,
          icon: Icon(Icons.blur_circular, size: 30, color: Colors.green),
          title: Text("Estables"),
        ),

      ];
}
