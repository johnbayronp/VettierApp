import 'package:flutter/material.dart';

class CustomAnimatedNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  const CustomAnimatedNavBar({required this.selectedIndex, required this.onItemSelected});

  @override
  Widget build(BuildContext context) {
    final items = [
      {'icon': Icons.home, 'label': 'Inicio'},
      {'icon': Icons.shopping_bag, 'label': 'Productos'},
      {'icon': Icons.calendar_today, 'label': 'Citas'},
      {'icon': Icons.person, 'label': 'Perfil'},
    ];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06), // sombra muy suave, sin morado
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (i) {
          final selected = i == selectedIndex;
          return GestureDetector(
            onTap: () => onItemSelected(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.ease,
              padding: EdgeInsets.symmetric(horizontal: selected ? 18 : 0, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? Colors.purple.withOpacity(0.15) : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(
                    items[i]['icon'] as IconData,
                    color: Colors.purple,
                    size: 26,
                  ),
                  if (selected) ...[
                    const SizedBox(width: 6),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: Text(
                        items[i]['label'] as String,
                        key: ValueKey(i),
                        style: const TextStyle(
                          color: Colors.purple,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ]
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
} 