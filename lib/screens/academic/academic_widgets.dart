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
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A2547), Color(0xFF253672)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: kNavy.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(12, 48, 20, 18),
      child: Row(
        children: [
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 22, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
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
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDE7),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4A300).withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: const Color(0xFFFFEE87), width: 1),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<ListItem>(
          value: selectedItem,
          isExpanded: true,
          dropdownColor: const Color(0xFFFFFDE7),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF8A7000)),
          style: const TextStyle(
            fontSize: 15,
            color: Color(0xFF3A3000),
            fontWeight: FontWeight.w500,
          ),
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
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.6),
            blurRadius: 18,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A2B4A),
                letterSpacing: 0.1,
              ),
            ),
          ),
          Divider(
            color: Colors.black.withValues(alpha: 0.12),
            thickness: 1,
            height: 1,
          ),
          child,
        ],
      ),
    );
  }
}