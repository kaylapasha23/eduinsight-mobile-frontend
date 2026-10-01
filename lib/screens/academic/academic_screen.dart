import 'package:flutter/material.dart';
import './../common_widgets.dart';

class MenuItem {
  final String title;
  const MenuItem({required this.title});
}

const List<MenuItem> menuItems = [
  MenuItem(title: 'IPK'),
  MenuItem(title: 'Kehadiran'),
  MenuItem(title: 'Nilai'),
  MenuItem(title: 'Kelas'),
];

class AcademicScreen extends StatelessWidget {
  const AcademicScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const HeaderBar(),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 27),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: menuItems
                      .map((item) => MenuCard(title: item.title))
                      .toList(),
                ),
              ),
            ),
          ),
          const BottomBar(currentIndex: 1),
        ],
      ),
    );
  }
}

class MenuCard extends StatelessWidget {
  final String title;
  const MenuCard({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 60,
      margin: const EdgeInsets.only(bottom: 19),
      padding: const EdgeInsets.symmetric(horizontal: 30),
      decoration: BoxDecoration(
        color: kCardBlue,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black)),
          const Icon(Icons.arrow_forward, size: 18, color: Colors.black),
        ],
      ),
    );
  }
}