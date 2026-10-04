import 'package:flutter/material.dart';
import './../common_widgets.dart';
import 'ipk.dart';
import 'kehadiran.dart';
import 'nilai.dart';

class MenuItem {
  final String title;
  final Widget? page;

  const MenuItem({required this.title, this.page});
}

const List<MenuItem> menuItems = [
  MenuItem(title: 'IPK', page: IpkScreen()),
  MenuItem(title: 'Kehadiran', page: KehadiranScreen()),
  MenuItem(title: 'Nilai', page: NilaiScreen()),
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
                      .map(
                        (item) => MenuCard(
                          title: item.title,
                          onTap: () {
                            final page = item.page;
                            if (page != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => page),
                              );
                            }
                          },
                        ),
                      )
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
  final VoidCallback onTap;

  const MenuCard({super.key, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const Icon(Icons.arrow_forward, size: 18, color: Colors.black),
          ],
        ),
      ),
    );
  }
}