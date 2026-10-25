import 'package:flutter/material.dart';
import '../common_widgets.dart';

// ---------- Header BIRU untuk semua halaman akademik & KHS ----------
class BackHeaderBar extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const BackHeaderBar({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color barBg = isDark ? const Color(0xFF131720) : kNavy;

    return Container(
      width: double.infinity,
      color: barBg,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 12),
          child: Row(
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}

// Model ListItem dropdown
class ListItem {
  final int value;
  final String name;

  const ListItem({required this.value, required this.name});
}

// ---------- Modern Dropdown ----------
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
    this.height = 54,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bg = isDark ? const Color(0xFF282D37) : Colors.white;
    final Color textColor = isDark ? Colors.white : const Color(0xFF0F172A);

    return Container(
      width: double.infinity,
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<ListItem>(
          value: selectedItem,
          isExpanded: true,
          dropdownColor: bg,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: isDark ? Colors.white70 : const Color(0xFF64748B)),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
          items: items.map((ListItem item) {
            return DropdownMenuItem<ListItem>(
              value: item,
              child: Text(item.name, overflow: TextOverflow.ellipsis),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

// ---------- Kartu berdesain modern dengan header ----------
class TitledCard extends StatelessWidget {
  final String title;
  final Color? color;
  final Widget child;

  const TitledCard({
    super.key,
    required this.title,
    this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = color ?? (isDark ? const Color(0xFF282D37) : Colors.white);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
          ),
          Divider(
            color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
            thickness: 1,
            height: 1,
          ),
          child,
        ],
      ),
    );
  }
}
