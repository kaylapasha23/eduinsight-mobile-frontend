import 'package:flutter/material.dart';
import '../common_widgets.dart';

const Color kYellow = Color(0xFFFFFFBB);
const Color kTileBlue = Color(0xFFEEF3FF);
const Color kTitleBlue = Color(0xFF3A6BBF);

class ListItem {
  final int value;
  final String name;

  const ListItem({required this.value, required this.name});
}

class BackHeaderBar extends StatelessWidget {
  final String title;

  const BackHeaderBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: kNavy,
      padding: const EdgeInsets.fromLTRB(20, 44, 20, 18),
      child: Row(
        children: [
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, size: 26, color: Colors.white),
          ),
          const SizedBox(width: 24),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class YellowDropdown extends StatelessWidget {
  final List<ListItem> items;
  final ListItem selectedItem;
  final ValueChanged<ListItem?> onChanged;
  final double height;

  const YellowDropdown({
    super.key,
    required this.items,
    required this.selectedItem,
    required this.onChanged,
    this.height = 52,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: kYellow,
        borderRadius: BorderRadius.circular(24),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<ListItem>(
          value: selectedItem,
          isExpanded: true,
          dropdownColor: kYellow,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black),
          style: const TextStyle(fontSize: 16, color: Colors.black),
          items: items.map((ListItem item) {
            return DropdownMenuItem<ListItem>(
              value: item,
              child: Text(item.name),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class TitledCard extends StatelessWidget {
  final String title;
  final Color color;
  final Widget child;

  const TitledCard({
    super.key,
    required this.title,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          const Divider(color: Colors.black, thickness: 1, height: 1),
          child,
        ],
      ),
    );
  }
}