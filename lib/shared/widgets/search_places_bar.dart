import 'package:flutter/material.dart';

class SearchPlacesBar extends StatelessWidget {
  final TextEditingController? controller;
  final VoidCallback? onFavoriteTap;
  final ValueChanged<String>? onChanged;

  const SearchPlacesBar({
    Key? key,
    this.controller,
    this.onFavoriteTap,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xF6EDE5EB),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              children: [
                const Icon(Icons.search, color: Color(0xFF990045)),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: controller,
                    onChanged: onChanged,
                    decoration: const InputDecoration(
                      hintText: 'Buscar lugares',
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Color(0xFF990045)),
                    ),
                    style: const TextStyle(color: Color(0xFF990045)),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: onFavoriteTap,
          child: const Icon(
            Icons.favorite_border,
            color: Color(0xFF990045),
            size: 28,
          ),
        ),
      ],
    );
  }
} 